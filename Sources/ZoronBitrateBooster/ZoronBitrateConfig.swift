import Foundation
import AVFoundation

/**
 * ZoronBitrateConfig - Ultra-High Quality Bitrate Targets & Encoding Presets
 * Supports dynamic configuration via GUI and persistent user preferences.
 */
public enum ZoronBitratePreset: String, CaseIterable {
    case extreme = "Extreme Studio (150-180 Mbps)"
    case ultra = "Ultra HD (85-120 Mbps)"
    case high = "High Quality (50-70 Mbps)"
    case custom = "Custom Multiplier"
}

public struct ZoronBitrateConfig {
    
    private static let presetKey = "zoron_bitrate_preset"
    private static let customMultiplierKey = "zoron_bitrate_multiplier"
    private static let custom1080pMbpsKey = "zoron_bitrate_custom_1080p_mbps"
    private static let custom1440pMbpsKey = "zoron_bitrate_custom_1440p_mbps"
    private static let custom4kMbpsKey = "zoron_bitrate_custom_4k_mbps"
    private static let forceHevcKey = "zoron_bitrate_force_hevc"
    private static let enable10BitHdrKey = "zoron_bitrate_enable_10bit"
    
    // Default Preset: Extreme
    public static var currentPreset: ZoronBitratePreset {
        get {
            if let saved = UserDefaults.standard.string(forKey: presetKey),
               let preset = ZoronBitratePreset(rawValue: saved) {
                return preset
            }
            return .extreme
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: presetKey)
        }
    }
    
    // Custom Multiplier (e.g., 2.0x to 6.0x)
    public static var customMultiplier: Double {
        get {
            let val = UserDefaults.standard.double(forKey: customMultiplierKey)
            return val > 0 ? val : 3.5
        }
        set {
            UserDefaults.standard.set(newValue, forKey: customMultiplierKey)
        }
    }

    // Resolution-specific custom targets. These are used when the Custom preset
    // is selected and stored in the host application's UserDefaults suite.
    public static var custom1080pMbps: Double {
        get { storedMbps(forKey: custom1080pMbpsKey, defaultValue: 85.0) }
        set { UserDefaults.standard.set(clampedMbps(newValue), forKey: custom1080pMbpsKey) }
    }

    public static var custom1440pMbps: Double {
        get { storedMbps(forKey: custom1440pMbpsKey, defaultValue: 120.0) }
        set { UserDefaults.standard.set(clampedMbps(newValue), forKey: custom1440pMbpsKey) }
    }

    public static var custom4kMbps: Double {
        get { storedMbps(forKey: custom4kMbpsKey, defaultValue: 180.0) }
        set { UserDefaults.standard.set(clampedMbps(newValue), forKey: custom4kMbpsKey) }
    }
    
    // Force HEVC conversion if requested
    public static var forceHEVC: Bool {
        get {
            return UserDefaults.standard.bool(forKey: forceHevcKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: forceHevcKey)
        }
    }
    
    // Enable 10-bit HDR for HEVC
    public static var enable10BitHDR: Bool {
        get {
            return UserDefaults.standard.object(forKey: enable10BitHdrKey) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: enable10BitHdrKey)
        }
    }

    // Calculates target bitrate in bits per second (bps)
    public static func targetBitrate(forWidth width: Int, height: Int, fps: Float = 60.0) -> Int {
        let maxDim = max(width, height)
        let baseBps: Int
        
        switch currentPreset {
        case .extreme:
            if maxDim >= 3840 {
                baseBps = 180_000_000 // 180 Mbps for 4K
            } else if maxDim >= 2560 {
                baseBps = 120_000_000 // 120 Mbps for 1440p / 2K
            } else if maxDim >= 1920 {
                baseBps = 85_000_000  // 85 Mbps for 1080p
            } else {
                baseBps = 50_000_000  // 50 Mbps for 720p / lower
            }
            
        case .ultra:
            if maxDim >= 3840 {
                baseBps = 120_000_000 // 120 Mbps for 4K
            } else if maxDim >= 2560 {
                baseBps = 85_000_000  // 85 Mbps for 1440p
            } else if maxDim >= 1920 {
                baseBps = 65_000_000  // 65 Mbps for 1080p
            } else {
                baseBps = 35_000_000  // 35 Mbps for 720p
            }
            
        case .high:
            if maxDim >= 3840 {
                baseBps = 80_000_000  // 80 Mbps for 4K
            } else if maxDim >= 2560 {
                baseBps = 55_000_000  // 55 Mbps for 1440p
            } else if maxDim >= 1920 {
                baseBps = 40_000_000  // 40 Mbps for 1080p
            } else {
                baseBps = 25_000_000  // 25 Mbps for 720p
            }
            
        case .custom:
            if maxDim >= 3840 {
                return mbpsToBps(custom4kMbps)
            } else if maxDim >= 2560 {
                return mbpsToBps(custom1440pMbps)
            } else if maxDim >= 1920 {
                return mbpsToBps(custom1080pMbps)
            } else {
                // Keep the existing multiplier behavior for 720p and lower.
                return Int(8_000_000.0 * customMultiplier)
            }
        }
        
        // Dynamic Framerate Compensation (scale up slightly for 60fps / 120fps)
        if fps > 30.0 {
            let fpsScale = min(Double(fps) / 30.0, 1.35)
            return Int(Double(baseBps) * fpsScale)
        }
        return baseBps
    }

    private static func storedMbps(forKey key: String, defaultValue: Double) -> Double {
        let saved = UserDefaults.standard.double(forKey: key)
        return saved > 0 ? clampedMbps(saved) : defaultValue
    }

    private static func clampedMbps(_ value: Double) -> Double {
        min(max(value, 1.0), 240.0)
    }

    private static func mbpsToBps(_ mbps: Double) -> Int {
        Int((clampedMbps(mbps) * 1_000_000.0).rounded())
    }
}
