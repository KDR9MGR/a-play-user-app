# Xcode StoreKit Configuration - Cleanup Instructions

**Status**: Scheme file updated ✅ | Manual cleanup required ⚠️

---

## ✅ What I Fixed Automatically

Updated the Xcode scheme to point to the correct StoreKit config:
- **File**: `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`
- **Changed**: `../A-Play.storekit` → `../StoreKitConfig.storekit`
- **Result**: Debugging sessions will now use the correct StoreKit configuration

---

## ⚠️ Manual Steps Required (Do This in Xcode)

You still need to remove a broken file reference in Xcode. This **cannot be automated** and must be done manually.

### Step 1: Open Project in Xcode
```bash
cd /Users/abdulrazak/Documents/a-play-user-app-main
open ios/Runner.xcworkspace
```

### Step 2: Remove Broken Reference

1. **In Xcode Project Navigator** (left sidebar):
   - Look for a file named `Configuration.storekit`
   - It will appear in **RED** (indicating broken/missing file)
   - It might be under the "Runner" folder group

2. **Right-click on** `Configuration.storekit`

3. **Select "Delete"**

4. **In the popup, choose "Remove Reference"** (NOT "Move to Trash")
   - This only removes the reference from the project
   - It won't delete anything from your filesystem

### Step 3: Verify Configuration

1. **Check Scheme (Optional verification)**:
   - Menu: **Product → Scheme → Edit Scheme**
   - Select **Run** → **Options** tab
   - Verify "StoreKit Configuration" shows `StoreKitConfig.storekit` ✓
   - Click "Close"

2. **Build and Test**:
   - Run the app in simulator (⌘R)
   - Navigate to subscription screen
   - Verify all 4 tiers show with correct pricing:
     - 7day: 50 GHS
     - 1month: 190 GHS
     - 3SUB: 550 GHS
     - 365day: 2200 GHS

---

## 🔍 Why This Happened

Your project had **conflicting StoreKit references**:

1. **Old broken reference**: `Configuration.storekit` (doesn't exist)
2. **Empty duplicate**: `A-Play.storekit` (deleted)
3. **Active config**: `StoreKitConfig.storekit` (correct! ✓)

When you tried to "add" the StoreKit file to Xcode, it conflicted with the existing broken reference. That's why you got an error.

---

## 📋 Current StoreKit Setup (After Cleanup)

### Files:
- ✅ `ios/StoreKitConfig.storekit` - Active configuration with 4 subscription products
- ❌ `ios/A-Play.storekit` - Deleted (was empty)

### Xcode References:
- ✅ **Scheme**: Points to `StoreKitConfig.storekit`
- ✅ **Build Settings**: `STOREKIT_CONFIGURATION_FILE = StoreKitConfig.storekit`
- ⚠️ **Broken Reference**: `Configuration.storekit` (needs manual removal)

### Product IDs in Config:
- `7day` - 1 Week Premium (50 GHS)
- `1month` - 1 Month Premium (190 GHS)
- `3SUB` - 3 Months Premium (550 GHS)
- `365day` - 1 Year Premium (2200 GHS)

---

## 💡 Important Notes

### StoreKit Files Don't Need to Be "Added"
- StoreKit configuration files are **auto-detected** by Xcode
- They work through build settings and scheme configuration
- You do **NOT** need to add them to the project file list
- Just having the file in `/ios/` is enough

### Testing Your Setup
Once you remove the broken reference:
1. Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
2. Run app in simulator
3. Test subscription purchases (they'll use StoreKit test environment)
4. All transactions are simulated - no real money charged

### For Production Testing
- After configuring products in App Store Connect
- Build and upload to TestFlight
- Use sandbox test accounts for testing
- Real IAP flow will use App Store Connect product IDs

---

## ✅ Checklist

- [x] Scheme updated to use `StoreKitConfig.storekit`
- [x] Deleted empty `A-Play.storekit` file
- [ ] **YOU NEED TO DO**: Remove broken `Configuration.storekit` reference in Xcode
- [ ] **YOU NEED TO DO**: Test app in simulator to verify StoreKit works
- [ ] **YOU NEED TO DO**: Configure products in App Store Connect with matching IDs

---

## 🆘 If You Still Get Errors

### Error: "StoreKit configuration file not found"
**Fix**: Make sure `ios/StoreKitConfig.storekit` exists and hasn't been accidentally deleted

### Error: "Duplicate product IDs"
**Fix**: Remove the broken `Configuration.storekit` reference (Step 2 above)

### Error: Products not loading in app
**Fix**:
1. Check that product IDs in `StoreKitConfig.storekit` match your Dart code
2. Verify you're running on a real device or simulator (not preview)
3. Clean build folder and rebuild

---

**Next**: After removing the broken reference, proceed to configure products in App Store Connect as described in `APPLE_IAP_SETUP_COMPLETE.md`
