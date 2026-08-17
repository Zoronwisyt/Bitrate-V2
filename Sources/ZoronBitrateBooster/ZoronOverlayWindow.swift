import UIKit

public class ZoronOverlayWindow: UIWindow {

    public static let shared = ZoronOverlayWindow()

    public let floatingButton = UIButton(type: .custom)
    private var guiVC: ZoronBitrateGUIViewController?
    private var initialCenter = CGPoint.zero

    private init() {
        super.init(frame: UIScreen.main.bounds)
        setupWindow()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWindow() {
        self.windowLevel = UIWindow.Level.alert + 1000
        self.backgroundColor = .clear
        self.isHidden = true

        let rootVC = OverlayPassthroughViewController()
        rootVC.view.backgroundColor = .clear
        self.rootViewController = rootVC

        setupFloatingButton(in: rootVC.view)
    }

    private func setupFloatingButton(in containerView: UIView) {
        floatingButton.frame = CGRect(x: UIScreen.main.bounds.width - 74, y: 120, width: 58, height: 58)
        floatingButton.layer.cornerRadius = 29
        floatingButton.clipsToBounds = true
        floatingButton.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 0.95)
        floatingButton.layer.borderWidth = 2.0
        floatingButton.layer.borderColor = UIColor(red: 0.05, green: 0.85, blue: 0.5, alpha: 0.9).cgColor

        floatingButton.layer.shadowColor = UIColor(red: 0.05, green: 0.85, blue: 0.5, alpha: 1.0).cgColor
        floatingButton.layer.shadowOffset = .zero
        floatingButton.layer.shadowRadius = 12
        floatingButton.layer.shadowOpacity = 0.85
        floatingButton.layer.masksToBounds = false

        floatingButton.setTitle("⚡4K", for: .normal)
        floatingButton.setTitleColor(UIColor(red: 0.2, green: 1.0, blue: 0.6, alpha: 1.0), for: .normal)
        floatingButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .black)

        floatingButton.addTarget(self, action: #selector(toggleMenu), for: .touchUpInside)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        floatingButton.addGestureRecognizer(panGesture)

        containerView.addSubview(floatingButton)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        if gesture.state == .began {
            initialCenter = floatingButton.center
        } else if gesture.state == .changed {
            floatingButton.center = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            let screenWidth = UIScreen.main.bounds.width
            let targetX: CGFloat = floatingButton.center.x > screenWidth / 2 ? screenWidth - 38 : 38
            let targetY = max(90, min(UIScreen.main.bounds.height - 90, floatingButton.center.y))

            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.floatingButton.center = CGPoint(x: targetX, y: targetY)
            }
        }
    }

    @objc public func toggleMenu() {
        guard let rootVC = self.rootViewController else { return }

        if let existing = guiVC {
            UIView.animate(withDuration: 0.25, animations: {
                existing.view.alpha = 0.0
                existing.view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            }) { _ in
                existing.view.removeFromSuperview()
                existing.removeFromParent()
                self.guiVC = nil
            }
        } else {
            let vc = ZoronBitrateGUIViewController()
            rootVC.addChild(vc)
            vc.view.frame = rootVC.view.bounds
            vc.view.alpha = 0.0
            vc.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            rootVC.view.addSubview(vc.view)
            vc.didMove(toParent: rootVC)

            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                vc.view.alpha = 1.0
                vc.view.transform = .identity
            }
            self.guiVC = vc
        }
    }

    public func present(in scene: UIWindowScene) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.windowScene = scene
            self.frame = scene.coordinateSpace.bounds
            self.isHidden = false
            self.makeKeyAndVisible()

            if let rootVC = self.rootViewController {
                rootVC.view.bringSubviewToFront(self.floatingButton)
            }
        }
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self.rootViewController?.view || hitView == self {
            return nil
        }
        return hitView
    }
}

class OverlayPassthroughViewController: UIViewController {
    override func loadView() {
        self.view = PassthroughView()
    }
}

class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
}
