# Worked Example

This chapter is a conceptual example app called **Customer Desk**. It is not a separate project; it is a guided walkthrough of how a developer would use XjMVVM to build a small desktop line-of-business feature.

## The App

Customer Desk has four user workflows:

- Search customers.
- Create a customer.
- Edit a customer.
- Switch between local SQLite and PocketBase REST.

That is enough to exercise MVVM without drowning the developer in screens.

## Code Structure

The feature is split by responsibility:

```text
CustomerDesk/
  Windows/
    CustomerListWindow
    CustomerEditWindow
    LoginWindow
  App/
    StartupSettings
    CurrentSession

XjMVVM framework/
  Core/Models/Customer
  Core/ViewModels/CustomerListViewModel
  Core/ViewModels/CustomerDetailViewModel
  Composition/CustomerDesktopAppContext
  Backends/SQLite/CustomerRepositorySQLite
  Backends/PocketBase/CustomerRepositoryPocketBase
```

The app owns windows and user preferences. The framework owns the MVVM and backend contracts.

## Opening The App

At startup, Customer Desk chooses the safest available backend.

```xojo
Sub AppOpening()
  Var settings As CustomerBackendSettings

  If Preferences.UseServer And Preferences.LastToken <> "" Then
    settings = CustomerBackendSettings.PocketBase(Preferences.ServerURL, Preferences.LastToken)
  Else
    Var dbFile As FolderItem = SpecialFolder.ApplicationData.Child("CustomerDesk").Child("customers.sqlite")
    settings = CustomerBackendSettings.SQLiteFile(dbFile)
  End If

  CustomerContext = New CustomerDesktopAppContext(settings)
End Sub
```

What this teaches:

- Startup is where environment decisions belong.
- Local fallback can be explicit.
- The rest of the app asks `CustomerContext` for ViewModels.

## Search Customers

The list window owns the list control, but not the search algorithm.

```xojo
Sub SearchField_TextChanged()
  ReloadPage(1)
End Sub

Private Sub ReloadPage(pageNumber As Integer)
  mListVM.SearchTerm = SearchField.Text
  mListVM.LoadPage(pageNumber, 50)

  CustomerList.RemoveAllRows
  For Each c As Customer In mListVM.Customers()
    CustomerList.AddRow(c.FullName(), c.Email)
    CustomerList.RowTagAt(CustomerList.LastAddedRowIndex) = c.ID
  Next

  StatusLabel.Text = mListVM.StatusMessage
End Sub
```

What this teaches:

- The Window still controls rendering.
- The ViewModel controls the use case.
- Search can be backed by fake arrays, SQLite `LIKE`, SQL predicates, or PocketBase filters.

## Edit Customer

The edit window converts controls into a model, then asks the ViewModel to save.

```xojo
Sub SaveButton_Pressed()
  Var c As New Customer(FirstNameField.Text, LastNameField.Text, EmailField.Text)
  c.ID = mCustomerID
  c.OwnerID = App.CurrentSession.UserID
  c.DateOfBirth = BirthDateField.Text
  c.Gender = GenderPopup.SelectedRowText

  If Not mDetailVM.Save(c) Then
    ErrorLabel.Text = mDetailVM.StatusMessage
    Return
  End If

  Self.Close()
End Sub
```

What this teaches:

- Validation and persistence are not inside the button event.
- `OwnerID` is part of the model so local and server storage can share meaning.
- The ViewModel can be tested without the edit window.

## Login And Switch To PocketBase

PocketBase login creates a session token. After login, the app replaces the context.

```xojo
Sub LoginButton_Pressed()
  Var transport As New PocketBaseURLConnectionTransport(30)
  Var client As New PocketBaseClient(ServerURLField.Text, transport)
  Var auth As New PocketBaseAuthService(client)

  Var session As PocketBaseAuthSession
  session = auth.AuthWithPassword(EmailField.Text, PasswordField.Text)

  If Not session.IsAuthenticated() Then
    ErrorLabel.Text = auth.LastError().Message
    Return
  End If

  If App.CustomerContext <> Nil Then App.CustomerContext.Close()
  App.CustomerContext = New CustomerDesktopAppContext( _
    CustomerBackendSettings.PocketBase(ServerURLField.Text, session.Token))
End Sub
```

What this teaches:

- Login is an app/session concern.
- The PocketBase token stays out of the ViewModel.
- Switching backend does not rewrite list or edit windows.

## Offline And Sync Boundaries

This framework currently supports choosing SQLite or PocketBase. It does not yet implement automatic offline sync between them.

If Customer Desk needs sync, treat it as a separate feature:

- Define conflict rules.
- Track local changes.
- Track server record versions.
- Add sync use cases outside the Window.
- Test conflict behavior with fixtures.

Do not hide sync inside `SaveButton_Pressed`.

## Adding The Next Feature

For Orders, Invoices, Inventory, or Appointments, repeat the same vertical slice:

```text
Model -> Validator -> Repository interface -> ViewModel -> Fake repo -> real backend adapters -> composition -> Window
```

Build the first screen against a fake repository. Add SQLite or PocketBase after the ViewModel behavior is clear.

## What The Example Proves

Customer Desk proves the core claim of XjMVVM:

- A desktop screen can stay readable.
- Business behavior can be tested away from controls.
- Backends can change at startup.
- PocketBase REST and SQLite can support the same ViewModels.
- The app can grow feature by feature without turning every Window into a miniature backend.
