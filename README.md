# LanMirror

Native iOS ReplayKit LAN screen mirroring project.

## Hardcoded PC address

`192.168.100.196:6969`

The Broadcast Upload Extension sends JPEG frames to:

`ws://192.168.100.196:6969/ws`

## Broadcast button

The main app contains Apple's real `RPSystemBroadcastPickerView`.
Open the app and tap the large blue ReplayKit broadcast icon.

The built app must contain:

`LanMirror.app/PlugIns/BroadcastUpload.appex`

The Codemagic workflow fails the build if that extension is missing.

## Signing

Codemagic creates an unsigned IPA so it can be signed afterward.
No App Group entitlement is used.
