# Apple IAP Setup Complete ✅

**Date**: April 13, 2026
**Status**: Ready for App Store Connect Configuration

---

## ✅ Changes Completed

### 1. **Database Migration**
- Created: `supabase/migrations/20260413_update_subscription_pricing.sql`
- New pricing: 50 GHS (weekly), 190 GHS (monthly), 550 GHS (quarterly), 2200 GHS (annual)

### 2. **Flutter App Model**
- Updated: `lib/features/subscription/model/subscription_model.dart`
- All default plans now use new GHS pricing

### 3. **StoreKit Configuration**
- ✅ Deleted duplicate file: `ios/A-Play.storekit`
- ✅ Updated: `ios/StoreKitConfig.storekit`
- Updated all product IDs and pricing

### 4. **Product ID Alignment**
All components now use consistent product IDs:
- **Weekly**: `7day` (50 GHS)
- **Monthly**: `1month` (190 GHS)
- **Quarterly**: `3SUB` (550 GHS)
- **Annual**: `365day` (2200 GHS)

---

## 📋 App Store Connect Configuration Required

You **MUST** configure these exact product IDs in App Store Connect:

### Subscription Group: "Go Pro"
**Subscription Group ID**: `21809726` (already in StoreKit config)

### Product Configuration

#### 1. Weekly Subscription
- **Product ID**: `7day`
- **Reference Name**: 1 Week Premium
- **Duration**: 1 Week
- **Price**: 50 GHS (or equivalent in other currencies)
- **Description**: "Fun Week"
- **Display Name**: "1 Week Premium"

#### 2. Monthly Subscription
- **Product ID**: `1month`
- **Reference Name**: 1 Month Premium
- **Duration**: 1 Month
- **Price**: 190 GHS (or equivalent in other currencies)
- **Description**: "Early Events Access"
- **Display Name**: "1 Month Premium"

#### 3. Quarterly Subscription
- **Product ID**: `3SUB`
- **Reference Name**: 3 Months Premium
- **Duration**: 3 Months
- **Price**: 550 GHS (or equivalent in other currencies)
- **Description**: "3 Months Benefits As premium user"
- **Display Name**: "3 Months Premium"

#### 4. Annual Subscription
- **Product ID**: `365day`
- **Reference Name**: 1 Year Premium
- **Duration**: 1 Year
- **Price**: 2200 GHS (or equivalent in other currencies)
- **Description**: "Premium Access to Events"
- **Display Name**: "1 Year Premium"

---

## 🔧 Files Updated

### StoreKit Configuration
- `ios/StoreKitConfig.storekit` ✅
  - Product IDs: 7day, 1month, 3SUB, 365day
  - Pricing: 50, 190, 550, 2200 GHS

### Flutter Code (Already Correct)
- `lib/features/subscription/service/apple_iap_service.dart` ✅
  - Product ID mappings verified
- `lib/core/services/purchase_manager.dart` ✅
  - Product ID list verified
- `lib/features/subscription/model/subscription_model.dart` ✅
  - Pricing updated to new GHS values

### Database
- `supabase/migrations/20260413_update_subscription_pricing.sql` ✅
  - New pricing and duration-based plans

---

## 🎯 Next Steps for App Store Connect

### Step 1: Create Subscription Products
1. Log into [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to: **My Apps** → **A-Play** → **Subscriptions**
3. Find subscription group "Go Pro" (ID: 21809726)
4. Create 4 new auto-renewable subscriptions with the exact product IDs listed above

### Step 2: Set Pricing
For each subscription, set the **Base Territory** (Ghana):
- Weekly: 50 GHS
- Monthly: 190 GHS
- Quarterly: 550 GHS
- Annual: 2200 GHS

Apple will automatically generate pricing for other territories based on the exchange rate.

### Step 3: Review Information
For each subscription, add:
- **Subscription Display Name** (from table above)
- **Description** (from table above)
- **Promotional Images** (optional but recommended)

### Step 4: Submit for Review
Once all 4 subscriptions are configured:
1. Save all changes
2. Submit subscriptions for review along with your app
3. Ensure you have screenshots showing subscription benefits

---

## 🧪 Testing

### Xcode StoreKit Testing (Local)
1. The app already has `StoreKitConfig.storekit` configured
2. Run app in Xcode simulator
3. Test all 4 subscription purchases
4. Verify pricing displays correctly as 50, 190, 550, 2200 GHS

### TestFlight Testing (Sandbox)
1. After configuring products in App Store Connect
2. Create sandbox test accounts in App Store Connect
3. Install app via TestFlight
4. Test real IAP flow with sandbox accounts
5. Verify receipt validation with Supabase backend

---

## ⚠️ Important Notes

### Currency Display
- StoreKit config uses Ghana (GHA) as storefront
- Prices will display in GHS on devices set to Ghana region
- Other regions will see auto-converted prices

### Product ID Format
- Apple requires product IDs to be unique
- Cannot change product IDs after submission
- Make sure these exact IDs are available in your App Store Connect account

### Subscription Group
- All 4 tiers are in the same group "Go Pro"
- Users can only have one active subscription at a time
- Upgrading/downgrading is automatic within the group

---

## 📞 Support

If you encounter issues:

1. **Product IDs not found**: Ensure exact match in App Store Connect
2. **Pricing not displaying**: Check StoreKit config currency/locale
3. **Receipt verification fails**: Check Supabase Edge Function logs
4. **Sandbox testing issues**: Verify sandbox account is properly configured

---

## ✅ Checklist Before Submission

- [ ] All 4 product IDs created in App Store Connect
- [ ] Pricing set to 50, 190, 550, 2200 GHS
- [ ] Subscription descriptions and names added
- [ ] Local testing in Xcode completed
- [ ] TestFlight sandbox testing completed
- [ ] Receipt verification tested with backend
- [ ] Database migration applied (`supabase db push`)
- [ ] Screenshots showing subscription benefits prepared
- [ ] Privacy policy and terms updated to mention subscriptions

---

**Status**: All code changes complete. Ready for App Store Connect configuration.
