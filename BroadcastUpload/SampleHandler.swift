import ReplayKit
import CoreImage
import CoreMedia
import Foundation
import ImageIO
import QuartzCore

private let mirrorHost = "192.168.100.196"
private let mirrorPort = 6969

final class SampleHandler: RPBroadcastSampleHandler {
    private let ciContext = CIContext(options: [.cacheIntermediates: false])
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    private let frameInterval: CFTimeInterval = 1.0 / 15.0

    private var session: URLSession?
    private var socket: URLSessionWebSocketTask?
    private var lastFrameTime: CFTimeInterval = 0
    private var sendingFrame = false

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        connect()
    }

    override func broadcastPaused() {}

    override func broadcastResumed() {}

    override func broadcastFinished() {
        socket?.cancel(with: .normalClosure, reason: nil)
        socket = nil
        session?.invalidateAndCancel()
        session = nil
        sendingFrame = false
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video else { return }

        let now = CACurrentMediaTime()
        guard now - lastFrameTime >= frameInterval else { return }
        guard !sendingFrame else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        lastFrameTime = now

        autoreleasepool {
            let image = CIImage(cvPixelBuffer: pixelBuffer)
            let options: [CIImageRepresentationOption: Any] = [
                CIImageRepresentationOption(
                    rawValue: kCGImageDestinationLossyCompressionQuality as String
                ): 0.62
            ]

            guard let jpeg = ciContext.jpegRepresentation(
                of: image,
                colorSpace: colorSpace,
                options: options
            ) else { return }

            send(jpeg)
        }
    }

    private func connect() {
        guard let url = URL(string: "ws://\(mirrorHost):\(mirrorPort)/ws") else {
            finishBroadcastWithError(MirrorError.invalidURL)
            return
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 8
        configuration.timeoutIntervalForResource = 60 * 60

        let session = URLSession(configuration: configuration)
        let socket = session.webSocketTask(with: url)

        self.session = session
        self.socket = socket
        socket.resume()

        socket.sendPing { [weak self] error in
            guard let self = self, let error = error else { return }
            self.finishBroadcastWithError(error)
        }
    }

    private func send(_ jpeg: Data) {
        guard let socket = socket else { return }

        sendingFrame = true
        socket.send(.data(jpeg)) { [weak self] error in
            guard let self = self else { return }
            self.sendingFrame = false

            if error != nil {
                self.reconnectAfterSendFailure()
            }
        }
    }

    private func reconnectAfterSendFailure() {
        socket?.cancel(with: .goingAway, reason: nil)
        session?.invalidateAndCancel()
        socket = nil
        session = nil
        sendingFrame = false
        connect()
    }
}

private enum MirrorError: LocalizedError {
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid LAN mirror WebSocket URL."
        }
    }
}
