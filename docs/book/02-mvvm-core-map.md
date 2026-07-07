# MVVM Core Map

The reboot should keep the codebase readable in the style of `customer-mvvm`,
but aim it at production desktop and future mobile applications.

The core dependency direction is:

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

The ViewModel should expose state and commands. It should not know whether a
record came from PocketBase, SQLite, or a direct database connection.

## Shared Core

The first shared core should be boring and testable:

- `Customer`
- `CustomerValidation`
- `ICustomerRepository`
- `CustomerListViewModel`
- `CustomerDetailViewModel`
- fake in-memory repository for tests

Only after that works should the production adapters be added.

## Platform Adapters

Desktop can support direct database repositories for trusted internal
deployments and PocketBase REST repositories for server-backed deployments.

Mobile should use PocketBase REST for server data and SQLite for local cache,
offline drafts, and sync queues. Mobile should not connect directly to
PostgreSQL, MySQL, or server-side databases.

