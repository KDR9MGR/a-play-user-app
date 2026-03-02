#!/bin/bash

# A Play - iOS Release Build Script
# Version: 0.1.0

set -e  # Exit on error

echo "🚀 A Play iOS Release Build Script v0.1.0"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: pubspec.yaml not found. Are you in the project root?${NC}"
    exit 1
fi

echo "📋 Step 1: Cleaning previous builds..."
flutter clean
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

echo "📦 Step 2: Getting dependencies..."
flutter pub get
echo -e "${GREEN}✓ Dependencies fetched${NC}"
echo ""

echo "🔨 Step 3: Generating Freezed code..."
flutter packages pub run build_runner build --delete-conflicting-outputs
echo -e "${GREEN}✓ Code generation complete${NC}"
echo ""

echo "🔍 Step 4: Running analyzer..."
flutter analyze
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Analysis passed${NC}"
else
    echo -e "${RED}✗ Analysis failed. Please fix errors before building.${NC}"
    exit 1
fi
echo ""

echo "📱 Step 5: Building iOS Release IPA..."
echo "This may take several minutes..."
flutter build ipa --release
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build successful!${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi
echo ""

echo "📍 Build Output Location:"
echo "   build/ios/ipa/a_play.ipa"
echo ""

echo "🎉 Build Complete!"
echo ""
echo "Next Steps:"
echo "1. Upload to App Store Connect using Transporter or Xcode"
echo "2. Review IOS_RELEASE_CHECKLIST.md for submission checklist"
echo "3. Test the IPA on physical device before submitting"
echo ""
echo "To open in Xcode for archiving:"
echo "   open ios/Runner.xcworkspace"
echo ""
