"""
ZoronBitrateBooster - Helper Injection Script
Assists in packaging and placing the framework into AE motion/Payload/AlightMotion.app/Frameworks
"""

import os
import shutil
import sys
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
PAYLOAD_FRAMEWORKS_DIR = BASE_DIR / "AE motion" / "Payload" / "AlightMotion.app" / "Frameworks"
FRAMEWORK_SOURCE = BASE_DIR / "ZoronBitrateBooster-iOS-Framework" / "ZoronBitrateBooster.framework"

def main():
    print("=" * 60)
    print("🚀 Zoron Bitrate Booster: Payload Injection Helper")
    print("=" * 60)
    
    if not PAYLOAD_FRAMEWORKS_DIR.exists():
        print(f"⚠️ Target Frameworks directory not found at: {PAYLOAD_FRAMEWORKS_DIR}")
        print("Please ensure 'AE motion/Payload/AlightMotion.app' exists.")
        return 1
        
    print(f"✅ Found Alight Motion Frameworks target: {PAYLOAD_FRAMEWORKS_DIR}")
    
    # Destination framework path
    dest_path = PAYLOAD_FRAMEWORKS_DIR / "ZoronBitrateBooster.framework"
    
    if FRAMEWORK_SOURCE.exists():
        print(f"📦 Copying compiled framework from {FRAMEWORK_SOURCE}...")
        if dest_path.exists():
            shutil.rmtree(dest_path)
        shutil.copytree(FRAMEWORK_SOURCE, dest_path)
        print("✅ Successfully installed ZoronBitrateBooster.framework into AlightMotion.app/Frameworks!")
    else:
        print(f"ℹ️ Pre-compiled framework not yet located at: {FRAMEWORK_SOURCE}")
        print("You can build it via GitHub Actions (.github/workflows/build-ios-framework.yml)")
        print("or Sideloadly using the standalone .dylib/.framework.")
        
    print("\n🎉 Injection helper process completed.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
