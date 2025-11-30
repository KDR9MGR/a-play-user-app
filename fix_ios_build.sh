#!/bin/bash

# Fix iOS Build Issues Script
# This script fixes common iOS build problems

set -e  # Exit on error

echo "🔧 Fixing iOS Build Issues..."
echo "=============================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: pubspec.yaml not found. Are you in the project root?${NC}"
    exit 1
fi

echo -e "${BLUE}Step 1: Cleaning Flutter build...${NC}"
flutter clean
echo -e "${GREEN}✓ Flutter cleaned${NC}"
echo ""

echo -e "${BLUE}Step 2: Getting Flutter dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies fetched${NC}"
echo ""

echo -e "${BLUE}Step 3: Generating Freezed models...${NC}"
flutter packages pub run build_runner build --delete-conflicting-outputs
echo -e "${GREEN}✓ Code generation complete${NC}"
echo ""

echo -e "${BLUE}Step 4: Cleaning iOS build cache...${NC}"
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies
echo -e "${GREEN}✓ iOS cache cleaned${NC}"
echo ""

echo -e "${BLUE}Step 5: Running pod deintegrate...${NC}"
pod deintegrate || echo -e "${YELLOW}⚠ No existing pods to remove${NC}"
echo ""

echo -e "${BLUE}Step 6: Installing CocoaPods dependencies...${NC}"
pod install --repo-update
echo -e "${GREEN}✓ Pods installed${NC}"
echo ""

cd ..

echo -e "${BLUE}Step 7: Verifying .env file...${NC}"
if [ -f ".env" ]; then
    echo -e "${GREEN}✓ .env file found${NC}"
else
    echo -e "${RED}✗ .env file missing!${NC}"
    echo "Creating .env file..."
    cat > .env << 'EOF'
SUPABASE_URL=https://yvnfhsipyfxdmulajbgl.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2bmZoc2lweWZ4ZG11bGFqYmdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NDUwNTgsImV4cCI6MjA2MzIyMTA1OH0.9mw2t1IKIHJkh30CdWcAfB2JhuJYdHQ_e_iHOZWcIqs
PAYSTACK_PUBLIC_KEY=pk_live_2185650de44c83c0fe00df70cbdf4bb3bb9b8f74
PAYSTACK_SECRET_KEY=sk_live_feb2476ad491d30a6b3cfc643080769d21724357
EOF
    echo -e "${GREEN}✓ .env file created${NC}"
fi
echo ""

echo -e "${BLUE}Step 8: Running Flutter analyze...${NC}"
flutter analyze
echo -e "${GREEN}✓ Analysis complete${NC}"
echo ""

echo -e "${GREEN}════════════════════════════════${NC}"
echo -e "${GREEN}✓ iOS build fix complete!${NC}"
echo -e "${GREEN}════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "1. Try running: flutter run"
echo "2. Or build for release: flutter build ios --release"
echo "3. Or open in Xcode: open ios/Runner.xcworkspace"
echo ""
