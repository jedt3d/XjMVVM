# Desktop App Integration

Cycle 7 adds a small desktop-facing composition layer. It does not turn the
current Web2 sample project into a desktop UI yet; instead, it creates the app
boundary a future Xojo Desktop project can call during startup.

## New Composition Classes

- `CustomerBackendSettings` describes which Customer backend the app wants.
- `CustomerDesktopAppContext` builds one shared repository and creates
  `CustomerListViewModel` and `CustomerDetailViewModel` instances from it.

The context supports these backend modes:

- `fake` for tests, previews, and design-time screens
- `sqlite-file` for local/offline desktop storage
- `sql` for direct database connections supplied by the app
- `pocketbase` for stock PocketBase REST backends

## Desktop Startup Shape

A desktop target can keep its window and control code thin:

```text
Var settings As CustomerBackendSettings
settings = CustomerBackendSettings.PocketBase(baseURL, token)

Var appContext As New CustomerDesktopAppContext(settings)
Var listVM As CustomerListViewModel = appContext.ListViewModel()
Var detailVM As CustomerDetailViewModel = appContext.DetailViewModel()
```

The window remains responsible for controls, selection, dialogs, and secure
token storage. The context owns only backend composition and view-model
construction.

## Lifecycle

`CustomerDesktopAppContext.Close()` closes repositories that own their database
connection. That gives long-running line-of-business desktop apps a single
place to release local files or direct database connections when a window,
session, or app shuts down.

## Verification

`CustomerDesktopAppContextTests` proves that fake and direct-SQL contexts share
one repository across detail and list view models. The test saves through the
detail view model and then loads through the list view model.

The remaining production proof is a real desktop window smoke test once the
target desktop project file exists.
