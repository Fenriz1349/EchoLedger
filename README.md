# EchoLedger

![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![iOS](https://img.shields.io/badge/iOS-18%2B-blue?logo=apple)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)
![SwiftData](https://img.shields.io/badge/Persistence-SwiftData-purple)
![Firebase](https://img.shields.io/badge/Backend-Firebase-yellow?logo=firebase)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green)
![Status](https://img.shields.io/badge/Status-Phase%201%20Complete-brightgreen)
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
└── Entities (Transaction, Account, Institution, User)
└── UseCases (AddTransaction, GetAccounts, ArchiveAccount, ...)
└── Protocols (-Providing)

Data
└── Local (SwiftData — -LocalSource, -Model)
└── Remote (Firebase — -RemoteSource, -Remote)
└── Storings (-Storing, implements -Providing)

Presentation
└── ViewModels (@Observable, @MainActor)
└── Views (SwiftUI)
└── Subviews (SplitRowView, AccountRowView, ...)

App
└── DIContainer (single source of truth for DI)
└── AppCoordinator (navigation + ViewModel ownership)
```

### Naming Conventions

| Pattern | Example |
|---|---|
| Protocol | `TransactionProviding` |
| Implementation | `TransactionStoring` |
| Local source | `TransactionLocalSource` |
| Remote source | `TransactionRemoteSource` |
| Remote struct | `TransactionRemote` |
| UseCase input | `AddTransactionInput` |

---

## Domain Model

### Core Entities

- **User** — application user
- **Institution** — financial institution (bank, insurance, etc.)
- **Account** — bank account linked to an institution, archivable
- **Transaction** — financial operation with amount distribution across multiple accounts via `TransactionSplit`

### Key Business Rules

- Account balances are computed on demand (not stored)
- Accounts cannot be deleted — they are **archived** (`isArchived: true`)
- Transactions referencing an archived account remain consistent
- `GetAccounts` supports an `AccountFilter` (`.active`, `.archived`, `.all`)

---

## Implemented Features (Phase 1 — Local)

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

---

## Upcoming Features (Phase 2 — Remote)

- [ ] Firebase save (offline-first) + `SyncManager` with timestamp-based sync
- [ ] Firebase authentication (email/password)
- [ ] Dashboard with balances and recent transactions
- [ ] Archived accounts view with unarchive support
- [ ] iPad layout support
- [ ] Account detail view
- [ ] Date picker in `TransactionFormView`
- [ ] Global error handling and alerts

---

## Project Structure

```
EchoLedger/
├── App/
│   ├── EchoLedgerApp.swift
│   ├── AppDelegate.swift
│   ├── DIContainer.swift
│   ├── DIContainer+ViewModels.swift
│   └── Navigation/
│       └── AppCoordinator.swift
├── Features/
│   ├── Transaction/
│   │   ├── Domain/
│   │   │   ├── Transaction.swift
│   │   │   ├── TransactionSplit.swift
│   │   │   ├── TransactionCategory.swift
│   │   │   └── TransactionError.swift
│   │   ├── Data/
│   │   │   ├── TransactionModel.swift
│   │   │   ├── TransactionLocalSource.swift
│   │   │   └── TransactionStoring.swift
│   │   └── Presentation/
│   │       ├── TransactionListView.swift
│   │       ├── TransactionListViewModel.swift
│   │       ├── TransactionDetailView.swift
│   │       ├── TransactionFormView.swift
│   │       ├── TransactionFormViewModel.swift
│   │       └── Subviews/
│   │           ├── SplitRowView.swift
│   │           └── AccountPickerView.swift
│   ├── Account/
│   │   ├── Domain/
│   │   │   ├── Account.swift
│   │   │   ├── AccountCategory.swift
│   │   │   ├── AccountFilter.swift
│   │   │   └── AccountError.swift
│   │   ├── Data/
│   │   │   ├── AccountModel.swift
│   │   │   ├── AccountLocalSource.swift
│   │   │   └── AccountStoring.swift
│   │   └── Presentation/
│   │       ├── AccountListView.swift
│   │       ├── AccountListViewModel.swift
│   │       ├── AccountFormView.swift
│   │       ├── AccountFormViewModel.swift
│   │       └── Subviews/
│   │           └── AccountRowView.swift
│   └── Institution/
│       ├── Domain/
│       │   ├── Institution.swift
│       │   ├── InstitutionType.swift
│       │   └── InstitutionError.swift
│       ├── Data/
│       │   ├── InstitutionModel.swift
│       │   ├── InstitutionLocalSource.swift
│       │   └── InstitutionStoring.swift
│       └── Presentation/
│           └── Subviews/
│               └── AddInstitutionFormView.swift
├── Shared/
│   ├── Extensions/
│   │   ├── Double+Euro.swift
│   │   └── String+Double.swift
│   └── Preview/
│       ├── PreviewData.swift
│       └── PreviewHelpers.swift
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
