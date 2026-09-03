# LanMirror

A simple LAN-only iPhone screen-mirroring prototype.

## Architecture

iPhone ReplayKit -> Broadcast Upload Extension -> JPEG binary WebSocket frames ->
FastAPI on the PC -> MJPEG `/video` -> browser viewer.

Default receiver:

- WebSocket: `ws://192.168.1.42:6969/ws`
- Browser: `http://192.168.1.42:6969`

The host and port are editable in the iOS app.

## PC server

```bash
cd Server
python -m pip install -r requirements.txt
python server.py
```

The server binds `0.0.0.0:6969`.

Allow inbound TCP port 6969 through the PC firewall if necessary, then browse to:

```text
http://YOUR_PC_LAN_IP:6969
```

Do not use `127.0.0.1` from the iPhone; that points back to the iPhone.

## Xcode / signing

The included project uses placeholder identifiers:

- App: `com.example.LanMirror`
- Extension: `com.example.LanMirror.BroadcastUpload`
- App Group: `group.com.example.LanMirror`

Before signing, change these to identifiers owned by your Apple Developer account. Keep the
same App Group enabled on BOTH targets. Also update `preferredExtension` in
`LanMirror/ContentView.swift` if you change the extension bundle ID.

The project intentionally does not contain a development team ID or signing certificate.

## Using it

1. Start `Server/server.py` on the PC.
2. Find the PC's LAN IPv4 address, for example `192.168.1.42`.
3. Open LAN Mirror on the iPhone.
4. Enter the PC LAN IP and port `6969`, then tap **Save receiver**.
5. Tap the ReplayKit broadcast picker button.
6. Select **LanMirror Broadcast** and start broadcasting.
7. Open `http://PC_IP:6969` in a browser.

The extension drops frames while a previous WebSocket send is still in flight and limits
capture to roughly 15 FPS. Microphone selection is hidden.

## Prototype security note

This prototype sends JPEG frames over cleartext `ws://` on the local network and includes
an ATS arbitrary-load exception so literal LAN IPv4 WebSocket URLs work during testing.
Do not expose port 6969 to the public internet. A production version should use authenticated
`wss://` transport.

## ReplayKit status

Apple currently marks the ReplayKit Broadcast Upload sample-handler APIs used here as
deprecated. They remain the architecture requested for this project, but future SDKs may
require migration to newer capture APIs.
