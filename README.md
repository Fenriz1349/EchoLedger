# EchoLedger

![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![iOS](https://img.shields.io/badge/iOS-18%2B-blue?logo=apple)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)
![SwiftData](https://img.shields.io/badge/Persistence-SwiftData-purple)
![Firebase](https://img.shields.io/badge/Backend-Firebase-yellow?logo=firebase)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)
![License](https://img.shields.io/badge/License-Academic-lightgrey)

A personal finance tracking iOS app built as a school project. The primary goal is learning and applying **Clean Architecture with a UseCase pattern**, backed by **Firebase** and, on the Classic target, local persistence via **SwiftData**. See *Targets, Data & Sync* below for how the two shipped targets differ.

---

## Tech Stack

| Component | Technology |
|---|---|
| Language | Swift 6 |
| UI | SwiftUI (iOS 18+) |
| Observability | `@Observable` (not `ObservableObject`) |
| Charts | Swift Charts |
| Local persistence | SwiftData |
| Remote backend | Firebase Auth + Firestore + Storage |
| Connectivity | `NWPathMonitor` + active reachability ping (`NetworkMonitor`) |
| Dependency injection | `DIContainer` (classic + cloud variants) |
| Navigation / lifecycle | `AppEntryViewModel` (launch phases) + `AppCoordinator` (feature VMs) |
| Targets | Classic (SwiftData + sync) and Cloud (Firestore cache-first) |

---

## Architecture

The project follows a strict **Clean Architecture** with clear layer separation:

```
Domain
└── Entities (Transaction, Account, Institution, User, Transfer)
└── UseCases (AddTransaction, GetAccounts, ArchiveAccount, TransferBetweenAccounts, ...)
└── Protocols (-Providing)

Data
└── Local (SwiftData — -LocalSource, -Model)
└── Remote (Firebase — -RemoteSource)
└── Storings (-Storing, implements -Providing)

Presentation
└── ViewModels (@Observable, @MainActor)
└── Views (SwiftUI)
└── Subviews (SplitRowView, AccountRowView, TransferRowView, ...)

Core
└── CascadeRules (cross-aggregate orchestration — Delete/Archive/Unarchive *Rule)
└── Sync (SyncManager — classic target, additive)
└── Network (NetworkMonitor, RemoteRefreshable, RefreshFromRemote, OfflineView)
└── Document (Storage upload/download, DownloadImage)
└── Graphs (ChartDataCalculator — pure, GetChartData)
└── Loader (EchoLedgerLoader, LoadingView)

App
└── DIContainer (DI — classic & cloud variants)
└── AppEntryViewModel (launch lifecycle: loading / auth / app / offline)
└── AppCoordinator (feature ViewModel ownership + navigation)
```

### Naming Conventions

| Pattern | Example |
|---|---|
| Protocol | `TransactionProviding` |
| Implementation | `TransactionStoring` |
| Local source | `TransactionLocalSource` |
| Remote source | `TransactionRemoteSource` |
| UseCase input | `AddTransactionInput` |
| Form submission DTO | `TransferFormInput` |

---

## Domain Model

### Core Entities

- **User** — application user
- **Institution** — financial institution (bank, insurance, etc.)
- **Account** — bank account linked to an institution, archivable
- **Transaction** — financial operation with amount distribution across multiple accounts via `TransactionSplit`
- **Transfer** — internal transfer between two accounts, always composed of two linked `Transaction` objects (`source` debits, `destination` credits). Wraps the pair as a single identifiable domain entity with convenience methods `sourceName(from:)` and `destinationName(from:)` for display name resolution.

### Key Business Rules

- Account balances are computed on demand (not stored)
- Accounts cannot be deleted — they are **archived** (`isArchived: true`)
- Transactions referencing an archived account remain consistent
- `GetAccounts` supports an `AccountFilter` (`.active`, `.archived`, `.all`)
- Every record carries an `updatedAt: Date?` used for sync conflict resolution
- Transfers are tagged `.transfer` on both legs and excluded from charts and reports (`isReportable`)
- `TransactionListItem.group()` merges transfer pairs by matching label + amount + same day + opposite `isExpense` before display — grouping must happen on the full transaction set, never on account-filtered subsets

---

## Implemented Features

### Phase 1 — Local (v0.1.0)

- [x] Transaction list with swipe actions (delete, edit)
- [x] Add and edit transaction with multi-account split
- [x] Transaction detail view
- [x] Account list grouped by institution
- [x] Add and edit account
- [x] Account archiving
- [x] Inline institution creation from the account form
- [x] Full local persistence via SwiftData
- [x] SwiftUI previews with seeded data (`PreviewHelpers`, `PreviewData`)
- [x] Typed error handling per domain (`TransactionError`, `AccountError`, `InstitutionError`)

### Phase 2 — Remote (v0.2.0)

- [x] Firebase Auth — email/password + anonymous demo mode (7-day limit)
- [x] Multi-user isolation — internal UUID mapped to Firebase UID for cross-device sign-in
- [x] Offline-first — local save always succeeds, remote synced separately
- [x] Additive `SyncManager` with `updatedAt`-based last-write-wins conflict resolution (deletes deferred to a tombstone-based rework — see *Targets, Data & Sync*)
- [x] Sync status UI (`SyncButton`) with error feedback and timeout (15s)
- [x] Session management — restore existing session on launch, anonymous expiry

### Phase 3 — Accounts & Transfers (v0.4.0)

- [x] Account detail view — balance, charts (expense/income by category), recent transactions
- [x] Transfer between accounts — creates a linked expense + income pair tagged `.transfer`
- [x] Transfer detail view — source/destination accounts, amount, date, description
- [x] Transfer edit and delete — both legs updated or removed atomically
- [x] `TransactionListItem` dispatcher — merges transfer pairs into a single row across all lists
- [x] `TransactionListItemView` — single entry point for all list rendering, routes to `TransactionRowView` or `TransferRowView`
- [x] Transfer grouping fix — grouping runs on the full transaction set before account filtering to ensure both legs are always visible
- [x] Bug fix — `AccountModel.update(from:)` was not persisting `institutionId`, causing institution changes to revert on next launch
- [x] Bug fix — `AccountFormViewModel` was not pre-selecting the correct institution in edit mode, silently moving accounts to the first institution in the list

### Phase 4 — Delete & Archive UX (v0.10.0)

- [x] Delete functionality for bank accounts and institutions with cascade rules
- [x] Unified archive/delete UI pattern — toggle for reversible archive, button+alert for destructive delete
- [x] Document picker architecture for PDFs and photos (`DocumentPickerSection` ViewModifier)
- [x] Delete user profile with complete data cleanup
- [x] Proper error handling in app bootstrap with toast feedback
- [x] Refactored `UserProfileViewModel` — user is non-optional, loaded before ViewModel creation
- [x] Moved user loading from lazy (views) to eager (AppEntryView.buildApp)
- [x] AppCoordinator owns `UserProfileViewModel` for proper lifecycle management
- [x] Naming consistency — "Profile" throughout (DeleteUserProfile, CreateUserProfile, etc.)
- [x] Toolbar icons for secondary actions (edit, delete) instead of large buttons

### Phase 5 — Documents & Charts

- [x] Transaction attachments (image/PDF) via Firebase Storage
- [x] User avatar — uploaded to Storage, preloaded at launch and held in the view model (no per-appearance re-fetch)
- [x] Dashboard with total balance, per-account balances, monthly flow, and category pies
- [x] Pure `ChartDataCalculator` + `GetChartData` use case (all chart math out of the view models)
- [x] Future-dated transactions excluded from displays and aggregates (`isEffective`)

### Phase 6 — Cloud target & Offline (v0.13.0+)

- [x] Cloud-only target — cache-first Firestore reads, server reload on explicit user action
- [x] `RefreshFromRemote` use case + `RemoteRefreshable` protocol — reload decoupled from sync
- [x] `NetworkMonitor` — `NWPathMonitor` interface state + active reachability ping (cache-bypassing)
- [x] Offline write guards on every cloud write (storings + Storage) — fail fast, never queue silently
- [x] Offline launch state — keeps the session and offers retry instead of signing out
- [x] Load-once-at-launch — screens read their pre-filled view models, no per-navigation loader
- [x] Guaranteed document deletion (delete file before record) + full Storage folder wipe on account deletion

### Phase 7 — Branding & polish (v0.15.0)

- [x] Adaptive color sets (`BackgroundColor`, `AccentSoft`, `AccentHard`) — full light/dark support
- [x] Gradient wordmark, shared `AppHeaderView` (logo + name) across the branded screens
- [x] Auth screen reworked — segmented Connexion/Inscription, primary CTA fills when valid, demo as secondary
- [x] Pull-to-refresh works on empty lists

### Phase 8 — Picker ergonomics, animations & test pyramid (v1.0.0)

- [x] Account pickers (transaction splits, transfer source/destination) sorted by most-recently-used instead of alphabetically (`AccountRecencySorter`)
- [x] Mutual exclusion between a transaction's splits — an account already used in another split of the same transaction is filtered out of the picker
- [x] Transfer form — swap button (⇅) between source and destination accounts
- [x] Success animation on transaction creation — a "+" rising from the add button, morphing into a checkmark, then fading out (`SuccessCheckmarkView`)
- [x] Full test pyramid completed — unit, integration, snapshot (see *Testing*) and end-to-end tests against real Firebase emulators
- [x] Code-quality pass — SonarQube-driven fixes, English-only comments, doc-comment coverage audit across the whole codebase

### Upcoming

- [ ] **Finalize `SyncManager`** — tombstones for correct cross-device deletions (Classic target)
- [ ] Swipe-to-navigate (optional)
- [ ] iPad layout support

---

## Targets, Data & Sync

The app is built as **two Xcode targets**, sharing the same Domain, UseCases and most of the Presentation layer — only the Data layer differs:

- **`EchoLedger` (Classic)** — SwiftData is the local source of truth, synced to Firestore by `SyncManager`. Offline-first: reads and writes always work locally, then sync in the background.
- **`EchoLedgerCloud` (Cloud)** — Firestore-only, no local database. Reads are **cache-first**: the on-device Firestore cache serves data instantly and works offline for consultation; an explicit *reload* warms the cache from the server. Remote writes are guarded by a real reachability check (`NetworkMonitor`) so they fail fast offline instead of being silently queued by Firestore's own offline write cache — a deliberate choice to keep write feedback honest rather than optimistic.

`EchoLedgerCloud` is the target used for the current academic delivery (simpler data flow, fully covered by the test suite below). `EchoLedger` (Classic) remains the actively maintained long-term target and is not being discontinued — the two coexist by design, sharing the same business logic through the Domain/UseCases layers.

### Reload vs Sync

- **Reload** (`RefreshFromRemote`) — pulls fresh data from the backend on an explicit user action (pull-to-refresh, launch, refresh button). Same trigger points for both targets.
- **Sync** (`SyncManager`, classic only) — reconciles local ↔ remote.

### SyncManager status

`SyncManager` is currently **additive** (last-write-wins on `updatedAt`, **no destructive deletes**), after a data-loss bug where absence was wrongly inferred as deletion. Cross-device **deletions are not yet propagated** — the real reconciliation via soft-delete **tombstones** is the main remaining work item for the Classic target. Firestore PITR (7-day retention) is enabled as a safety net in the meantime.

| Situation | Action |
|---|---|
| Local newer (`updatedAt`) | Push to remote |
| Remote newer | Pull to local |
| Both present | Most recent `updatedAt` wins |
| Missing on one side | **No delete** (additive) — pending tombstones |

Accounts are never hard-deleted (archived instead).

---

## Testing

The test suite follows a pyramid, split across three targets:

| Level | Target | Approach |
|---|---|---|
| Unit | `EchoLedgerTests` | Each UseCase tested in isolation against in-memory doubles (`AccountDouble`, `TransactionDouble`, `InstitutionDouble`, ...) — no SwiftData, no Firebase |
| Integration | `EchoLedgerTests/Integration` | Several real UseCases chained together against shared in-memory doubles (e.g. add an account, add a transaction, verify the balance) — validates that UseCases compose correctly |
| Snapshot | `EchoLedgerTests/SnapshotsTests` | Hand-rolled snapshot testing (no third-party dependency) — renders key screens to a `UIImage` and compares against a stored reference, in light/dark mode and at the smallest/largest Dynamic Type sizes |
| End-to-end | `EchoLedgerE2ETests.` | Real Firebase Auth + Firestore, run exclusively against the **local emulator suite** (`firebase.json`) — zero risk of touching production data. Covers sign-up/sign-in, anonymous-to-permanent account linking, and a full CRUD lifecycle (institution → account → transaction) |

Run unit, integration, and snapshot tests with the standard `EchoLedgerCloud` scheme (⌘U). E2E tests require the Firebase emulators running locally (`firebase emulators:start`) and use a dedicated, non-default test plan so they never run accidentally alongside the regular suite.

---

## Project Structure

```
EchoLedger/
├── App/
│   ├── EchoLedgerApp.swift
│   ├── DIContainer.swift
│   ├── DIContainer+ViewModels.swift
│   └── Navigation/
│       ├── AppEntryView.swift
│       ├── ContentView.swift
│       └── AppCoordinator.swift
├── Core/
│   ├── CascadeRules/
│   │   ├── DeleteAccountRule.swift
│   │   ├── DeleteInstitutionRule.swift
│   │   ├── DeleteUserRule.swift
│   │   ├── ArchiveInstitutionRule.swift
│   │   ├── UnarchiveInstitutionRule.swift
│   │   └── UnarchiveAccountRule.swift
│   ├── Sync/                  (Classic target only)
│   │   ├── Domain/
│   │   │   ├── SyncManager.swift
│   │   │   ├── SyncManagerProtocol.swift
│   │   │   ├── SyncStatus.swift
│   │   │   └── SyncMetadata.swift
│   │   └── Presentation/
│   │       └── SyncButton.swift
│   ├── Network/
│   │   ├── Domain/
│   │   │   ├── NetworkMonitor.swift
│   │   │   ├── RemoteRefreshable.swift
│   │   │   ├── OfflineError.swift
│   │   │   └── UseCases/RefreshFromRemote.swift
│   │   └── Presentation/OfflineView.swift
│   ├── Document/               (Storage upload/download — attachments & avatars)
│   │   ├── Domain/UseCases/
│   │   └── Presentation/
│   ├── Graphs/                 (pure chart math + presentation)
│   │   ├── Domain/ChartDataCalculator.swift, ChartModels.swift, UseCases/GetChartData.swift
│   │   └── Presentation/GraphsViewModel.swift, ExpensePieChartView.swift, MonthlyFlowChartView.swift, ...
│   ├── Animations/              (SuccessCheckmarkView, chart animators, list row transitions)
│   ├── Branding/                (AppLogoView, AppHeaderView, Color+Echo, shared styles)
│   ├── Controls/                (SegmentedToggle)
│   ├── Extensions/              (Array, Calendar, Color, Double, String, View)
│   └── Loader/
│       └── EchoLedgerLoader.swift
├── Features/
│   ├── Authentication/
│   │   ├── Domain/
│   │   │   ├── AuthSession.swift
│   │   │   ├── AuthError.swift
│   │   │   ├── AuthProviding.swift
│   │   │   └── UseCases/
│   │   ├── Data/
│   │   │   ├── AuthLocalSource.swift
│   │   │   ├── AuthRemoteSource.swift
│   │   │   └── AuthStoring.swift
│   │   └── Presentation/
│   │       ├── AuthView.swift
│   │       ├── AuthViewModel.swift
│   │       └── AuthFormContent.swift
│   ├── Transaction/
│   │   ├── Domain/
│   │   │   ├── Transaction.swift
│   │   │   ├── TransactionSplit.swift
│   │   │   ├── TransactionCategory.swift
│   │   │   ├── TransactionError.swift
│   │   │   └── UseCases/
│   │   ├── Data/
│   │   │   ├── TransactionModel.swift
│   │   │   ├── TransactionSplitModel.swift
│   │   │   ├── TransactionLocalSource.swift
│   │   │   ├── TransactionRemoteSource.swift
│   │   │   └── TransactionStoring.swift
│   │   └── Presentation/
│   │       ├── TransactionListView.swift
│   │       ├── TransactionListViewModel.swift
│   │       ├── TransactionListItem.swift
│   │       ├── TransactionListItemView.swift
│   │       ├── TransactionDetailView.swift
│   │       ├── TransactionFormView.swift
│   │       ├── TransactionFormViewModel.swift
│   │       └── Subviews/
│   │           ├── TransactionRowView.swift
│   │           └── SplitRowView.swift
│   ├── Transfer/
│   │   ├── Domain/
│   │   │   ├── Transfer.swift
│   │   │   └── UseCases/
│   │   │       ├── TransferFormInput.swift
│   │   │       ├── TransferBetweenAccounts.swift
│   │   │       ├── UpdateTransfer.swift
│   │   │       └── DeleteTransfer.swift
│   │   └── Presentation/
│   │       ├── TransferDetailView.swift
│   │       ├── TransferDetailViewModel.swift
│   │       ├── TransferFormView.swift
│   │       ├── TransferFormViewModel.swift
│   │       └── TransferRowView.swift
│   ├── Account/
│   │   ├── Domain/
│   │   │   ├── Account.swift
│   │   │   ├── AccountCategory.swift
│   │   │   ├── AccountFilter.swift
│   │   │   ├── AccountError.swift
│   │   │   └── UseCases/
│   │   ├── Data/
│   │   │   ├── AccountModel.swift
│   │   │   ├── AccountLocalSource.swift
│   │   │   ├── AccountRemoteSource.swift
│   │   │   └── AccountStoring.swift
│   │   └── Presentation/
│   │       ├── AccountListView.swift
│   │       ├── AccountListViewModel.swift
│   │       ├── AccountDetailView.swift
│   │       ├── AccountDetailViewModel.swift
│   │       ├── AccountFormView.swift
│   │       ├── AccountFormViewModel.swift
│   │       └── Subviews/
│   │           ├── AccountRowView.swift
│   │           └── RecentTransactionsView.swift
│   ├── Institution/
│   │   ├── Domain/
│   │   │   ├── Institution.swift
│   │   │   ├── InstitutionCategory.swift
│   │   │   ├── InstitutionError.swift
│   │   │   └── UseCases/
│   │   ├── Data/
│   │   │   ├── InstitutionModel.swift
│   │   │   ├── InstitutionLocalSource.swift
│   │   │   ├── InstitutionRemoteSource.swift
│   │   │   └── InstitutionStoring.swift
│   │   └── Presentation/
│   │       └── Subviews/
│   │           └── AddInstitutionFormView.swift
│   ├── User/
│   │   ├── Domain/
│   │   │   └── UseCases/
│   │   ├── Data/
│   │   │   ├── UserModel.swift
│   │   │   ├── UserLocalSource.swift
│   │   │   ├── UserRemoteSource.swift
│   │   │   └── UserStoring.swift
│   │   └── Presentation/
│   │       ├── UserProfileView.swift
│   │       └── UserProfileViewModel.swift
│   └── Dashboard/
│       └── Presentation/
│           └── DashboardView.swift
├── PreviewContent/
│   ├── PreviewData.swift
│   ├── PreviewHelpers.swift (+ PreviewHelpersCloud)
│   └── PreviewAuthStoring.swift

EchoLedgerTests/
├── Features/            (unit tests, mirrors EchoLedger/Features/)
├── Core/                 (unit tests for CascadeRules, Document, Graphs)
├── Integration/          (chained real UseCases against shared doubles)
└── SnapshotsTests/        (hand-rolled snapshot testing, see SnapshotTestCase.swift)

EchoLedgerE2ETests./     (real Firebase Auth + Firestore, emulator-only)
├── AuthE2ETests.swift
└── FirestoreLifecycleE2ETests.swift
```

---

## Getting Started

1. Clone the repository
2. Open `EchoLedger.xcodeproj`
3. Add your `GoogleService-Info.plist` (Firebase)
4. Build & Run on an iOS 18+ simulator

---

## Author

Julien Cotte — Academic project 2026
