# Reference Map

This chapter is a compact map for developers who already understand the pattern and need to find the right file.

## Core Files

| Area | File | Purpose |
| --- | --- | --- |
| Model | `Core/Models/Customer.xojo_code` | Customer data object |
| Validation | `Core/Validation/CustomerValidator.xojo_code` | Business validation |
| Repository contract | `Core/Repositories/ICustomerRepository.xojo_code` | Backend-independent persistence contract |
| List ViewModel | `Core/ViewModels/CustomerListViewModel.xojo_code` | Search, paging, list status |
| Detail ViewModel | `Core/ViewModels/CustomerDetailViewModel.xojo_code` | Load, validate, save |

## Backend Files

| Backend | File | Purpose |
| --- | --- | --- |
| Fake | `Backends/Fake/FakeCustomerRepository.xojo_code` | In-memory tests and early UI work |
| SQLite | `Backends/SQLite/CustomerRepositorySQLite.xojo_code` | Local file persistence |
| Generic SQL | `Backends/SQL/CustomerRepositorySQL.xojo_code` | Xojo `Database` repository |
| SQL dialect | `Backends/SQL/CustomerSQLDialect.xojo_code` | Placeholder and SQL syntax differences |
| PocketBase | `Backends/PocketBase/CustomerRepositoryPocketBase.xojo_code` | REST repository adapter |
| PocketBase auth | `Backends/PocketBase/PocketBaseAuthService.xojo_code` | Password auth and token assignment |
| PocketBase transport | `Backends/PocketBase/PocketBaseURLConnectionTransport.xojo_code` | URLConnection-backed HTTP transport |

## Composition Files

| File | Purpose |
| --- | --- |
| `Composition/CustomerBackendSettings.xojo_code` | Backend mode and connection settings |
| `Composition/CustomerRepositoryFactory.xojo_code` | Concrete repository construction |
| `Composition/CustomerDesktopAppContext.xojo_code` | Desktop app startup boundary |

## Operational Files

| File | Purpose |
| --- | --- |
| `pocketbase/pb_migrations/20260708041000_xjmvvm_production_customers.js` | PocketBase production schema and rules |
| `tools/xojo_text_scan.py` | Xojo text project scan |
| `tools/pocketbase_smoke.py` | Disposable public PocketBase smoke |
| `tools/pocketbase_production_smoke.py` | Owner-only production PocketBase smoke |
| `.github/workflows/ci.yml` | Pull request and `main` validation |
| `.github/workflows/docs-pages.yml` | GitHub Pages publication |
| `docs/book` | Guide source |
| `docs/site` | Generated static site |

## Production Readiness Checklist

Before calling a feature production-ready:

- The ViewModel is covered with fake-repository tests.
- The selected backend has adapter tests or a smoke harness.
- PocketBase rules or database permissions are verified outside the UI.
- Desktop startup chooses the backend through composition settings.
- Secrets are not committed.
- Local database files are created in writable per-user locations.
- CI passes on the pull request.
- GitHub Pages publishes the updated guide after merge.
- The Xojo project opens and tests run in the Xojo IDE.

## Extension Rule

When adding something new, ask one question first:

```text
Is this business behavior, backend behavior, composition behavior, or UI behavior?
```

Put the code in the matching layer. That one question prevents most framework drift.

## Pattern Glossary

| Pattern | Short Meaning In This Framework |
| --- | --- |
| MVVM | Windows render controls; ViewModels own screen behavior; Models hold business data |
| Repository | A business-facing persistence contract such as `ICustomerRepository` |
| Adapter | A concrete backend wrapper that makes SQLite, SQL, or PocketBase look like the repository contract |
| Data Mapper | Code that converts `RowSet` rows or PocketBase records into model objects |
| Factory | Construction helpers that build repositories and their dependencies |
| Dependency Injection | Passing repositories into ViewModel constructors instead of creating them inside ViewModels |
| Strategy | Swappable behavior such as SQL dialect placeholder rules |
| Composition Root | Startup code that chooses concrete implementations for the app |
