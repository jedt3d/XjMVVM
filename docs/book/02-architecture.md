# Architecture

XjMVVM is organized around a vertical dependency rule. Higher layers can depend on lower contracts, but lower layers should not depend on windows, controls, or backend details.

[[diagram:architecture-overview|Layered architecture for a desktop-first line-of-business app.]]

## Runtime Layers

The layers have different responsibilities:

- **UI layer**: Xojo DesktopWindow, controls, menus, dialogs, and platform-specific UI behavior.
- **ViewModel layer**: user actions, page state, validation feedback, and commands.
- **Domain layer**: Customer objects and business validation.
- **Repository contract**: `ICustomerRepository` describes what persistence must do.
- **Backend adapters**: PocketBase, SQLite, direct SQL, and fake implementations.
- **Backend services**: PocketBase server, local SQLite file, or external database server.

The UI layer is allowed to be platform-specific. Everything below it should stay portable enough to be reused by a future Web, iOS, or Android presentation layer if the same Xojo language surface can support it.

## System Design

[[diagram:system-design|System design for desktop clients using local and REST backends.]]

This diagram is the production target:

- Desktop apps compose a repository at startup.
- ViewModels remain stable across backend choices.
- PocketBase is a stock executable with committed migrations.
- SQLite is a local file owned by the desktop app.
- Direct SQL is available when the deployment model allows database connectivity from the client.

## Dependency Rule

The rule is simple enough to enforce during review:

```text
Core must not import Backends.
Core must not import Composition.
Backends may import Core contracts and models.
Composition may import Core and Backends.
Desktop UI may import Composition and Core ViewModels.
```

When this rule is kept, a new repository can be added without changing the ViewModel. A new screen can be built without adding persistence code to event handlers.

## Project Shape

The main production path is:

```text
Core/
  Models/
  Repositories/
  Validation/
  ViewModels/

Backends/
  Fake/
  SQLite/
  SQL/
  PocketBase/

Composition/
  CustomerBackendSettings
  CustomerDesktopAppContext
  CustomerRepositoryFactory
```

The test project exercises the same files. The docs build quotes these files directly, so guide snippets should fail visibly if the source moves or disappears.

## Cross-Platform Meaning

The framework is desktop-first today. That does not mean the MVVM shape is desktop-only.

The portable part is the separation:

- ViewModels are written against repository contracts.
- Backend adapters are replaceable.
- UI code only binds controls to ViewModel state and commands.

That pattern can be adapted for iOS or Android front ends, but mobile may require a separate presentation project if Xojo mobile controls, async behavior, or storage APIs differ too much from desktop. Keep the repository contract and business rules shared where possible.
