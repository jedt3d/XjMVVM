# Desktop Composition

The composition root is the place where the desktop app becomes concrete. It chooses the repository and creates ViewModels.

[[diagram:desktop-composition|Startup and shutdown lifecycle for a desktop app using XjMVVM.]]

## App Context

`CustomerDesktopAppContext` is intentionally small. It receives settings, builds one repository, and hands ViewModels to the UI.

[[snippet:Composition/CustomerDesktopAppContext.xojo_code:3-64|CustomerDesktopAppContext configures the selected backend and creates ViewModels.]]

This pattern prevents every Window from constructing its own backend client.

## Suggested Desktop Startup

In a real desktop app, build the context once during startup or after login:

```xojo
Sub Opening()
  Var dbFile As FolderItem = SpecialFolder.ApplicationData.Child("XjMVVM").Child("customers.sqlite")
  Var settings As CustomerBackendSettings = CustomerBackendSettings.SQLiteFile(dbFile)

  mCustomerContext = New CustomerDesktopAppContext(settings)
  System.DebugLog(mCustomerContext.StatusMessage)
End Sub
```

After a successful PocketBase login, the same app can switch to the REST backend:

```xojo
Sub UseServerBackend(session As PocketBaseAuthSession)
  Var settings As CustomerBackendSettings
  settings = CustomerBackendSettings.PocketBase("https://api.example.com", session.Token, "customers", 30)

  If mCustomerContext <> Nil Then mCustomerContext.Close()
  mCustomerContext = New CustomerDesktopAppContext(settings)
End Sub
```

## Window Binding

Create ViewModels from the app context:

```xojo
Sub CustomerListWindow_Opening()
  mListVM = App.CustomerContext.ListViewModel()
  mListVM.LoadPage(1, 50)
  RenderCustomers(mListVM.Customers())
End Sub
```

For an edit window:

```xojo
Sub CustomerEditor_Opening(customerID As String)
  mDetailVM = App.CustomerContext.DetailViewModel()
  mDetailVM.Load(customerID)

  Var c As Customer = mDetailVM.Current()
  If c <> Nil Then
    FirstNameField.Text = c.FirstName
    LastNameField.Text = c.LastName
    EmailField.Text = c.Email
  End If
End Sub
```

## Shutdown

Call `Close()` when the app changes backend or quits. This lets SQLite and direct SQL repositories close owned connections.

```xojo
Sub Closing()
  If mCustomerContext <> Nil Then
    mCustomerContext.Close()
    mCustomerContext = Nil
  End If
End Sub
```

That lifecycle matters in cross-platform desktop apps because file locks and connection cleanup differ by operating system.
