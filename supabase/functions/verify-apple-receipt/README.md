# verify-apple-receipt (Supabase Edge Function)

Validates Apple App Store subscription receipts using the legacy `verifyReceipt` API and returns a structured JSON indicating validity and key receipt fields.

## Environment Variables

- `APPLE_SHARED_SECRET`: App-specific shared secret from App Store Connect (for auto-renewable subscriptions).
  - Set via Supabase CLI:
    - `supabase secrets set APPLE_SHARED_SECRET=your_shared_secret`

## Local Development

1. Create a local env file:
   - `supabase/functions/verify-apple-receipt/.env.example`
   - Put `APPLE_SHARED_SECRET=your_shared_secret` inside.
2. Serve locally:
   - `supabase functions serve verify-apple-receipt --env-file supabase/functions/verify-apple-receipt/.env.example`

## Deploy

- `supabase functions deploy verify-apple-receipt`
- Set your secret in the project:
  - `supabase secrets set APPLE_SHARED_SECRET=your_shared_secret`

## Request Body

```json
{
  "userId": "<uuid>",
  "planId": "<plan-id>",
  "transactionId": "<apple-transaction-id>",
  "receiptData": "<base64-receipt>"
}
```

## Response (200 OK when valid)

```json
{
  "valid": true,
  "environment": "Sandbox",
  "status": 0,
  "matchedTransaction": true,
  "productId": "SUB3M",
  "transactionId": "1000002036163913",
  "originalTransactionId": "1000002036163901",
  "expiresDateMs": "1730403600000",
  "planId": "quarterly_plan",
  "userId": "<uuid>"
}
```

## Notes

- If Apple returns `status: 21007` (sandbox receipt sent to production), the function automatically retries in sandbox.
- Non-zero `status` returns `422` with `valid: false`.
- For production readiness, consider switching to App Store Server API JWT flows for renewals and richer status.