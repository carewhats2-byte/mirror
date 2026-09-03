import SwiftUI
import ReplayKit

private let mirrorHost = "192.168.100.196"
private let mirrorPort = 6969

struct BroadcastPicker: UIViewRepresentable {
    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(frame: .zero)
        picker.preferredExtension = "com.example.LanMirror.BroadcastUpload"
        picker.showsMicrophoneButton = false
        return picker
    }

    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {}
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("PC receiver")) {
                    Text("ws://\(mirrorHost):\(mirrorPort)/ws")
                        .textSelection(.enabled)

                    Text("Change mirrorHost in BroadcastUpload/SampleHandler.swift before building if your PC LAN IP is different.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Start mirroring")) {
                    HStack {
                        Spacer()
                        BroadcastPicker()
                            .frame(width: 64, height: 64)
                        Spacer()
                    }

                    Text("Tap the broadcast button, choose LanMirror Broadcast, then start the broadcast. Microphone capture is hidden.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Viewer")) {
                    Text("Open http://\(mirrorHost):\(mirrorPort) in a browser on your LAN.")
                        .textSelection(.enabled)
                }
            }
            .navigationTitle("LAN Mirror")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
