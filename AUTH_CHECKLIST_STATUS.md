# Authentication & Registration — Checklist Status

Audit date: 2026-07-13. Scope: `a-play-user-app-main` (Flutter + Supabase Auth).
Status legend: ✅ Implemented · 🟡 Partial · ❌ Not implemented · ➖ N/A / handled by Supabase SDK

This is a snapshot, not a guarantee — re-verify against code before relying on any ✅ here after future changes.

## Input Validation
🟡 Client-side null/length/regex checks on forms. Password strength enforced both client and server (`_validatePasswordOrThrow` in `auth_provider.dart`). No sanitization/HTML-escaping/unicode-normalization layer.
➖ SQL/NoSQL injection: moot — Supabase client only issues parameterized PostgREST calls, never raw SQL from the client.

## Email Validation
🟡 Only a `.contains('@')` check client-side. No RFC-strict regex, no MX-record check, no disposable-email detection, no domain allow/deny list.
➖ Normalization, uniqueness enforcement, confirmation token issuance/validation — handled by Supabase Auth.

## Username Validation
➖ Not applicable. App has no username system — identity is email + `full_name` metadata only.

## Password Validation
🟡 Min 8 chars, requires a number + special character (client + server enforced). Confirm-password match checked client-side.
❌ No breach detection (e.g. HaveIBeenPwned), no password-reuse/history prevention.
➖ Hashing/storage/verification — Supabase Auth's job.

## Phone Validation
❌ Not implemented. No phone field or OTP flow anywhere in the auth feature.

## Account Validation
✅ Custom sign-in/sign-up intent enforcement (`_enforceSocialAuthIntent`, compares `created_at`/`last_sign_in_at`) — prevents silent account creation on "sign in" and silent login on "sign up" for Google/Apple.
✅ Hard delete via `delete-account` edge function + `prepare_user_deletion` RPC.
❌ No account status field (suspended/locked/disabled), no soft-delete, no explicit in-app "email verified" gate (relies on Supabase's `email_confirmed_at`), no KYC.

## Authentication
✅ Email/password, Google OAuth (ID-token flow), Apple Sign-In (with nonce) — all implemented in `auth_provider.dart`. Social buttons currently hidden via `FeatureFlags.enableSocialLogin = false` (logic intact, entry points hidden).
❌ No MFA/2FA, no passkey, no biometric auth, no magic link, no OIDC/SAML/SSO beyond Google/Apple.

## Authorization
🟡 RLS policies exist and were hardened this session (privilege-escalation guard trigger on `profiles`, service-role-only insert guard on `user_subscriptions`/`bookings`). No formal RBAC/ABAC framework in app code beyond ownership checks (e.g. delete-account scoped to caller's own JWT).

## Session & Token Management
➖ Entirely handled by the `supabase_flutter` SDK — JWT issue/validate/refresh/rotation, session persistence. No custom token code (correctly so — don't reinvent this).

## Security Checks
❌ No rate limiting, CAPTCHA, CSRF protection, device fingerprinting, IP/geo-reputation checks, impossible-travel detection, brute-force/login-attempt lockout, or trusted-device logic in app code. Supabase Auth has some baked-in server-side rate limiting, but it isn't app-controlled or visible/auditable from here.

## Registration
✅ `signUpWithEmail` → `handle_new_user` DB trigger provisions `profiles` row → welcome email sent (Resend) → OneSignal linking. Email confirmation token gen/validation is Supabase's job.

## Login
🟡 `signInWithEmail` works with clear, user-friendly error states.
❌ No last-login timestamp tracking, no failed-login counter, no persisted/queryable login audit log (only dev-only `debugPrint`).

## Password Recovery
✅ `resetPassword` sends Supabase reset email with platform-specific deep-link redirect; `updatePassword` applies the new password post-recovery-session, reusing the shared strength validator. Token generation/validation/expiry is Supabase's job.

## Database Checks
🟡 PK/FK/unique constraints exist at the schema level. Not exhaustively re-verified against the *live* Supabase schema in this pass — tracked migration files are known to drift from live state (see project memory `reference_aplay_live_schema.md`); confirm live before relying on any specific constraint.

## Audit & Monitoring
❌ Not implemented. No login/device/session history table, no persisted audit log. Only ad-hoc `debugPrint` console output (dev-only, stripped/ignored in release).

## Compliance & Privacy
🟡 EULA consent dialog exists but is recorded only in local `SharedPreferences` — no server-side, durable proof-of-consent. Privacy policy / legal-links screens exist as static content.
❌ No age verification, no GDPR data-retention automation, no consent versioning or re-consent flow tied to the backend.

---

## Suggested priority order for future hardening
1. **Rate limiting / brute-force lockout** on login and password-reset-request (cheapest win, closes the most realistic abuse vector).
2. **Persisted login/audit logging** (who signed in, when, from where) — needed for any future incident response.
3. **Server-side consent recording** (EULA/privacy acceptance tied to the user's profile row, not just local storage).
4. **Disposable-email detection** on signup — reduces throwaway/spam accounts cheaply.
5. **MFA/2FA** — biggest lift, only worth it once the above are in place.

Everything else on the original checklist (KYC, SSO/SAML, biometric, passkeys, phone/OTP, username system) is out of scope unless the product direction changes to need it.
