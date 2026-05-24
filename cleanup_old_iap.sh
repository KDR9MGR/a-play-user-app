#!/bin/bash

# Cleanup script for old IAP implementation
# Run this AFTER testing the new implementation successfully

echo "════════════════════════════════════════"
echo "  IAP Cleanup Script"
echo "════════════════════════════════════════"
echo ""
echo "This will delete the following old files:"
echo ""
echo "IAP Services:"
echo "  ❌ lib/core/services/purchase_manager.dart"
echo "  ❌ lib/features/subscription/service/apple_iap_service.dart"
echo ""
echo "Documentation:"
echo "  ❌ APPLE_IAP_DIAGNOSIS.md"
echo "  ❌ IAP_PENDING_STATUS_FIX.md"
echo "  ❌ IAP_PENDING_DIAGNOSIS_FINAL.md"
echo ""
echo "⚠️  WARNING: This action cannot be undone!"
echo "   Make sure the new implementation works before proceeding."
echo ""
read -p "Continue with deletion? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Deleting old files..."
echo ""

# Delete old IAP service files
if [ -f "lib/core/services/purchase_manager.dart" ]; then
    rm "lib/core/services/purchase_manager.dart"
    echo "✓ Deleted: lib/core/services/purchase_manager.dart"
else
    echo "⚠ Not found: lib/core/services/purchase_manager.dart"
fi

if [ -f "lib/features/subscription/service/apple_iap_service.dart" ]; then
    rm "lib/features/subscription/service/apple_iap_service.dart"
    echo "✓ Deleted: lib/features/subscription/service/apple_iap_service.dart"
else
    echo "⚠ Not found: lib/features/subscription/service/apple_iap_service.dart"
fi

# Delete old documentation
if [ -f "APPLE_IAP_DIAGNOSIS.md" ]; then
    rm "APPLE_IAP_DIAGNOSIS.md"
    echo "✓ Deleted: APPLE_IAP_DIAGNOSIS.md"
else
    echo "⚠ Not found: APPLE_IAP_DIAGNOSIS.md"
fi

if [ -f "IAP_PENDING_STATUS_FIX.md" ]; then
    rm "IAP_PENDING_STATUS_FIX.md"
    echo "✓ Deleted: IAP_PENDING_STATUS_FIX.md"
else
    echo "⚠ Not found: IAP_PENDING_STATUS_FIX.md"
fi

if [ -f "IAP_PENDING_DIAGNOSIS_FINAL.md" ]; then
    rm "IAP_PENDING_DIAGNOSIS_FINAL.md"
    echo "✓ Deleted: IAP_PENDING_DIAGNOSIS_FINAL.md"
else
    echo "⚠ Not found: IAP_PENDING_DIAGNOSIS_FINAL.md"
fi

echo ""
echo "════════════════════════════════════════"
echo "  Cleanup Complete!"
echo "════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "1. Run 'flutter clean' in Windows terminal"
echo "2. Run 'flutter pub get'"
echo "3. Run 'flutter analyze' to check for errors"
echo "4. Rebuild and test the app"
echo ""
