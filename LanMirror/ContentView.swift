import SwiftUI
import ReplayKit
import UIKit

private let mirrorHost = "192.168.100.196"
private let mirrorPort = 6969
private let broadcastExtensionBundleID = "com.example.LanMirror.BroadcastUpload"

struct BroadcastPicker: UIViewRepresentable {
    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(
            frame: CGRect(x: 0, y: 0, width: 88, height: 88)
        )

        picker.preferredExtension = broadcastExtensionBundleID
        picker.showsMicrophoneButton = false

        // Make Apple's real ReplayKit broadcast control very obvious.
        picker.tintColor = .systemBlue
        picker.backgroundColor = .secondarySystemBackground
        picker.layer.cornerRadius = 18
        picker.layer.borderWidth = 2
        picker.layer.borderColor = UIColor.systemBlue.cgColor
        picker.clipsToBounds = true

        return picker
    }

    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {
        uiView.preferredExtension = broadcastExtensionBundleID
        uiView.showsMicrophoneButton = false
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 22) {
                Spacer()

                Text("LAN Mirror")
                    .font(.largeTitle)
                    .bold()

                Text("PC: \(mirrorHost):\(mirrorPort)")
                    .font(.headline)

                Text("Tap the blue broadcast icon below.")
                    .font(.title3)
                    .multilineTextAlignment(.center)

                BroadcastPicker()
                    .frame(width: 88, height: 88)

                Text("START BROADCAST")
                    .font(.headline)
                    .bold()

                Text("iOS will open Apple's Broadcast sheet. Choose “LanMirror Broadcast”, then tap Start Broadcast.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                Divider()
                    .padding(.horizontal, 24)

                Text("Streaming target")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("ws://\(mirrorHost):\(mirrorPort)/ws")
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
