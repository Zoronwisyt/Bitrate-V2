import UIKit

/**
 * ZoronLoader - Auto-initializing entrypoint hook
 */
public final class ZoronLoader: NSObject {

    @objc public static let shared: ZoronLoader = {
        let instance = ZoronLoader()
        instance.setup()
        return instance
    }()

    private var retryTimer: Timer?

    private override init() {
        super.init()
    }

    private func setup() {
        // Enable Swizzling immediately
        ZoronBitrateSwizzler.enableBooster()
        
        // Start an aggressive timer to ensure the UI shows up
        DispatchQueue.main.async {
            self.retryTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] timer in
                let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
                let activeScene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
                
                if let scene = activeScene {
                    // We found the screen! Show the button and stop the timer.
                    ZoronOverlayWindow.shared.present(in: scene)
                    self?.showSuccessAlert(in: scene)
                    timer.invalidate()
                }
            }
        }
    }
    
    private func showSuccessAlert(in scene: UIWindowScene) {
        if let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            let alert = UIAlertController(title: "✅ Zoron Booster Active", message: "The H.264 / H.265 bitrate booster has been successfully injected into Alight Motion!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Let's Go!", style: .default))
            root.present(alert, animated: true)
        }
    }
}

// C-Bridge function that gets called by the C Constructor
@_cdecl("zoron_swift_entry")
public func zoron_swift_entry() {
    _ = ZoronLoader.shared
}
