# Restore Purchases Test Plan

## Overview
This document outlines the comprehensive testing approach for the Apple IAP restore purchases functionality implemented in the TestPlay app.

## Test Environment Setup

### Prerequisites
1. **iOS Device/Simulator**: iOS 12.0 or later
2. **Apple Developer Account**: With App Store Connect access
3. **Sandbox Test Account**: Created in App Store Connect
4. **Test Products**: Configured in App Store Connect
5. **Supabase Backend**: Properly configured with subscription tables

### Test Products Required
- `premium_monthly`: Monthly subscription
- `premium_yearly`: Yearly subscription
- `premium_lifetime`: One-time purchase (if applicable)

## Test Scenarios

### 1. Fresh Install Restore
**Objective**: Test restoring purchases on a fresh app installation

**Steps**:
1. Install app on device A
2. Sign in with sandbox test account
3. Purchase a subscription (e.g., premium_monthly)
4. Verify subscription is active
5. Delete app from device A
6. Install app on device B (or reinstall on device A)
7. Sign in with the same sandbox test account
8. Navigate to subscription screen
9. Tap "Restore Purchases" button
10. Verify loading indicator appears
11. Wait for completion

**Expected Results**:
- Loading indicator shows "Restoring purchases..."
- Success message: "Successfully restored 1 active subscription"
- Subscription status updates to active
- User gains access to premium features
- Database records are created correctly

### 2. Multiple Subscriptions Restore
**Objective**: Test restoring multiple subscription purchases

**Steps**:
1. Using sandbox account, purchase multiple subscriptions over time
2. Let some subscriptions expire naturally
3. Fresh install the app
4. Sign in and restore purchases

**Expected Results**:
- All historical subscriptions are restored
- Only active subscriptions grant access
- Expired subscriptions are marked as expired
- Success message shows correct count of active subscriptions

### 3. No Purchases to Restore
**Objective**: Test restore when no previous purchases exist

**Steps**:
1. Use a new sandbox test account with no purchase history
2. Tap "Restore Purchases"

**Expected Results**:
- Message: "No previous purchases found to restore"
- No errors occur
- App remains in non-premium state

### 4. Network Error Handling
**Objective**: Test restore purchases with network issues

**Steps**:
1. Disable internet connection
2. Tap "Restore Purchases"
3. Re-enable internet and retry

**Expected Results**:
- First attempt shows appropriate error message
- Retry button is available
- Second attempt succeeds when network is restored

### 5. App Store Unavailable
**Objective**: Test when App Store services are unavailable

**Steps**:
1. Test in region where App Store is restricted
2. Or simulate App Store unavailability

**Expected Results**:
- Error message: "App Store not available. Please check your connection."
- Retry option available

### 6. Duplicate Purchase Handling
**Objective**: Test deduplication of restored purchases

**Steps**:
1. Purchase same subscription multiple times (renewals)
2. Restore purchases

**Expected Results**:
- Only one active subscription is created per product
- No duplicate database entries
- Correct subscription period is applied

### 7. Receipt Validation Failure
**Objective**: Test handling of invalid receipts

**Steps**:
1. Simulate invalid receipt scenario (requires backend modification)
2. Restore purchases

**Expected Results**:
- Invalid purchases are skipped
- Valid purchases are processed
- Appropriate error logging occurs

## UI/UX Testing

### Loading States
- [ ] Loading indicator appears immediately
- [ ] Loading message is clear and informative
- [ ] Loading persists for appropriate duration
- [ ] Loading can be cancelled if needed

### Success States
- [ ] Success message is clear and informative
- [ ] Success message shows correct count
- [ ] UI updates to reflect restored subscriptions
- [ ] Premium features become accessible

### Error States
- [ ] Error messages are user-friendly
- [ ] Retry button is available for recoverable errors
- [ ] Error messages don't expose technical details
- [ ] Different error types show appropriate messages

## Backend Verification

### Database Checks
After each restore operation, verify:

```sql
-- Check subscriptions table
SELECT * FROM subscriptions 
WHERE user_id = 'test_user_id' 
ORDER BY created_at DESC;

-- Check payments table
SELECT * FROM subscription_payments 
WHERE user_id = 'test_user_id' 
AND metadata->>'restored_purchase' = 'true'
ORDER BY created_at DESC;

-- Check for duplicates
SELECT original_transaction_id, COUNT(*) 
FROM subscription_payments 
WHERE metadata->>'restored_purchase' = 'true'
GROUP BY original_transaction_id 
HAVING COUNT(*) > 1;
```

### Expected Database State
- One subscription record per restored purchase
- Correct status (active/expired) based on expiration date
- Payment records with restored_purchase metadata
- No duplicate original_transaction_ids
- Proper foreign key relationships

## Performance Testing

### Metrics to Monitor
- Time to complete restore operation
- Memory usage during restore
- Network requests count and size
- Database query performance

### Acceptable Thresholds
- Restore completion: < 10 seconds for typical cases
- Memory increase: < 50MB during operation
- Network timeout: 30 seconds maximum
- Database operations: < 2 seconds per purchase

## Security Testing

### Validation Checks
- [ ] Receipt validation occurs server-side
- [ ] Invalid receipts are rejected
- [ ] User can only restore their own purchases
- [ ] Sensitive data is not logged
- [ ] API endpoints are properly secured

## Regression Testing

### Areas to Verify
- [ ] Normal purchase flow still works
- [ ] Existing subscription management unchanged
- [ ] App performance not degraded
- [ ] Other IAP functionality unaffected

## Test Data Cleanup

After testing, ensure:
- Test subscriptions are cancelled
- Sandbox test accounts are reset
- Database test data is cleaned up
- No production data is affected

## Known Limitations

1. **Sandbox Environment**: Some behaviors may differ from production
2. **Apple Review**: Restore functionality must work in production for App Store approval
3. **Receipt Validation**: Requires proper server-side implementation
4. **Platform Specific**: Only works on iOS devices

## Success Criteria

The restore purchases functionality is considered successful when:
- [ ] All test scenarios pass
- [ ] UI/UX meets design requirements
- [ ] Backend data integrity is maintained
- [ ] Performance meets acceptable thresholds
- [ ] Security requirements are satisfied
- [ ] No regressions are introduced

## Production Deployment Checklist

Before deploying to production:
- [ ] All tests pass in sandbox environment
- [ ] Receipt validation endpoint is production-ready
- [ ] Database migrations are applied
- [ ] Monitoring and logging are configured
- [ ] Error tracking is enabled
- [ ] App Store Connect products are configured
- [ ] Privacy policy is updated if needed