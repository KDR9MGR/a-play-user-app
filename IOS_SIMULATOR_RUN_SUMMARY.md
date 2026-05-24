## iOS Simulator Run – Summary of Fixes and Steps

This document records what was done to get the app running on the iOS Simulator and how to reproduce it locally.

### Context
- Startup failed with: “Missing Supabase configuration (SUPABASE_URL / SUPABASE_ANON_KEY). Pass values at build/run time using --dart-define or --dart-define-from-file.”
- Root cause: the app reads Supabase config from Dart defines via `String.fromEnvironment` and throws when they are absent.
  - Config reader: [supabase_config.dart](file:///Users/abdulrazak/Documents/a-play-user-app-main/lib/core/config/supabase_config.dart)
  - Validation and throw site: [main.dart](file:///Users/abdulrazak/Documents/a-play-user-app-main/lib/main.dart#L56-L74)

### Changes Applied
1. Generated Dart defines from a local env-style file to pass Supabase values at build time:
   - Generator script: [gen_dart_defines.py](file:///Users/abdulrazak/Documents/a-play-user-app-main/tool/gen_dart_defines.py)
   - Input file used: `.env.example` (for convenience). This produced `.dart-defines.json`.
2. Fixed a compile-time provider mismatch that prevented the iOS build:
   - Screen updated to use the correct Riverpod provider and notifier:
     - File: [trial_offer_screen.dart](file:///Users/abdulrazak/Documents/a-play-user-app-main/lib/features/subscription/screens/trial_offer_screen.dart)
     - Replaced `subscriptionControllerProvider` with `activeSubscriptionProvider` and adjusted imports.

### Commands Executed
From the project root:

```bash
# 1) Generate dart defines from the example file (produces .dart-defines.json)
python3 tool/gen_dart_defines.py --env-file .env.example --out .dart-defines.json

# 2) Verify a simulator is booted (optional)
open -a Simulator
flutter devices

# 3) Launch on the booted simulator (replace -d value if needed)
flutter run --dart-define-from-file=.dart-defines.json -d E56AA095-FD28-4095-A5FA-B69F643091EC
```

If you prefer to avoid the JSON file and pass values inline, use:

```bash
flutter run \
--dart-define=SUPABASE_URL="https://YOUR-PROJECT.supabase.co" \
--dart-define=SUPABASE_ANON_KEY="YOUR-ANON-KEY"
```

### Successful Run Indicators
Expected logs during a good run include:
- “Supabase init completed”
- “Platform subscription service initialized successfully”
- “RealtimeSync: All subscriptions initialized successfully”
- Flutter DevTools URLs and hot-reload prompts

### Notes and Recommendations
- Security: avoid storing real keys in tracked files. Keep secrets local and use `--dart-define` or a local, gitignored file.
  - `.dart-defines.json` and `.env` are already gitignored in [.gitignore](file:///Users/abdulrazak/Documents/a-play-user-app-main/.gitignore#L49-L54).
  - If `.env.example` contains real values, revert it to placeholders.
- Optional helper script (if you do use a local `.env`): [flutter_run.sh](file:///Users/abdulrazak/Documents/a-play-user-app-main/tool/flutter_run.sh)
  - Converts `.env` → `.dart-defines.json` and runs Flutter with it.

### Code References
- Config reader: [lib/core/config/supabase_config.dart](file:///Users/abdulrazak/Documents/a-play-user-app-main/lib/core/config/supabase_config.dart)
- App init and validation: [lib/main.dart](file:///Users/abdulrazak/Documents/a-play-user-app-main/lib/main.dart)
- Dart defines generator: [tool/gen_dart_defines.py](file:///Users/abdulrazak/Documents/a-play-user-app-main/tool/gen_dart_defines.py)
- Local run helper: [tool/flutter_run.sh](file:///Users/abdulrazak/Documents/a-play-user-app-main/tool/flutter_run.sh)
- Provider fix: [lib/features/subscription/screens/trial_offer_screen.dart](file:///Users/abdulrazak/Documents/a-play-user-app-main/lib/features/subscription/screens/trial_offer_screen.dart)

### TL;DR
- Provide Supabase values via Dart defines and run on a booted simulator:

```bash
python3 tool/gen_dart_defines.py --env-file .env.example --out .dart-defines.json
flutter run --dart-define-from-file=.dart-defines.json
```

App now runs on the iOS Simulator with Supabase initialized and realtime subscriptions active.

