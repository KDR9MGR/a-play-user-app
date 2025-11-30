# Apple App Store Compliance Notes

This document outlines how the A Play app complies with Apple App Store Guidelines.

## Guideline 5.1.1 - Privacy - Data Collection and Storage

**Issue:** App required users to register before accessing explore features.

**Resolution:**
- Modified router to allow guest access to `/home`, `/podcast`, and `/explore` routes without authentication
- Updated explore page to allow all users to view events without requiring login or premium subscription
- Users can browse events freely; only booking/purchasing requires authentication
- See: `lib/config/router.dart` lines 43-48 and `lib/features/explore/screens/explore_page.dart`

## Guideline 2.1 - Performance - App Completeness

**Issue:** App contained placeholder images, events, and exhibited bugs on iPad Air.

**Resolution:**
- **Placeholder Content:** Database should be populated with real, production-ready events and images (not code-level issue)
- **iPad Air Bug Fixes:**
  - Added comprehensive error handling in event loading to prevent crashes
  - Improved error messages to be user-friendly instead of technical
  - Added try-catch blocks around event tap handlers to prevent app freezing
  - Responsive grid layout adjusted for iPad (2-4 columns based on screen size)
  - See: `lib/features/explore/screens/explore_page.dart` and `lib/features/explore/service/event_supabase_service.dart`

## Guideline 3.1.2 - Business - Payments - Subscriptions

**Issue:** App metadata missing functional link to Terms of Use (EULA).

**Resolution:**
- Added prominent "Terms of Use (EULA)" link in subscription plans screen
- Link points to Apple's standard EULA: https://www.apple.com/legal/internet-services/itunes/dev/stdeula
- Also available in app's Legal & Policies section accessible from profile
- See: `lib/features/subscription/screens/subscription_plans_screen.dart` lines 164-184
- See: `lib/presentation/pages/legal_links_page.dart` lines 39-42

## Guideline 3.1.1 - Business - Payments - In-App Purchase

**Issue:** Subscriptions could be purchased using payment mechanisms other than in-app purchase on iOS.

**Resolution:**
- **iOS Platform:** Uses Apple In-App Purchase (IAP) exclusively for all digital subscriptions
- **Android Platform:** Uses PayStack for subscription payments
- Platform detection logic ensures iOS users CANNOT use PayStack
- Implementation uses `Platform.isIOS` check to route to appropriate payment method
- Apple IAP service handles all iOS subscription purchases, verification, and receipt validation
- See: `lib/features/subscription/screens/subscription_plans_screen.dart` lines 693-734
- See: `lib/features/subscription/service/platform_subscription_service.dart`
- See: `lib/features/subscription/service/apple_iap_service.dart`

### Payment Flow Details:

**iOS Users:**
1. User selects subscription plan
2. App checks `Platform.isIOS` → true
3. Initiates Apple IAP flow using `in_app_purchase` package
4. Apple handles payment processing
5. App receives purchase confirmation from App Store
6. Backend verifies receipt with Apple servers
7. Subscription activated in Supabase database

**Android Users:**
1. User selects subscription plan
2. App checks `Platform.isIOS` → false
3. Shows PayStack WebView for payment
4. PayStack handles payment processing
5. App verifies payment with PayStack API
6. Subscription activated in Supabase database

## Additional Compliance Features

- **Account Deletion:** Users can delete their account and all associated data from profile settings
  - See: `lib/features/authentication/presentation/providers/auth_provider.dart` lines 303-365

- **Data Privacy:** Comprehensive privacy policy available in-app and on website
  - Privacy Policy: https://www.aplayworld.com/privacy-policy
  - See: `lib/presentation/pages/legal_links_page.dart`

## Testing Instructions for Reviewers

1. **Guest Access (Guideline 5.1.1):**
   - Launch app without signing in
   - Navigate to "Explore" tab
   - Verify all events are viewable
   - Tap on any event to view details
   - Only when trying to book should login be required

2. **Subscription Purchase (Guideline 3.1.1):**
   - Sign in to the app
   - Navigate to Profile → Premium Plans (or see upgrade prompts)
   - Select any subscription tier
   - On iOS: Verify Apple IAP sheet appears (NOT PayStack)
   - On Android: Verify PayStack payment page appears

3. **Terms of Use (Guideline 3.1.2):**
   - Navigate to subscription plans screen
   - Scroll to bottom of page
   - Verify "Terms of Use (EULA)" link is visible and clickable
   - Link opens Apple's standard EULA in browser

4. **Stability (Guideline 2.1):**
   - Test on iPad Air (5th generation) with iPadOS 18.1+
   - Browse explore page with various categories
   - Tap on multiple events
   - Verify no crashes or error messages
   - Confirm responsive layout on iPad

## Environment Configuration

The app uses environment variables for API keys:
- `SUPABASE_URL` - Backend database URL
- `SUPABASE_ANON_KEY` - Backend authentication key
- `PAYSTACK_PUBLIC_KEY` - Android payment processing (NOT used on iOS)

## Contact Information

For App Store review questions or issues:
- Support: https://www.aplayworld.com/contact
- Email: support@aplayworld.com
- Website: https://www.aplayworld.com

---

**Last Updated:** 2025-01-25
**App Version:** 1.0.3+3
**Build Number:** 3
