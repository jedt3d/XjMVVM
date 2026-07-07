# Start Here

XjMVVM is a desktop-first Xojo application framework for line-of-business software. Its job is to make business screens easy to read, test, and change by keeping UI code away from persistence code.

The new concept to learn is **MVVM**: Model, View, ViewModel.

- **Model** is the business data and business meaning. In this guide, `Customer` is the first model.
- **View** is the Xojo desktop UI: windows, controls, menus, dialogs, and visual state.
- **ViewModel** is the screen brain. It exposes what the View needs, receives user actions, validates input, and talks to repositories.

MVVM is not a decoration pattern. It is a way to stop a desktop app from hiding business logic inside control events.

The current production direction is intentionally small:

- A shared Customer domain model.
- ViewModels that expose screen behavior without knowing the backend.
- A repository contract that every backend implements.
- Backend adapters for fake data, SQLite, generic Xojo `Database`, and PocketBase REST.
- A desktop composition root that chooses the backend at application startup.
- CI and GitHub Pages publishing so the framework is always documented from source.

That shape is the important idea. A Xojo desktop app should be able to switch from local SQLite to PocketBase REST without rewriting its list window, detail window, validation rules, or tests.

[[diagram:request-lifecycle|The basic runtime flow from user action to backend result.]]

## The Mental Model

Use this rule when reading or extending the framework:

```text
Window controls -> ViewModel -> ICustomerRepository -> backend adapter -> backend service
```

The arrow points in the direction of knowledge. A Window may know the ViewModel. A ViewModel may know `ICustomerRepository`. The repository implementation may know PocketBase, SQLite, or another database. The core ViewModel should not know which backend was selected.

This keeps the desktop app from becoming a maze of button handlers that also parse JSON, build SQL, manage API tokens, and display validation messages.

## MVVM In One Screen

Think about a Customer edit window:

| User sees | XjMVVM layer | Responsibility |
| --- | --- | --- |
| Text fields and buttons | View | Read and write control values |
| Save button behavior | ViewModel | Validate and decide whether save can happen |
| Customer fields | Model | Hold business data |
| Save/load persistence | Repository | Hide backend details |
| PocketBase/SQLite/SQL | Backend adapter | Talk to the selected storage system |

The View should be boring. It should collect input, call the ViewModel, and render output. The ViewModel should be interesting. It owns user intent in testable code.

## What MVVM Is Not

MVVM does not mean every property needs a giant binding framework. Xojo desktop apps can use a practical version:

- Controls are still controls.
- Event handlers still exist.
- A Window can still call `mDetailVM.Save(c)`.
- The important rule is that persistence and business decisions leave the Window.

This guide uses explicit Xojo code instead of magic binding so the pattern is easy to inspect.

## What To Read First

Start with these folders:

- `Core/Models`: stable business data objects.
- `Core/Validation`: business validation that should not live inside controls.
- `Core/Repositories`: backend contracts.
- `Core/ViewModels`: screen behavior and state.
- `Composition`: startup wiring for desktop apps.
- `Backends`: concrete repository adapters.
- `pocketbase`: stock PocketBase migrations and backend contract.
- `Tests`: XojoUnit coverage for core behavior and adapters.

The older `Framework`, `Models`, and `ViewModels` folders remain useful context from the previous implementation. For new production work, prefer the Customer MVVM pattern described in this guide.

## A Tiny Screen Example

A desktop window should treat controls as input and output only. The ViewModel owns the use case.

```xojo
Sub SearchField_TextChanged()
  mListVM.SearchTerm = SearchField.Text
  mListVM.LoadPage(1, 50)
  RenderCustomers(mListVM.Customers())
  StatusLabel.Text = mListVM.StatusMessage
End Sub

Private Sub RenderCustomers(rows() As Customer)
  CustomerListBox.RemoveAllRows
  For Each c As Customer In rows
    CustomerListBox.AddRow(c.FullName(), c.Email)
    CustomerListBox.RowTagAt(CustomerListBox.LastAddedRowIndex) = c.ID
  Next
End Sub
```

The example has no SQL and no HTTP. That is the point. A developer can inspect the screen behavior without also understanding the server.

Things to notice:

- The handler copies UI text into ViewModel inputs.
- `LoadPage` is the use-case call.
- Rendering is separated into `RenderCustomers`.
- The backend can change without changing the handler.

## Production Promise

For a production desktop app, XjMVVM should make these things ordinary:

- Run with fake repositories during early UI work.
- Run with SQLite for local-first or offline workflows.
- Run with PocketBase REST for authenticated multi-user sync.
- Run with a direct Xojo `Database` connection when the desktop app is allowed to talk to a database server.
- Test ViewModels without a network or database.
- Publish guide documentation from the same repository as the framework.

The rest of this guide explains how those promises are implemented and how to extend them safely.

## What Comes Next

If you are new to MVVM, read the Quick Tutorial next. It walks through the pattern in the order a developer would learn it: define a model, define a repository, build a ViewModel, bind a Window, then switch backends.

If you already build Xojo apps with SQL in Window events and `RowSet` loops, read From RowSet To MVVM after the quick tutorial. It shows how your current code maps into the design patterns used by the framework.
