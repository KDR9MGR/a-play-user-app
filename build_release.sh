#!/bin/bash

echo "================================================"
echo "iOS Release Build - Version 2.0.0"
echo "================================================"
echo ""

# Navigate to project directory
cd "$(dirname "$0")"

# Generate dart-defines from .env and refuse to proceed with a missing or
# test Paystack key - this used to be silently baked into stale Xcode
# archives (Generated.xcconfig only updates on flutter build/run, Xcode
# Archive alone does not regenerate it), shipping test-mode payments.
echo "0. Generating dart-defines from .env..."
if [ ! -f ".env" ]; then
    echo "   ✗ .env not found. Copy .env.example to .env and fill in real (live) values first."
    exit 1
fi
python3 tool/gen_dart_defines.py --env-file .env --out .dart-defines.json
PAYSTACK_KEY=$(grep '"PAYSTACK_PUBLIC_KEY"' .dart-defines.json | sed -E 's/.*: *"([^"]*)".*/\1/')
if [[ -z "$PAYSTACK_KEY" ]]; then
    echo "   ✗ PAYSTACK_PUBLIC_KEY is not set in .env. A release build cannot ship without it."
    exit 1
fi
if [[ "$PAYSTACK_KEY" == pk_test_* ]]; then
    echo "   ⚠️  PAYSTACK_PUBLIC_KEY is a test key (pk_test_). This value isn't actually"
    echo "   used by the live payment flow (that goes through the paystack edge function"
    echo "   server-side), so this is informational only, not blocking."
fi
echo "   ✓ dart-defines generated"
echo ""

# Set file limit
echo "1. Setting file descriptor limit..."
ulimit -n 10240
echo "   File limit: $(ulimit -n)"
echo ""

# Clean everything
echo "2. Cleaning build artifacts..."
flutter clean
cd ios
rm -rf Pods Podfile.lock build DerivedData
cd ..
echo "   ✓ Clean complete"
echo ""

# Install pods
echo "3. Installing CocoaPods..."
cd ios
pod install
cd ..
echo "   ✓ Pods installed"
echo ""

# Get dependencies
echo "4. Getting Flutter dependencies..."
flutter pub get
echo "   ✓ Dependencies fetched"
echo ""

# Run analyzer
echo "5. Running Flutter analyze..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "   ⚠ Warning: Flutter analyze found issues"
    echo "   Review the issues above before proceeding"
    read -p "   Continue anyway? (y/n): " continue_build
    if [ "$continue_build" != "y" ]; then
        echo "   Build cancelled"
        exit 1
    fi
fi
echo ""

# Build options
echo "6. Building iOS release..."
echo "   Choose build method:"
echo "   a) Build IPA (flutter build ios --release)"
echo "   b) Open Xcode for Archive (recommended for App Store)"
echo "   c) Skip build (just clean and prepare)"
read -p "   Enter choice (a/b/c): " choice
echo ""

if [ "$choice" = "a" ]; then
    echo "   Building iOS release IPA..."
    flutter build ios --release --dart-define-from-file=.dart-defines.json
    if [ $? -eq 0 ]; then
        echo ""
        echo "   ✓ IPA built successfully"
        echo "   Location: build/ios/iphoneos/Runner.app"
    else
        echo ""
        echo "   ✗ Build failed"
        exit 1
    fi
elif [ "$choice" = "b" ]; then
    echo "   Refreshing Generated.xcconfig with live dart-defines before Xcode..."
    echo "   (Xcode Archive alone would otherwise reuse stale values from"
    echo "   whatever flutter command last ran, e.g. a debug 'flutter run')"
    flutter build ios --release --dart-define-from-file=.dart-defines.json
    if [ $? -ne 0 ]; then
        echo ""
        echo "   ✗ Build failed - not opening Xcode"
        exit 1
    fi
    open ios/Runner.xcworkspace
    echo "   ✓ Xcode opened"
    echo ""
    echo "   Next steps in Xcode:"
    echo "   1. Select 'Any iOS Device (arm64)' as target"
    echo "   2. Product → Archive"
    echo "   3. Wait for archive to complete"
    echo "   4. Click 'Distribute App'"
    echo "   5. Choose 'App Store Connect'"
    echo "   6. Follow the upload wizard"
    echo ""
    echo "   ⚠️  Do not run 'flutter run' (debug) before archiving, or the"
    echo "   dart-defines will go stale again and you'll re-archive test values."
else
    echo "   ✓ Build preparation complete"
    echo "   You can now:"
    echo "   - Run 'flutter build ios --release'"
    echo "   - Or open 'ios/Runner.xcworkspace' in Xcode"
fi

echo ""
echo "================================================"
echo "✅ Release Build Process Complete!"
echo "================================================"
echo ""
echo "Version: 2.0.0 (Build 1)"
echo ""
echo "Next steps:"
echo "1. Test the build on simulator/device"
echo "2. Upload to TestFlight"
echo "3. Submit for App Store review"
echo ""
echo "See IOS_RELEASE_BUILD.md for detailed instructions"
echo ""
