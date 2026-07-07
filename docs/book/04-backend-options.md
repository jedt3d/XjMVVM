# Backend Options

XjMVVM supports several persistence choices behind the same `ICustomerRepository` contract.

[[diagram:backend-selection|How backend settings become the concrete Customer repository.]]

## Choosing A Backend

Use **fake** when designing screens or testing ViewModels.

Use **SQLite file** when the app needs local storage, offline work, or a single-user desktop database.

Use **PocketBase REST** when the app needs authenticated users, server-side access rules, and a simple deployable backend.

Use **direct SQL** when the desktop app is deployed in an environment where direct database access is acceptable and controlled.

## Backend Settings

`CustomerBackendSettings` is the value object that names the backend mode and carries the required connection inputs.

[[snippet:Composition/CustomerBackendSettings.xojo_code:3-49|Factories for fake, PocketBase, direct SQL, and SQLite-file settings.]]

This keeps startup code readable:

```xojo
Var settings As CustomerBackendSettings

If UseServerCheckBox.Value Then
  settings = CustomerBackendSettings.PocketBase(ServerURLField.Text, SessionToken)
Else
  settings = CustomerBackendSettings.SQLiteFile(SpecialFolder.ApplicationData.Child("customers.sqlite"))
End If

mAppContext = New CustomerDesktopAppContext(settings)
```

The Window chooses a setting. The composition root builds the repository.

## Repository Factory

The factory creates concrete adapters and ensures local database schemas when needed.

[[snippet:Composition/CustomerRepositoryFactory.xojo_code:1-39|Factory methods for each Customer repository adapter.]]

Notice that `NewSQLite` and `NewSQL` call `EnsureSchema()`. That is convenient for samples and small desktop deployments. In larger production deployments, schema changes should be controlled by migrations and deployment scripts.

## Adapter Responsibilities

Every adapter must:

- Implement `ICustomerRepository`.
- Return `Nil` or empty arrays predictably on failures the ViewModel can display.
- Keep backend-specific parsing, SQL, HTTP, or token behavior inside the adapter layer.
- Avoid changing ViewModel behavior for a backend-specific convenience.
- Be covered by either XojoUnit tests or smoke tooling.

When adding an adapter, start with `FindPage`, `Count`, `FindByID`, `Save`, and `Delete`. Do not add new interface methods until at least two adapters need the same behavior.
