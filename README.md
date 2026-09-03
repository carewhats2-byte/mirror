# LanMirror

Native iOS LAN screen mirroring prototype using ReplayKit Broadcast Upload Extension + WebSocket JPEG frames.

## Receiver

The current receiver is hardcoded in both the app UI and broadcast extension as:

- PC LAN IP: `192.168.100.196`
- Port: `6969`
- WebSocket: `ws://192.168.100.196:6969/ws`
- Browser viewer: `http://192.168.100.196:6969`

If your PC has a different LAN IP, edit `mirrorHost` in:

- `BroadcastUpload/SampleHandler.swift`
- `LanMirror/ContentView.swift` (display only)

No App Group entitlement is used. This makes the unsigned build simpler for external IPA signing.

## Python server

```bash
cd Server
pip install -r requirements.txt
python server.py
```

Allow TCP port `6969` through your PC firewall and make sure the iPhone and PC are on the same LAN.

## Codemagic

`codemagic.yaml` builds with signing disabled and packages:

`LanMirror.ipa`

The IPA remains unsigned. A signing tool must sign the embedded `BroadcastUpload.appex` and then the main `LanMirror.app` with compatible provisioning.
