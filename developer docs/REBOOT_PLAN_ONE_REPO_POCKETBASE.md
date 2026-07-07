# XjMVVM Reboot Plan: One Repository, PocketBase Backend

Status: planning baseline
Date: 2026-07-07

This plan supersedes a gradual refactor of the current XjMVVM SSR web
framework. The current code remains useful as reference material, but the
production target is a fresh MVVM framework for Xojo line-of-business
applications.

## Locked Direction

- Keep one Git repository if possible.
- Start fresh rather than preserving the current SSR/router design as the core.
- Treat old XjMVVM work as legacy/reference material that can be squashed into a
  clean reboot baseline when implementation starts.
- Use original PocketBase as the preferred REST backend.
- Do not use PocketPod for this framework plan; PocketPod belongs to the Dart
  side.
- Keep direct database, REST, and local SQLite access behind repository
  interfaces so ViewModels stay platform-neutral.
- Keep JinjaX optional for reports, printable/exportable HTML, email templates,
  generated documentation, and optional server-rendered companion surfaces.

## Repository Shape

One repository does not have to mean one Xojo project file. Desktop and mobile
targets may need separate `.xojo_project` files because Xojo app types differ,
but they should share the same core source folders.

Recommended target layout:

```text
XjMVVM/
  Core/
    Models/
    DTOs/
    Validation/
    ViewModels/
    Services/
    Repositories/
  Backends/
    PocketBase/
    SQLiteLocal/
    DirectDatabase/
  Desktop/
    XjMVVMDesktop.xojo_project
    Views/
    AppShell/
  Mobile/
    XjMVVMMobile.xojo_project
    Screens/
    AppShell/
  ServerContracts/
    PocketBase/
    schemas/
    smoke/
  Samples/
    CustomerDesktop/
    CustomerMobile/
  Tests/
  docs/
```

If one Xojo project can safely host all targets, use it. If not, keep one Git
repository with shared source and separate project files.

## Target Architecture

```text
Desktop View / Mobile Screen
  -> ViewModel
  -> Application Service
  -> Repository Interface
  -> PocketBase REST Repository
     SQLite Local Repository
     Direct Database Repository
  -> Model / DTO / Validation Result
```

The ViewModel should never know whether data came from PocketBase, SQLite, or a
direct database call. The View chooses controls and layout; the ViewModel owns
state, commands, validation, loading, and error messages; repositories own all
I/O.

## PocketBase Backend Strategy

PocketBase should be treated as an external, compatible backend process, not as
code to fork first. The first milestone should use the stock PocketBase
executable and its normal REST API, auth, admin dashboard, SQLite storage, and
migration flow.

The Xojo framework should provide:

- `PocketBaseClient`: base URL, timeout, headers, request/response execution.
- `PocketBaseAuthProvider`: login, logout, token/session persistence, refresh if
  supported by the chosen PocketBase auth flow.
- `PocketBaseRecordMapper`: converts backend JSON into Xojo DTOs/models.
- `PocketBaseQuery`: paging, sort, filter, and expand options without exposing
  backend syntax to ViewModels.
- `PocketBaseErrorMapper`: converts HTTP and backend errors into user-safe
  validation/status results.
- `PocketBaseRepositoryBase`: reusable CRUD behavior for domain repositories.

The first implementation should not require backend code changes. It should
prove that PocketBase can run as-is, expose the needed collections/resources,
and support Xojo desktop/mobile clients over REST.

## SQLite Local Strategy

SQLite should be a first-class local repository for mobile and offline-friendly
desktop workflows.

Use cases:

- mobile local cache,
- offline draft capture,
- lookup/reference data stored on device,
- queue of pending changes for later sync,
- standalone small-business desktop deployment.

Do not let mobile apps connect directly to PostgreSQL, MySQL, or server-side
databases. Mobile should use REST for server data and SQLite for local storage.

## Direct Database Strategy

Direct database repositories remain useful for desktop line-of-business apps
running on trusted internal networks or local deployments.

They should be adapters, not a special architecture:

- `CustomerRepositoryDirectDatabase`
- `CustomerRepositoryPocketBase`
- `CustomerRepositorySQLiteLocal`

All must satisfy the same repository interface and return the same model/result
types.

## First Production Vertical Slice

Build a Customer module first because `customer-mvvm` already demonstrates the
clearer MVVM separation.

Minimum slice:

- `Customer` model/DTO.
- `CustomerValidation`.
- `ICustomerRepository`.
- `CustomerListViewModel`.
- `CustomerDetailViewModel`.
- fake in-memory repository for ViewModel tests.
- PocketBase REST repository.
- SQLite local repository.
- simple desktop Customer list/detail sample.
- optional mobile Customer list/detail sample after desktop is stable.

## Verification Gates

The reboot is real only when these proof points pass:

1. Shared ViewModel tests pass against a fake repository.
2. The same Customer ViewModels run with PocketBase REST and SQLite
   repositories.
3. PocketBase runs as-is and passes a smoke test for auth, list, create, update,
   delete, paging, filtering, and expected error cases.
4. SQLite local repository passes create/read/update/delete and migration tests.
5. Desktop sample opens in Xojo, analyzes cleanly, and performs Customer CRUD.
6. Mobile sample, if included in the milestone, uses the same core contracts and
   either REST or local SQLite without direct server database access.
7. JinjaX report/export rendering is demonstrated without becoming a required UI
   layer.

## Risks To Resolve Before Coding

- Pin the PocketBase version and API contract before generating repository code.
- Define the first PocketBase collections, auth model, access rules, indexes,
  file fields, and migration ownership.
- Decide whether the repo should archive the legacy SSR implementation in-place,
  move it under `Legacy/`, or replace it on a new branch with history preserved
  by Git.
- Confirm Xojo project-file sharing strategy for desktop and mobile targets.
- Confirm token storage expectations for macOS, Windows, Linux, iOS, and
  Android.

## Recommended Next Step

Create a fresh branch or clean baseline commit that introduces only the new
folder structure, contracts, and Customer vertical-slice test scaffold. Keep the
first slice boring and verifiable: no router, no SSR, no template rendering in
the core path, and no backend customization until the PocketBase compatibility
smoke test proves the REST contract.
