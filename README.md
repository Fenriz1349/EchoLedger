# EchoLedger

![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![iOS](https://img.shields.io/badge/iOS-18%2B-blue?logo=apple)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)
![SwiftData](https://img.shields.io/badge/Persistence-SwiftData-purple)
![Firebase](https://img.shields.io/badge/Backend-Firebase-yellow?logo=firebase)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green)
![Version](https://img.shields.io/badge/Version-0.4.0-blue)
![License](https://img.shields.io/badge/License-Academic-lightgrey)

A personal finance tracking iOS app built as a school project. The primary goal is learning and applying **Clean Architecture with a UseCase pattern**, local persistence via **SwiftData**, and remote storage via **Firebase**.

---

## Tech Stack

| Component | Technology |
|---|---|
| Language | Swift 6 |
| UI | SwiftUI (iOS 18+) |
| Observability | `@Observable` (not `ObservableObject`) |
| Local persistence | SwiftData |
| Remote backend | Firebase Auth + Firestore |
| Dependency injection | `DIContainer` |
| Navigation | `AppCoordinator` |

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
└── Sync (SyncManager — bidirectional, offline-first)
└── Loader (EchoLedgerLoader)

App
└── DIContainer (single source of truth for DI)
└── AppCoordinator (navigation + ViewModel ownership)
└── AppEntryView (session resolution + phase management)
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
- [x] Bidirectional `SyncManager` with `updatedAt`-based last-write-wins conflict resolution
- [x] Delete detection via `lastSyncDate` pivot (no tombstone required)
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

### Phase 4 — Upcoming

- [ ] Dashboard with account balances and recent transactions
- [ ] Archived accounts view with unarchive support
- [ ] iPad layout support

---

## Sync Architecture

`SyncManager` implements a **bidirectional offline-first sync** between SwiftData and Firestore:

| Situation | Action |
|---|---|
| Local only, `updatedAt` > last sync | Push to remote |
| Local only, `updatedAt` ≤ last sync | Deleted on remote → delete locally |
| Remote only, `updatedAt` > last sync | Pull to local |
| Remote only, `updatedAt` ≤ last sync | Deleted locally → delete on remote |
| Both sides present | Most recent `updatedAt` wins |
| `updatedAt` nil (legacy) | Remote wins, no delete logic applied |

Accounts are never hard-deleted (archived instead), so delete detection is skipped for them.

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
│   ├── Sync/
│   │   ├── Domain/
│   │   │   ├── SyncManager.swift
│   │   │   ├── SyncManagerProtocol.swift
│   │   │   ├── SyncStatus.swift
│   │   │   └── SyncMetadata.swift
│   │   └── Presentation/
│   │       └── SyncButton.swift
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
│   ├── PreviewHelpers.swift
│   └── PreviewAuthStoring.swift
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
