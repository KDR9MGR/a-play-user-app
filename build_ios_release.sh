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

echo "🔑 Step 0: Generating dart-defines from .env..."
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env not found. Copy .env.example to .env and fill in real (live) values first.${NC}"
    exit 1
fi
python3 tool/gen_dart_defines.py --env-file .env --out .dart-defines.json

PAYSTACK_KEY=$(grep '"PAYSTACK_PUBLIC_KEY"' .dart-defines.json | sed -E 's/.*: *"([^"]*)".*/\1/')
if [[ -z "$PAYSTACK_KEY" ]]; then
    echo -e "${RED}Error: PAYSTACK_PUBLIC_KEY is not set in .env. A release build cannot ship without it.${NC}"
    exit 1
fi
if [[ "$PAYSTACK_KEY" == pk_test_* ]]; then
    echo -e "${YELLOW}⚠️  PAYSTACK_PUBLIC_KEY is a test key (pk_test_). This value isn't actually${NC}"
    echo -e "${YELLOW}   used by the live payment flow (that goes through the paystack edge${NC}"
    echo -e "${YELLOW}   function server-side), so this is informational only, not blocking.${NC}"
    echo ""
fi
echo -e "${GREEN}✓ dart-defines generated with a live Paystack key${NC}"
echo ""

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
flutter build ipa --release --dart-define-from-file=.dart-defines.json
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
echo -e "${YELLOW}⚠️  Important: Xcode Archive reuses whatever dart-defines were last"
echo -e "   written to ios/Flutter/Generated.xcconfig by a flutter build/run"
echo -e "   command - it does NOT regenerate them itself. Archive right after"
echo -e "   this script (which just set them correctly) and don't run"
echo -e "   'flutter run' (debug/test key) in between, or you'll silently"
echo -e "   re-archive with stale/test values again.${NC}"
echo ""
