# Settle Now — Project Context

> Shared context for any human or AI agent working on Settle Now, across either repo.
> This file should be near-identical in both repos. Repo-specific implementation
> detail lives in each repo's own `CONTEXT.md`.

## What is Settle Now

Settle Now is a personal finance / expense-splitting mobile app (Flutter) with a
Node.js backend. It solves "who owes who" for groups of people sharing costs —
roommates, trips, friend groups — and also supports informal one-on-one lending
between two people, and personal expense tracking.

- 5,000+ downloads, 50+ DAU
- Solo-developed and maintained by Rohit Anand
- Live at https://settlenow.in/

## Repos

| Repo | Visibility | Stack | Purpose |
|---|---|---|---|
| [Settle-Now-App](https://github.com/rranand/Settle-Now-App) | Public | Flutter/Dart | Mobile + web client |
| Settle-Now-NODE | Private | Node.js/Express + MongoDB | API backend, deployed on AWS Lambda |

## Core Domain Concepts

These four features are the heart of the app. They are related but distinct —
don't conflate them when reasoning about data models or business logic.

### 1. Rooms
- N users join a room and log shared expenses against it.
- An expense can be split fully or partially — not every room member has to be
  part of every transaction.
- Transactions can be created in bulk.
- Each user's net position (gain/loss) is computed from all transactions in the room.
- Users settle debts to each other within the room.
- A room can be closed once all transactions are settled.

### 2. LenDen (personal ledger)
- Exactly two users per LenDen "room" (a 1:1 ledger, not a group room).
- Tracks informal gave/owe entries between the pair, chat-style.
- Maintains a running mutual balance.

### 3. Personal Expense
- A user's own monthly expense log, independent of rooms.
- Two ways entries get into it:
  1. **Manual entry** — user directly logs a personal expense for the current month.
  2. **"Add to Personal Expense" flow** — from an existing Room transaction *or*
     an existing QuickSplit transaction, the user taps a button to pull that
     transaction into their **current month's** personal expense. Only the
     user's own share of the original transaction is added, not the full amount.
     (Implemented as its own bloc: `bloc/add_to_personal_expense/` — this is
     the flow to look at for this specific behavior, distinct from the general
     `personal_expense` bloc/cubit which handles the monthly log and dashboard.)
- **Sync behavior applies to both source types (Room and QuickSplit):** if the
  original transaction is later edited or deleted at the source, the linked
  personal expense entry must be updated/deleted too (bidirectional sync,
  cascading updates/deletes).

### 4. QuickSplit
- For expenses that don't belong in a persistent room — a lightweight, one-off,
  independent split-and-settle flow. Supports partial/custom amounts like Rooms do,
  but has no ongoing room state.

### How they relate
Rooms and QuickSplit both produce transactions that can be pulled into Personal
Expense via the "Add to Personal Expense" flow (user's own share only, added
to the current month). LenDen is deliberately separate — it's a two-party
running ledger, not an expense split, and has no personal-expense sync. Personal
Expense is the aggregation point for "what did I actually spend": manual entries
plus anything pulled in from Rooms or QuickSplit.

## Known Open Items / Things Any Agent Should Know

- **Balance/settlement algorithm — core math confirmed correct, one narrower
  question remains open.** The Contribution/Spent/Balance model (per-user
  Gain/Loss, Loss pays Gain, computed as MongoDB virtuals from transaction
  records) is documented and verified in `BACKEND_CONTEXT.md`. What's still
  unverified: whether/how the app minimizes the *number* of settlement
  transactions when multiple users owe each other (the "who pays whom"
  optimization Splitwise does) — settlement today may simply be user-initiated
  (pick a person + amount) rather than auto-suggested. Confirm which before
  assuming Splitwise-style optimization is in scope. See `BACKEND_CONTEXT.md`
  for full algorithm detail and remaining open questions (rounding-remainder
  determinism, SQS idempotency).
- **Go/PostgreSQL migration is paused, not abandoned.** There was an active
  effort to migrate the backend from Node/Express/MongoDB to Go/PostgreSQL.
  It's currently paused due to time constraints, not cancelled. Do not assume
  the migration happened — the production backend today is still Node/MongoDB.
  When designing new backend features, consider whether it's worth designing
  with an eventual Go/Postgres port in mind, but don't block on it.
- Sole developer, no formal staging environment — testing happens locally on
  device before publishing directly to app stores / web.

## Out of Scope (currently)

- No CI/CD for the backend or for mobile app releases (both manual/local).
  Web frontend is the exception — GitHub Actions auto-deploys to Vercel on
  push to the relevant branch.
- No automated test suite mentioned
- No multi-currency support noted