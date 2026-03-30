#!/bin/bash

# iOS Rebuild Script - Fix PhaseScriptExecution and "Too many open files" errors
# This script performs a complete clean rebuild of the iOS app

echo "================================================"
echo "iOS Clean Rebuild Script"
echo "================================================"
echo ""

# Step 1: Increase file descriptor limit
echo "Step 1: Increasing file descriptor limit..."
ulimit -n 10240
echo "✓ File limit set to: $(ulimit -n)"
echo ""

# Step 2: Navigate to project directory
cd "$(dirname "$0")"
echo "Step 2: Working directory: $(pwd)"
echo ""

# Step 3: Clean Flutter build
echo "Step 3: Cleaning Flutter build artifacts..."
flutter clean
echo "✓ Flutter clean complete"
echo ""

# Step 4: Remove iOS build artifacts
echo "Step 4: Removing iOS build artifacts..."
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf build
rm -rf DerivedData
echo "✓ iOS artifacts removed"
echo ""

# Step 5: Clean Xcode derived data
echo "Step 5: Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "✓ Xcode derived data cleaned"
echo ""

# Step 6: Deintegrate CocoaPods
echo "Step 6: Deintegrating CocoaPods..."
pod deintegrate
echo "✓ Pods deintegrated"
echo ""

# Step 7: Install CocoaPods dependencies
echo "Step 7: Installing CocoaPods dependencies..."
pod install
if [ $? -ne 0 ]; then
    echo "⚠ Pod install failed, trying with repo update..."
    pod repo update
    pod install
fi
echo "✓ Pods installed"
echo ""

# Step 8: Go back to project root
cd ..
echo "Step 8: Back to project root"
echo ""

# Step 9: Get Flutter dependencies
echo "Step 9: Getting Flutter dependencies..."
flutter pub get
echo "✓ Flutter dependencies fetched"
echo ""

# Step 10: Run Flutter doctor
echo "Step 10: Running Flutter doctor..."
flutter doctor
echo ""

# Step 11: List available simulators
echo "Step 11: Available iOS simulators:"
xcrun simctl list devices available | grep "iPhone"
echo ""

echo "================================================"
echo "✅ Rebuild complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Run: flutter run"
echo "2. Or open in Xcode: open ios/Runner.xcworkspace"
echo ""
