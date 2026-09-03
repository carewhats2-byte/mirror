import asyncio
from typing import Optional

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import HTMLResponse, StreamingResponse
import uvicorn

app = FastAPI()

latest_frame: Optional[bytes] = None
frame_id = 0
frame_condition = asyncio.Condition()


@app.get("/", response_class=HTMLResponse)
async def index():
    return """
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>LAN Mirror</title>
  <style>
    html,body{margin:0;height:100%;background:#111;color:#eee;font-family:system-ui}
    body{display:flex;align-items:center;justify-content:center;overflow:hidden}
    img{max-width:100vw;max-height:100vh;object-fit:contain}
    .status{position:fixed;top:10px;left:10px;background:#0009;padding:6px 9px;border-radius:8px;font-size:13px}
  </style>
</head>
<body>
  <div class="status">LAN Mirror · /video</div>
  <img src="/video" alt="Waiting for iPhone stream…">
</body>
</html>
"""


@app.websocket("/ws")
async def receive_frames(ws: WebSocket):
    global latest_frame, frame_id

    await ws.accept()
    print(f"iPhone connected: {ws.client}")

    try:
        while True:
            data = await ws.receive_bytes()

            # Basic sanity check for JPEG SOI/EOI markers.
            if len(data) < 4 or not data.startswith(b"\xff\xd8") or not data.endswith(b"\xff\xd9"):
                continue

            async with frame_condition:
                latest_frame = data
                frame_id += 1
                frame_condition.notify_all()

    except WebSocketDisconnect:
        print("iPhone disconnected")
    except Exception as exc:
        print(f"WebSocket error: {exc}")


async def mjpeg_stream():
    seen_id = -1

    while True:
        async with frame_condition:
            await frame_condition.wait_for(lambda: latest_frame is not None and frame_id != seen_id)
            frame = latest_frame
            seen_id = frame_id

        yield (
            b"--frame\r\n"
            b"Content-Type: image/jpeg\r\n"
            b"Cache-Control: no-cache\r\n"
            + f"Content-Length: {len(frame)}\r\n\r\n".encode()
            + frame
            + b"\r\n"
        )


@app.get("/video")
async def video():
    return StreamingResponse(
        mjpeg_stream(),
        media_type="multipart/x-mixed-replace; boundary=frame",
        headers={"Cache-Control": "no-store, no-cache, must-revalidate, max-age=0"},
    )


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=6969)
