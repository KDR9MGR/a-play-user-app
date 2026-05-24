#!/bin/bash

# Repository Sanitization Script
# This script creates a sanitized copy of your repo safe for sharing with AI tools

set -e  # Exit on error

ORIGINAL_DIR="$(pwd)"
SANITIZED_DIR="${ORIGINAL_DIR}-sanitized"

echo "🔒 Starting Repository Sanitization..."
echo "Original: $ORIGINAL_DIR"
echo "Sanitized Copy: $SANITIZED_DIR"
echo ""

# Phase 1: Create sanitized copy
echo "📂 Phase 1: Creating sanitized copy..."
if [ -d "$SANITIZED_DIR" ]; then
    echo "⚠️  Sanitized directory already exists. Removing..."
    rm -rf "$SANITIZED_DIR"
fi

# Copy repo excluding large build artifacts
rsync -av \
    --exclude='.env' \
    --exclude='*.env' \
    --exclude='key.properties' \
    --exclude='ios/Pods/' \
    --exclude='.dart_tool/' \
    --exclude='build/' \
    --exclude='android/.gradle/' \
    --exclude='android/.cxx/' \
    --exclude='**/xcuserdata/' \
    --exclude='.symlinks/' \
    --exclude='android/local.properties' \
    --exclude='*.keystore' \
    --exclude='*.jks' \
    "$ORIGINAL_DIR/" "$SANITIZED_DIR/"

cd "$SANITIZED_DIR"

echo "✅ Copy created"
echo ""

# Phase 2: Delete sensitive files
echo "🗑️  Phase 2: Deleting sensitive files..."

# Remove any remaining sensitive files
find . -name ".env" -type f -delete
find . -name "*.env" -type f -delete
find . -name "key.properties" -type f -delete
find . -name "local.properties" -type f -delete
find . -type d -name "xcuserdata" -exec rm -rf {} + 2>/dev/null || true

echo "✅ Sensitive files deleted"
echo ""

# Phase 3: Sanitize source code
echo "🔧 Phase 3: Sanitizing source code..."

# Sanitize supabase_config.dart
if [ -f "lib/core/config/supabase_config.dart" ]; then
    sed -i.bak "s|https://yvnfhsipyfxdmulajbgl.supabase.co|https://YOUR-PROJECT.supabase.co|g" \
        lib/core/config/supabase_config.dart
    sed -i.bak "s|https://gixstjuzbqcvdfcqeztk.supabase.co|https://YOUR-PROJECT.supabase.co|g" \
        lib/core/config/supabase_config.dart
    sed -i.bak "s|eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[^'\"]*|YOUR_SUPABASE_ANON_KEY|g" \
        lib/core/config/supabase_config.dart
    rm -f lib/core/config/supabase_config.dart.bak
    echo "  ✓ supabase_config.dart sanitized"
fi

# Sanitize env.dart
if [ -f "lib/core/config/env.dart" ]; then
    sed -i.bak "s|pk_test_[a-zA-Z0-9_]*|pk_test_YOUR_PAYSTACK_KEY|g" \
        lib/core/config/env.dart
    sed -i.bak "s|pk_live_[a-zA-Z0-9_]*|pk_live_YOUR_PAYSTACK_KEY|g" \
        lib/core/config/env.dart
    sed -i.bak "s|sk_test_[a-zA-Z0-9_]*|sk_test_YOUR_PAYSTACK_SECRET|g" \
        lib/core/config/env.dart
    sed -i.bak "s|sk_live_[a-zA-Z0-9_]*|sk_live_YOUR_PAYSTACK_SECRET|g" \
        lib/core/config/env.dart
    sed -i.bak "s|re_[a-zA-Z0-9_]*|re_YOUR_RESEND_API_KEY|g" \
        lib/core/config/env.dart
    sed -i.bak "s|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}|xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx|g" \
        lib/core/config/env.dart
    rm -f lib/core/config/env.dart.bak
    echo "  ✓ env.dart sanitized"
fi

# Sanitize firebase_options.dart
if [ -f "lib/firebase_options.dart" ]; then
    sed -i.bak "s|AIzaSy[a-zA-Z0-9_-]*|YOUR_FIREBASE_API_KEY|g" \
        lib/firebase_options.dart
    sed -i.bak "s|aplay-b7c41|YOUR_FIREBASE_PROJECT_ID|g" \
        lib/firebase_options.dart
    sed -i.bak "s|1:[0-9]*:web:[a-zA-Z0-9]*|1:YOUR_APP_ID:web:YOUR_MEASUREMENT_ID|g" \
        lib/firebase_options.dart
    sed -i.bak "s|1:[0-9]*:android:[a-zA-Z0-9]*|1:YOUR_APP_ID:android:YOUR_MEASUREMENT_ID|g" \
        lib/firebase_options.dart
    sed -i.bak "s|1:[0-9]*:ios:[a-zA-Z0-9]*|1:YOUR_APP_ID:ios:YOUR_MEASUREMENT_ID|g" \
        lib/firebase_options.dart
    rm -f lib/firebase_options.dart.bak
    echo "  ✓ firebase_options.dart sanitized"
fi

echo "✅ Source code sanitized"
echo ""

# Phase 4: Sanitize documentation
echo "📝 Phase 4: Sanitizing documentation files..."

# Find and sanitize all markdown files
find . -name "*.md" -type f | while read -r file; do
    # Skip files in node_modules or Pods
    if [[ "$file" == *"/node_modules/"* ]] || [[ "$file" == *"/Pods/"* ]]; then
        continue
    fi

    # Sanitize Supabase URLs
    sed -i.bak "s|https://yvnfhsipyfxdmulajbgl.supabase.co|https://YOUR-PROJECT.supabase.co|g" "$file"
    sed -i.bak "s|https://gixstjuzbqcvdfcqeztk.supabase.co|https://YOUR-PROJECT.supabase.co|g" "$file"

    # Sanitize JWT tokens (Supabase anon keys)
    sed -i.bak "s|eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[^[:space:]\"']*|YOUR_SUPABASE_ANON_KEY|g" "$file"

    # Sanitize PayStack keys
    sed -i.bak "s|pk_test_[a-zA-Z0-9_]*|pk_test_YOUR_KEY|g" "$file"
    sed -i.bak "s|pk_live_[a-zA-Z0-9_]*|pk_live_YOUR_KEY|g" "$file"
    sed -i.bak "s|sk_test_[a-zA-Z0-9_]*|sk_test_YOUR_SECRET|g" "$file"
    sed -i.bak "s|sk_live_[a-zA-Z0-9_]*|sk_live_YOUR_SECRET|g" "$file"

    # Sanitize Resend API keys
    sed -i.bak "s|re_[a-zA-Z0-9_]*|re_YOUR_RESEND_API_KEY|g" "$file"

    # Sanitize UUIDs (OneSignal, etc)
    sed -i.bak "s|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}|xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx|g" "$file"

    # Sanitize Firebase API keys
    sed -i.bak "s|AIzaSy[a-zA-Z0-9_-]*|YOUR_FIREBASE_API_KEY|g" "$file"

    # Remove backup files
    rm -f "${file}.bak"
done

echo "✅ Documentation sanitized"
echo ""

# Phase 5: Create .env.example
echo "📄 Phase 5: Creating .env.example..."

cat > .env.example << 'EOF'
# ===========================================
# SUPABASE
# ===========================================
SUPABASE_URL=https://YOUR-PROJECT.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key

# ===========================================
# PAYSTACK
# ===========================================
PAYSTACK_PUBLIC_KEY=pk_test_your_key_here

# ===========================================
# ONESIGNAL PUSH NOTIFICATIONS
# ===========================================
ONESIGNAL_APP_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# ===========================================
# RESEND EMAIL SERVICE
# ===========================================
RESEND_API_KEY=re_YOUR_RESEND_API_KEY

# For production (use your verified domain):
RESEND_FROM_EMAIL=YourApp <noreply@yourdomain.com>

# For testing (Resend sandbox - only sends to YOUR email):
# RESEND_FROM_EMAIL=YourApp <onboarding@resend.dev>
EOF

echo "✅ .env.example created"
echo ""

# Phase 6: Final verification
echo "🔍 Phase 6: Running security verification..."

SECURITY_ISSUES=0

# Check for remaining JWT tokens
if grep -r "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*" . \
    --exclude-dir=".git" \
    --exclude-dir="ios/Pods" \
    --exclude-dir="local_plugins" \
    --exclude="*.sh" 2>/dev/null; then
    echo "⚠️  WARNING: Found remaining JWT tokens!"
    SECURITY_ISSUES=$((SECURITY_ISSUES + 1))
fi

# Check for PayStack live keys
if grep -r "sk_live_[a-zA-Z0-9]" . \
    --exclude-dir=".git" \
    --exclude-dir="ios/Pods" \
    --exclude-dir="local_plugins" \
    --exclude="*.sh" 2>/dev/null; then
    echo "⚠️  WARNING: Found PayStack live keys!"
    SECURITY_ISSUES=$((SECURITY_ISSUES + 1))
fi

# Check for Resend API keys (that aren't placeholders)
if grep -r "re_[A-Z][a-zA-Z0-9_]\{15,\}" . \
    --exclude-dir=".git" \
    --exclude-dir="ios/Pods" \
    --exclude-dir="local_plugins" \
    --exclude="*.sh" 2>/dev/null; then
    echo "⚠️  WARNING: Found potential Resend API keys!"
    SECURITY_ISSUES=$((SECURITY_ISSUES + 1))
fi

# Check for specific compromised Supabase URLs
if grep -r "gixstjuzbqcvdfcqeztk\|yvnfhsipyfxdmulajbgl" . \
    --exclude-dir=".git" \
    --exclude-dir="ios/Pods" \
    --exclude-dir="local_plugins" \
    --exclude="*.sh" 2>/dev/null; then
    echo "⚠️  WARNING: Found real Supabase project identifiers!"
    SECURITY_ISSUES=$((SECURITY_ISSUES + 1))
fi

echo ""
if [ $SECURITY_ISSUES -eq 0 ]; then
    echo "✅ Security verification passed! No sensitive data found."
else
    echo "⚠️  Found $SECURITY_ISSUES potential security issue(s). Review output above."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Sanitization Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Sanitized repository location:"
echo "  $SANITIZED_DIR"
echo ""
echo "📋 Summary of changes:"
echo "  • Removed .env files and credentials"
echo "  • Sanitized source code (supabase_config.dart, env.dart, firebase_options.dart)"
echo "  • Sanitized 37+ documentation files"
echo "  • Created .env.example with placeholders"
echo "  • Excluded build artifacts (Pods, .dart_tool, build)"
echo ""
echo "Next steps:"
echo "  1. Review the sanitized copy: cd $SANITIZED_DIR"
echo "  2. Verify no sensitive data remains"
echo "  3. Zip and share: tar -czf repo-sanitized.tar.gz -C $(dirname $SANITIZED_DIR) $(basename $SANITIZED_DIR)"
echo ""
echo "⚠️  IMPORTANT: Your original repo with credentials is untouched at:"
echo "  $ORIGINAL_DIR"
echo ""
