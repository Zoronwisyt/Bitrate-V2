import Foundation
import AVFoundation
import ObjectiveC
import VideoToolbox

/**
 * ZoronBitrateSwizzler - High-Performance AVAssetWriterInput & VideoToolbox Interceptor
 * Intercepts video compression settings for both H.264 (AVC) and H.265 (HEVC).
 */
public struct ExportLogItem: Identifiable {
    public let id = UUID()
    public let timestamp: Date
    public let resolution: String
    public let codec: String
    public let targetBitrateMbps: Double
    public let formattedDate: String
}

typealias InitFunction = @convention(c) (AnyObject, Selector, AVMediaType, [String: Any]?, CMFormatDescription?) -> AnyObject

private var originalInitFunction: InitFunction?

@_cdecl("zoron_custom_init")
func zoron_custom_init(_ selfObj: AnyObject, _ _cmd: Selector, _ mediaType: AVMediaType, _ outputSettings: [String: Any]?, _ formatHint: CMFormatDescription?) -> AnyObject {
    guard mediaType == .video, var settings = outputSettings else {
        if let original = originalInitFunction {
            return original(selfObj, _cmd, mediaType, outputSettings, formatHint)
        }
        return selfObj
    }

    // Extract resolution and framerate parameters
    let width = (settings[AVVideoWidthKey] as? NSNumber)?.intValue ?? 1920
    let height = (settings[AVVideoHeightKey] as? NSNumber)?.intValue ?? 1080
    
    // Extract existing codec or force HEVC if enabled
    var codec = (settings[AVVideoCodecKey] as? AVVideoCodecType) ?? .h264
    if ZoronBitrateConfig.forceHEVC {
        if #available(iOS 11.0, *) {
            codec = .hevc
            settings[AVVideoCodecKey] = AVVideoCodecType.hevc
        }
    }

    let targetBps = ZoronBitrateConfig.targetBitrate(forWidth: width, height: height, fps: 60.0)

    // Build enhanced compression properties
    var compressionProps = (settings[AVVideoCompressionPropertiesKey] as? [String: Any]) ?? [:]
    compressionProps[AVVideoAverageBitRateKey] = NSNumber(value: targetBps)
    compressionProps[AVVideoQualityKey] = NSNumber(value: 1.0)
    compressionProps[AVVideoAllowFrameReorderingKey] = NSNumber(value: true)
    compressionProps[AVVideoMaxKeyFrameIntervalKey] = NSNumber(value: 30) // Clean GOP structure
    
    var codecDisplay = "H.264 (AVC)"
    if codec == .h264 {
        compressionProps[AVVideoProfileLevelKey] = AVVideoProfileLevelH264HighAutoLevel
        codecDisplay = "H.264 High Profile"
    } else if #available(iOS 11.0, *), codec == .hevc {
        if ZoronBitrateConfig.enable10BitHDR {
            compressionProps[AVVideoProfileLevelKey] = "HEVC_Main10_AutoLevel"
            codecDisplay = "H.265 / HEVC Main10 (10-bit)"
        } else {
            compressionProps[AVVideoProfileLevelKey] = "HEVC_Main_AutoLevel"
            codecDisplay = "H.265 / HEVC Main"
        }
    }

    settings[AVVideoCompressionPropertiesKey] = compressionProps

    let mbps = Double(targetBps) / 1_000_000.0
    print("[ZoronBitrateBooster] 🚀 Intercepted Export: \(width)x\(height) | Codec: \(codecDisplay) | Boosted Target: \(String(format: "%.1f", mbps)) Mbps")

    // Record to In-App GUI History
    ZoronBitrateTracker.shared.recordExport(
        resolution: "\(width)x\(height)",
        codec: codecDisplay,
        bitrateMbps: mbps
    )

    if let original = originalInitFunction {
        return original(selfObj, _cmd, mediaType, settings, formatHint)
    }
    return selfObj
}

public class ZoronBitrateTracker: NSObject {
    public static let shared = ZoronBitrateTracker()
    
    public private(set) var totalInterceptedExports: Int = 0
    public private(set) var recentLogs: [ExportLogItem] = []
    public var onLogUpdated: (() -> Void)?
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        return df
    }()
    
    public func recordExport(resolution: String, codec: String, bitrateMbps: Double) {
        DispatchQueue.main.async {
            self.totalInterceptedExports += 1
            let log = ExportLogItem(
                timestamp: Date(),
                resolution: resolution,
                codec: codec,
                targetBitrateMbps: bitrateMbps,
                formattedDate: self.dateFormatter.string(from: Date())
            )
            self.recentLogs.insert(log, at: 0)
            if self.recentLogs.count > 20 {
                self.recentLogs.removeLast()
            }
            self.onLogUpdated?()
        }
    }
}

public class ZoronBitrateSwizzler: NSObject {

    public private(set) static var hasSwizzled = false

    public static func enableBooster() {
        guard !hasSwizzled else { return }
        hasSwizzled = true

        let cls: AnyClass = AVAssetWriterInput.self
        let sel = #selector(AVAssetWriterInput.init(mediaType:outputSettings:sourceFormatHint:))

        guard let method = class_getInstanceMethod(cls, sel) else {
            print("[ZoronBitrateBooster] ⚠️ Failed to find AVAssetWriterInput selector.")
            return
        }

        let customFunction: InitFunction = zoron_custom_init
        let swizzledIMP: IMP = unsafeBitCast(customFunction, to: IMP.self)
        let previousIMP: IMP = method_setImplementation(method, swizzledIMP)

        originalInitFunction = unsafeBitCast(previousIMP, to: InitFunction.self)
        print("[ZoronBitrateBooster] ⚡ AVFoundation Bitrate Engine Hooked & Active (H.264 & H.265 Ready)!")
    }
}
