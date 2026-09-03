import SwiftUI
import ReplayKit

private let appGroupID = "group.com.example.LanMirror"
private let hostKey = "mirrorHost"
private let portKey = "mirrorPort"

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
    @State private var host = "192.168.100.196"
    @State private var port = "6969"
    @State private var saved = false

    var body: some View {
        NavigationView {
            Form {
                Section("PC receiver") {
                    TextField("PC LAN IP", text: $host)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.numbersAndPunctuation)

                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)

                    Button("Save receiver") {
                        saveReceiver()
                    }

                    if saved {
                        Text("Saved: ws://\(host):\(port)/ws")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Start mirroring") {
                    HStack {
                        Spacer()
                        BroadcastPicker()
                            .frame(width: 64, height: 64)
                        Spacer()
                    }

                    Text("Tap the broadcast button, choose LanMirror Broadcast, then start the broadcast. Microphone capture is hidden.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Viewer") {
                    Text("Open http://\(host):\(port) in a browser on your LAN.")
                        .textSelection(.enabled)
                }
            }
            .navigationTitle("LAN Mirror")
            .onAppear(perform: loadReceiver)
        }
    }

    private func loadReceiver() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        host = defaults.string(forKey: hostKey) ?? "192.168.1.42"
        let storedPort = defaults.integer(forKey: portKey)
        port = storedPort > 0 ? String(storedPort) : "6969"
    }

    private func saveReceiver() {
        let cleanHost = host.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPort = Int(port) ?? 6969

        guard !cleanHost.isEmpty, (1...65535).contains(cleanPort) else {
            saved = false
            return
        }

        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            saved = false
            return
        }

        defaults.set(cleanHost, forKey: hostKey)
        defaults.set(cleanPort, forKey: portKey)
        saved = true
    }
}
