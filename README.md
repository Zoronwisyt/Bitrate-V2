# 🚀 ZoronBitrateBooster: Ultra-High Bitrate 4K / HQ Exporter for Alight Motion

**ZoronBitrateBooster** is an iOS dynamic framework (`.framework`) and dynamic library (`.dylib`) designed to boost video export bitrates in **Alight Motion** for both **H.264 (AVC)** and **H.265 (HEVC)** codecs up to **180+ Mbps**.

It features an **In-App GUI Overlay** (draggable neon floating badge) that lets you confirm injection, switch bitrate presets in real-time, toggle HEVC / 10-bit HDR Main10 profiles, and monitor live exports.

---

## ⚡ Features

- 🎥 **Dual Codec Boost**: Intercepts and upgrades both **H.264 (High Profile AutoLevel)** and **H.265 (HEVC Main & Main10 10-bit HDR)** exports.
- 🎯 **Extreme Bitrate Targets**:
  - **4K UHD (3840x2160)**: Up to **180 Mbps** (Stock is ~35-45 Mbps)
  - **1440p 2K (2560x1440)**: Up to **120 Mbps** (Stock is ~20 Mbps)
  - **1080p FHD (1920x1080)**: Up to **85 Mbps** (Stock is ~12-16 Mbps)
  - **720p HD (1280x720)**: Up to **50 Mbps** (Stock is ~8 Mbps)
- 🖥️ **Live In-App GUI**:
  - Draggable `⚡4K` floating neon badge with touch passthrough.
  - Visual status indicator (`🟢 ENGINE ACTIVE: AVAssetWriter Hooked`).
  - Real-time preset switcher (Extreme, Ultra, High, Custom Multiplier).
  - Live export tracker displaying resolution, codec, and actual output Mbps.
- 🛡️ **Zero Crash Architecture**: Pure Objective-C runtime method swapping (`method_setImplementation`) with native C-level function pointers.
- 🚀 **Auto-Initializing**: Automatically activates via global constructor upon dylib load (`+load` / `_autoInitTrigger`).

---

## 📲 How to Install & Inject with Sideloadly

### Option 1: Sideloadly Dylib / Tweak Injection (Easiest)

1. Open **Sideloadly** on your PC or Mac and connect your iOS device.
2. Drag & drop your **Alight Motion `.ipa`** (or select the decrypted IPA from `AE motion/Payload`).
3. Click **"Advanced Options"** at the bottom of Sideloadly.
4. In the **"Tweak injection"** section:
   - Click the **`+`** button or drag **`ZoronBitrateBooster.dylib`** (or `ZoronBitrateBooster.framework`) into the box.
   - Set Injection mode to **Cydia Substrate / Substitute** or **Insert Dylib**.
5. Enter your Apple ID and click **Start**.
6. Once installed, open Alight Motion: you will see the **`⚡4K`** floating neon badge appear on screen confirming the booster is loaded and active!

---

### Option 2: TrollStore / Esign / Feather / Scarlet

- **TrollStore**: Install the IPA, or use TrollStore's inject tweak feature.
- **Esign / Feather**: 
  1. Import Alight Motion `.ipa`.
  2. Tap **Signature -> More Settings -> Add Dylib / Framework**.
  3. Select `ZoronBitrateBooster.dylib` or `ZoronBitrateBooster.framework`.
  4. Sign and install!

---

### Option 3: Direct Payload Injection

You can place `ZoronBitrateBooster.framework` into the app bundle directly:
```
AlightMotion.app/Frameworks/ZoronBitrateBooster.framework
```
And use `opool` or `insert_dylib` to add `@rpath/ZoronBitrateBooster.framework/ZoronBitrateBooster` to `AlightMotion.app/AlightMotion`.

---

## 🛠️ GitHub Actions Automated Build

This repository includes a fully automated GitHub Actions workflow (`.github/workflows/build-ios-framework.yml`):

1. Push your repository to GitHub (or click **Run workflow** under the **Actions** tab).
2. The workflow will automatically compile the Swift code on `macos-14` using the official iOS SDK (`arm64-apple-ios15.0`).
3. Under **Workflow Artifacts**, download:
   - `ZoronBitrateBooster-iOS-Framework.zip` (Standard iOS `.framework`)
   - `ZoronBitrateBooster-iOS-Dylib.zip` (Standalone `.dylib`)

---

## 🏗️ Building Locally with Swift CLI / XcodeGen

### macOS Terminal:
```bash
xcrun --sdk iphoneos swiftc -target arm64-apple-ios15.0 \
  -emit-library \
  -emit-module \
  -module-name ZoronBitrateBooster \
  -O \
  Sources/ZoronBitrateBooster/*.swift \
  -o ZoronBitrateBooster.dylib
```

### XcodeGen:
```bash
xcodegen generate
xcodebuild -project ZoronBitrateBooster.xcodeproj -scheme ZoronBitrateBooster -configuration Release -sdk iphoneos
```

---

## 📊 Preset Matrix

| Preset | 4K UHD (bps) | 1440p 2K (bps) | 1080p FHD (bps) | 720p HD (bps) |
|---|---|---|---|---|
| **Extreme Studio** | 180 Mbps | 120 Mbps | 85 Mbps | 50 Mbps |
| **Ultra HD** | 120 Mbps | 85 Mbps | 65 Mbps | 35 Mbps |
| **High Quality** | 80 Mbps | 55 Mbps | 40 Mbps | 25 Mbps |
| **Custom** | *35 Mbps × Multiplier* | *20 Mbps × Multiplier* | *14 Mbps × Multiplier* | *8 Mbps × Multiplier* |
