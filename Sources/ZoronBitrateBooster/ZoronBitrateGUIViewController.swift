import UIKit

/**
 * ZoronBitrateGUIViewController - In-App Bitrate Studio & Visual Status Dashboard
 * Allows live confirmation that the dylib/framework is injected and active inside Alight Motion.
 */
public class ZoronBitrateGUIViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let blurCard = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let statusBadge = UIView()
    private let statusLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    private let segmentedPreset = UISegmentedControl(items: ["Extreme", "Ultra", "High", "Custom"])
    private let previewLabel = UILabel()
    private let bitrateControlsStack = UIStackView()
    private let bitrate1080pSlider = UISlider()
    private let bitrate1440pSlider = UISlider()
    private let bitrate4kSlider = UISlider()
    
    private let hevcSwitchContainer = UIView()
    private let hevcLabel = UILabel()
    private let hevcSwitch = UISwitch()
    
    private let hdrSwitchContainer = UIView()
    private let hdrLabel = UILabel()
    private let hdrSwitch = UISwitch()
    
    private let logHeaderLabel = UILabel()
    private let logTableView = UITableView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updatePresetPreview()
        
        ZoronBitrateTracker.shared.onLogUpdated = { [weak self] in
            self?.logTableView.reloadData()
            self?.updatePresetPreview()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Main Container Card
        blurCard.layer.cornerRadius = 24
        blurCard.clipsToBounds = true
        blurCard.layer.borderWidth = 1.0
        blurCard.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        blurCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurCard)
        
        let content = blurCard.contentView
        
        // Header
        titleLabel.text = "⚡ ZORON BITRATE STUDIO"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .black)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(titleLabel)
        
        subtitleLabel.text = "Alight Motion 4K/HQ Export Engine (H.264 & H.265)"
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        subtitleLabel.textColor = UIColor(white: 0.75, alpha: 1.0)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(subtitleLabel)
        
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(closeButton)
        
        // Status Badge
        statusBadge.backgroundColor = UIColor(red: 0.05, green: 0.8, blue: 0.4, alpha: 0.2)
        statusBadge.layer.cornerRadius = 8
        statusBadge.layer.borderWidth = 1
        statusBadge.layer.borderColor = UIColor(red: 0.05, green: 0.8, blue: 0.4, alpha: 0.6).cgColor
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(statusBadge)
        
        statusLabel.text = ZoronBitrateSwizzler.hasSwizzled ? "🟢 ENGINE ACTIVE: AVAssetWriter Hooked" : "🟡 STANDBY: Ready for Export"
        statusLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        statusLabel.textColor = UIColor(red: 0.3, green: 1.0, blue: 0.6, alpha: 1.0)
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusBadge.addSubview(statusLabel)
        
        // Preset Segmented Control
        segmentedPreset.selectedSegmentTintColor = UIColor(red: 0.85, green: 0.15, blue: 0.45, alpha: 1.0)
        segmentedPreset.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11, weight: .bold)], for: .selected)
        segmentedPreset.setTitleTextAttributes([.foregroundColor: UIColor(white: 0.7, alpha: 1.0), .font: UIFont.systemFont(ofSize: 11, weight: .semibold)], for: .normal)
        segmentedPreset.backgroundColor = UIColor(white: 0.15, alpha: 0.8)
        segmentedPreset.selectedSegmentIndex = presetToIndex(ZoronBitrateConfig.currentPreset)
        segmentedPreset.addTarget(self, action: #selector(presetChanged), for: .valueChanged)
        segmentedPreset.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(segmentedPreset)
        
        // Bitrate Preview Label
        previewLabel.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        previewLabel.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0)
        previewLabel.numberOfLines = 2
        previewLabel.textAlignment = .center
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(previewLabel)

        // Per-resolution controls apply to the Custom preset. Values are Mbps.
        bitrateControlsStack.axis = .vertical
        bitrateControlsStack.spacing = 5
        bitrateControlsStack.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(bitrateControlsStack)
        addBitrateSlider(title: "1080p", slider: bitrate1080pSlider, value: ZoronBitrateConfig.custom1080pMbps)
        addBitrateSlider(title: "1440p / 2K", slider: bitrate1440pSlider, value: ZoronBitrateConfig.custom1440pMbps)
        addBitrateSlider(title: "4K", slider: bitrate4kSlider, value: ZoronBitrateConfig.custom4kMbps)
        
        // Toggles Container
        setupToggleRow(container: hevcSwitchContainer, label: hevcLabel, switchCtrl: hevcSwitch, title: "Force H.265 / HEVC Output", isOn: ZoronBitrateConfig.forceHEVC, action: #selector(hevcToggled(_:)))
        setupToggleRow(container: hdrSwitchContainer, label: hdrLabel, switchCtrl: hdrSwitch, title: "Enable 10-bit HDR (Main10)", isOn: ZoronBitrateConfig.enable10BitHDR, action: #selector(hdrToggled(_:)))
        
        content.addSubview(hevcSwitchContainer)
        content.addSubview(hdrSwitchContainer)
        
        // Log Section Header
        logHeaderLabel.text = "📊 LIVE EXPORT LOGS (\(ZoronBitrateTracker.shared.totalInterceptedExports))"
        logHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        logHeaderLabel.textColor = UIColor(white: 0.9, alpha: 1.0)
        logHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(logHeaderLabel)
        
        // Log Table View
        logTableView.backgroundColor = UIColor(white: 0.1, alpha: 0.6)
        logTableView.layer.cornerRadius = 12
        logTableView.separatorColor = UIColor(white: 0.25, alpha: 0.6)
        logTableView.dataSource = self
        logTableView.delegate = self
        logTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LogCell")
        logTableView.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(logTableView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            blurCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blurCard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            blurCard.widthAnchor.constraint(equalToConstant: 350),
            blurCard.heightAnchor.constraint(equalToConstant: 650),
            
            titleLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),
            
            statusBadge.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            statusBadge.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            statusBadge.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            statusBadge.heightAnchor.constraint(equalToConstant: 26),
            
            statusLabel.centerXAnchor.constraint(equalTo: statusBadge.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: statusBadge.centerYAnchor),
            
            segmentedPreset.topAnchor.constraint(equalTo: statusBadge.bottomAnchor, constant: 12),
            segmentedPreset.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            segmentedPreset.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            segmentedPreset.heightAnchor.constraint(equalToConstant: 30),
            
            previewLabel.topAnchor.constraint(equalTo: segmentedPreset.bottomAnchor, constant: 8),
            previewLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            previewLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),

            bitrateControlsStack.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: 8),
            bitrateControlsStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            bitrateControlsStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            bitrateControlsStack.heightAnchor.constraint(equalToConstant: 92),
            
            hevcSwitchContainer.topAnchor.constraint(equalTo: bitrateControlsStack.bottomAnchor, constant: 8),
            hevcSwitchContainer.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            hevcSwitchContainer.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            hevcSwitchContainer.heightAnchor.constraint(equalToConstant: 34),
            
            hdrSwitchContainer.topAnchor.constraint(equalTo: hevcSwitchContainer.bottomAnchor, constant: 4),
            hdrSwitchContainer.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            hdrSwitchContainer.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            hdrSwitchContainer.heightAnchor.constraint(equalToConstant: 34),
            
            logHeaderLabel.topAnchor.constraint(equalTo: hdrSwitchContainer.bottomAnchor, constant: 12),
            logHeaderLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            
            logTableView.topAnchor.constraint(equalTo: logHeaderLabel.bottomAnchor, constant: 6),
            logTableView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            logTableView.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            logTableView.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -16)
        ])
    }

    private func addBitrateSlider(title: String, slider: UISlider, value: Double) {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8

        let label = UILabel()
        label.text = "\(title): \(Int(value.rounded())) Mbps"
        label.tag = 100
        label.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .semibold)
        label.textColor = .white
        label.widthAnchor.constraint(equalToConstant: 108).isActive = true

        slider.minimumValue = 1
        slider.maximumValue = 240
        slider.value = Float(value)
        slider.minimumTrackTintColor = UIColor(red: 0.85, green: 0.15, blue: 0.45, alpha: 1.0)
        slider.addTarget(self, action: #selector(bitrateSliderChanged(_:)), for: .valueChanged)

        row.addArrangedSubview(label)
        row.addArrangedSubview(slider)
        bitrateControlsStack.addArrangedSubview(row)
    }
    
    private func setupToggleRow(container: UIView, label: UILabel, switchCtrl: UISwitch, title: String, isOn: Bool, action: Selector) {
        container.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        switchCtrl.isOn = isOn
        switchCtrl.onTintColor = UIColor(red: 0.85, green: 0.15, blue: 0.45, alpha: 1.0)
        switchCtrl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        switchCtrl.addTarget(self, action: action, for: .valueChanged)
        switchCtrl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(switchCtrl)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            switchCtrl.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            switchCtrl.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
    
    private func presetToIndex(_ preset: ZoronBitratePreset) -> Int {
        switch preset {
        case .extreme: return 0
        case .ultra: return 1
        case .high: return 2
        case .custom: return 3
        }
    }
    
    private func updatePresetPreview() {
        let b4k = ZoronBitrateConfig.targetBitrate(forWidth: 3840, height: 2160) / 1_000_000
        let b1440 = ZoronBitrateConfig.targetBitrate(forWidth: 2560, height: 1440) / 1_000_000
        let b1080 = ZoronBitrateConfig.targetBitrate(forWidth: 1920, height: 1080) / 1_000_000
        previewLabel.text = "🎯 Targets: 4K: \(b4k) | 2K: \(b1440) | 1080p: \(b1080) Mbps"
        logHeaderLabel.text = "📊 LIVE EXPORT LOGS (\(ZoronBitrateTracker.shared.totalInterceptedExports))"
    }

    @objc private func bitrateSliderChanged(_ sender: UISlider) {
        let value = Double(sender.value.rounded())
        sender.value = Float(value)

        if sender === bitrate1080pSlider {
            ZoronBitrateConfig.custom1080pMbps = value
        } else if sender === bitrate1440pSlider {
            ZoronBitrateConfig.custom1440pMbps = value
        } else if sender === bitrate4kSlider {
            ZoronBitrateConfig.custom4kMbps = value
        }

        ZoronBitrateConfig.currentPreset = .custom
        segmentedPreset.selectedSegmentIndex = presetToIndex(.custom)

        if let label = sender.superview?.subviews.first(where: { $0.tag == 100 }) as? UILabel {
            let title = label.text?.split(separator: ":").first ?? "Bitrate"
            label.text = "\(title): \(Int(value)) Mbps"
        }
        updatePresetPreview()
    }
    
    @objc private func presetChanged() {
        switch segmentedPreset.selectedSegmentIndex {
        case 0: ZoronBitrateConfig.currentPreset = .extreme
        case 1: ZoronBitrateConfig.currentPreset = .ultra
        case 2: ZoronBitrateConfig.currentPreset = .high
        case 3: ZoronBitrateConfig.currentPreset = .custom
        default: break
        }
        updatePresetPreview()
    }
    
    @objc private func hevcToggled(_ sender: UISwitch) {
        ZoronBitrateConfig.forceHEVC = sender.isOn
    }
    
    @objc private func hdrToggled(_ sender: UISwitch) {
        ZoronBitrateConfig.enable10BitHDR = sender.isOn
    }
    
    @objc private func didTapClose() {
        ZoronOverlayWindow.shared.toggleMenu()
    }
    
    // TableView Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = ZoronBitrateTracker.shared.recentLogs.count
        return count == 0 ? 1 : count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let logs = ZoronBitrateTracker.shared.recentLogs
        if logs.isEmpty {
            cell.textLabel?.text = "No exports intercepted yet. Start an export!"
            cell.textLabel?.textColor = UIColor(white: 0.5, alpha: 1.0)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        } else {
            let item = logs[indexPath.row]
            cell.textLabel?.text = "[\(item.formattedDate)] \(item.resolution) (\(item.codec)) ➔ \(String(format: "%.1f", item.targetBitrateMbps)) Mbps 🚀"
            cell.textLabel?.textColor = UIColor(red: 0.4, green: 0.9, blue: 1.0, alpha: 1.0)
            cell.textLabel?.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .bold)
        }
        return cell
    }
}
