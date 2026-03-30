#!/bin/bash

echo "================================================"
echo "iOS Release Build - Version 2.0.0"
echo "================================================"
echo ""

# Navigate to project directory
cd "$(dirname "$0")"

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
    flutter build ios --release
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
