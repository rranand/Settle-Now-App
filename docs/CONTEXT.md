# Settle Now Frontend — Context

> Repo: Settle-Now-App (public) — https://github.com/rranand/Settle-Now-App
> See PROJECT_CONTEXT.md for domain concepts (Rooms, LenDen, Personal Expense, QuickSplit).
> This file covers frontend implementation specifics only.

## Stack

- **Framework:** Flutter / Dart
- **State management:** Hybrid — **Provider** for lightweight reactive state,
  **Flutter Bloc / Bloc** (with Cubit) for scalable business logic and
  predictable state flows. Don't assume one pattern app-wide; check which
  a given feature uses before extending it.
- **Backend integration:** REST APIs (see backend repo — routes: auth, room,
  lenden, personal, quicksplit, friend, notification, user, server)
- **Firebase:** Core, Cloud Messaging (push notifications), Analytics,
  Crashlytics, Remote Config
- **Auth:** Google Sign-In + JWT-based session handling, device-aware sessions

## Project Structure (`lib/`)

Top-level folders, each explained below with what actually lives in them.

```
lib/
├── bloc              # Bloc-managed features (see below)
├── constant          # App-wide constants (calendar, gradients, home UI, remote config, UI)
├── core.dart
├── cubit             # Cubit-managed features (see below)
├── data              # data_provider/ (raw API calls) + repository/ (wraps data_provider)
├── firebase          # messaging, options (incl. firebase_options_dev.dart), remote config
├── internationalization  # currency.dart
├── main.dart
├── model             # Data models, flat — one file per entity/DTO
├── notification       # notification_controller, notification_interface_handler
├── provider           # preference_provider, screen_size_provider
├── router              # router_config, router_constant
├── screen              # UI screens, organized by feature (see below)
├── theme               # themes.dart
└── util                # card/, custom/, enum/, filter/, functions/, graph/, handler/, oAuth/, widgets/
```

### Bloc vs Cubit — which feature uses which

There's a clear split by feature, not a mixed convention within a single feature:

**Bloc-managed:** `auth`, `notification`, `notification_action`, `quicksplit`,
`update_info`, `add_to_personal_expense`, and the **dashboard** sub-flows of
`lenden`, `personal_expense`, and `room` (`lenden_dashboard`,
`personal_expense_dashboard`, `room_dashboard`), plus the single-room view
`room/each_room` and `lenden/room`.

**Cubit-managed:** `filter`, `new_transaction`, `lenden/create_room`,
`quicksplit/settle`, `user/friend`, `user/preference`,
`user/user_login_activity`, `user/user_update_profile`, and most of the
**room** sub-flows: `create_join_room`, `room_activity`, `room_close`,
`room_close_request`, `room_info`, `room_settle`, `room_settle_upsert`,
`room_user`.

**Pattern to infer:** Bloc tends to be used for dashboard/list-level views and
flows with distinct event→state transitions (auth, notifications); Cubit tends
to be used for more granular, single-purpose state (a specific room action, a
filter, a form). When adding a new feature, match the pattern of the closest
existing sibling rather than picking arbitrarily.

### Data layer pattern

Every feature with backend calls follows: `data_provider/<feature>_data_provider.dart`
(raw network calls) → `repository/<feature>_repository.dart` (wraps the
provider, consumed by bloc/cubit). This mirrors the backend's route/module
naming almost exactly (auth, lenden/dashboard, lenden/room, notification,
personal_expense/dashboard, personal_expense/monthly_expense, quicksplit,
room/dashboard, room/each_room, update_info) — useful for tracing a feature
end-to-end across both repos.

### Screens, by feature

```
screen/
├── auth/            login, signup, google_signin (web-specific impl + stub)
├── dashboard/
│   ├── home/          home_screen, about_us, deep_link_join, preference_screen
│   ├── lenden/         lenden_dashboard_screen, lenden_expense_screen
│   ├── notification/
│   ├── personal_expense/  dashboard + monthly screen + categories/transaction sub-sections
│   ├── quicksplit/     quick_split_dashboard_screen
│   └── room/           dashboard, expense screen + sub_section: activity, analysis, settle, transaction, user
└── profile/            profile_screen, profile_edit, login_activity
```

### `util/` breakdown

- `card/` — one card widget per list-item type across features (room_card,
  lenden_card, quick_split_card, settle_card, transaction_card, etc.)
- `handler/` — cross-cutting infra: `network_call.dart` (API client),
  `local_storage_preference.dart`, `crypto.dart`, `filter_sort.dart`,
  `platform_service.dart`, `stream_to_listenable.dart`
- `functions/` — `room_function.dart`, `validator.dart`, `text_function.dart`,
  `in_app_update_service.dart`, `additional_function.dart`
- `enum/` — activity_type, device_type, filter_enums, transaction_type
- `graph/` — analytics chart widgets (bar_group, bar_line, expense-by-category,
  expense-by-user, legend, linear_graph_card)
- `widgets/` — shared UI primitives (buttons, shimmer, snackbar, navbar,
  auth_gate, maintenance_page, update_page)
- `oAuth/` — google_oauth.dart
- `custom/` — small generic helpers (pair, tuple, typedefs, custom_gesture_detector)

## Features Implemented

- Authentication: Google Sign-In, JWT handling, persistent sessions, device-aware sessions
- Expense management: create/split shared expenses (equal + custom), real-time
  balance calc, expense history, settlement workflows, activity timeline
- Rooms: multi-participant expense rooms, room-wise balances, room activity,
  room-based settlement
- LenDen: two-person mutual ledger, chat-style transaction history, editable
  entries (creator only), running balance
- Notifications: FCM + local notifications, background handling
- Analytics/insights: spending summaries, trend charts, timeline activity
- UX: shimmer loading, sticky headers, cached images, adaptive typography,
  in-app update/review prompts, share/invite flows

## Dev Workflow

- Sole developer — no formal CI/CD for the mobile app itself.
- Local testing on physical device with a dev build.
- On satisfactory local testing, builds and publishes the app bundle (Android)
  directly — no separate staging environment for mobile.
- **Web build is auto-deployed:** a GitHub Actions workflow deploys the web
  version to **Vercel** automatically on push to the relevant branch. This is
  the one part of the pipeline that is automated — mobile release is still
  manual.

## Notes for Agents

- Bloc vs Cubit choice is documented above by feature — follow the existing
  pattern of the closest sibling feature rather than picking arbitrarily.
- No documented build flavors (dev/prod) or `.env`-based config split, though
  `firebase_options_dev.dart` suggests at least a dev Firebase config exists
  separate from prod — verify in code before assuming a full flavor split.