# Quick Tutorial

This is a conceptual tutorial. It is written like a small guided build, but you do not need to create a new project while reading it.

The goal is to understand how an XjMVVM feature grows from business data to a desktop screen.

## Step 1: Define The Model

Start with the data the business cares about:

```xojo
Protected Class Customer
  Property ID As String
  Property FirstName As String
  Property LastName As String
  Property Email As String

  Function FullName() As String
    Var value As String = FirstName.Trim() + " " + LastName.Trim()
    Return value.Trim()
  End Function
End Class
```

Things to notice:

- The model does not know about controls.
- The model does not open a database.
- The model has only behavior that belongs to Customer itself.

## Step 2: Define The Repository Contract

The ViewModel needs Customer data, but it should not care where that data lives.

```xojo
Protected Interface ICustomerRepository
  Function FindPage(searchTerm As String, pageNumber As Integer, pageSize As Integer) As Customer()
  Function Count(searchTerm As String) As Integer
  Function FindByID(id As String) As Customer
  Function Save(customer As Customer) As Customer
  Sub Delete(id As String)
End Interface
```

Things to notice:

- This is business persistence language, not SQL language.
- There is no `PocketBaseClient` here.
- There is no `SQLiteDatabase` here.

This interface is the seam that lets the app swap fake, SQLite, REST, and direct SQL backends.

## Step 3: Write A Fake Repository First

Before building a real database adapter, use fake data to make the ViewModel and Window understandable.

```xojo
Protected Class FakeCustomerRepository
Implements ICustomerRepository
  Private mRows() As Customer

  Function FindPage(searchTerm As String, pageNumber As Integer, pageSize As Integer) As Customer()
    Var results() As Customer
    For Each c As Customer In mRows
      If searchTerm.Trim() = "" Or c.FullName().Lowercase().IndexOf(searchTerm.Lowercase()) >= 0 Then
        results.Add(c.Clone())
      End If
    Next
    Return results
  End Function
End Class
```

Things to notice:

- A fake repository is not throwaway junk. It is how you test the screen behavior quickly.
- The fake implements the same interface as production adapters.
- The ViewModel cannot tell whether data is fake or real.

## Step 4: Build The List ViewModel

Now write the code that a list window needs:

```xojo
Protected Class CustomerListViewModel
  Sub Constructor(repository As ICustomerRepository)
    mRepository = repository
  End Sub

  Sub LoadPage(pageNumber As Integer, pageSize As Integer)
    mCustomers.RemoveAll
    StatusMessage = ""

    If mRepository = Nil Then
      StatusMessage = "No customer repository"
      Return
    End If

    For Each c As Customer In mRepository.FindPage(SearchTerm, pageNumber, pageSize)
      mCustomers.Add(c)
    Next

    mTotalCount = mRepository.Count(SearchTerm)
    StatusMessage = "Loaded " + mCustomers.Count.ToString + " customer(s)"
  End Sub
End Class
```

Things to notice:

- The ViewModel receives the repository through its constructor.
- Search and paging are use-case inputs.
- The ViewModel stores status text for the View to display.
- There is still no backend-specific code.

## Step 5: Bind A Desktop Window

The Window should be a thin adapter from controls to ViewModel calls.

```xojo
Sub Opening()
  Var repo As New FakeCustomerRepository()
  mListVM = New CustomerListViewModel(repo)
  ReloadCustomers()
End Sub

Private Sub ReloadCustomers()
  mListVM.SearchTerm = SearchField.Text
  mListVM.LoadPage(1, 50)

  CustomerList.RemoveAllRows
  For Each c As Customer In mListVM.Customers()
    CustomerList.AddRow(c.FullName(), c.Email)
  Next

  StatusLabel.Text = mListVM.StatusMessage
End Sub
```

Things to notice:

- The Window does not filter rows itself.
- The Window does not know how records are loaded.
- The Window still controls visual rendering.

This practical MVVM style works well in Xojo because it keeps the code explicit.

## Step 6: Add Validation Before Save

Validation belongs near the model and ViewModel, not scattered across button handlers.

```xojo
Function Save(c As Customer) As Boolean
  Var validation As ValidationResult = CustomerValidator.Validate(c)
  If Not validation.IsValid() Then
    StatusMessage = validation.Summary()
    Return False
  End If

  mCustomer = mRepository.Save(c)
  Return mCustomer <> Nil
End Function
```

Things to notice:

- The same validation runs regardless of backend.
- The ViewModel returns a simple success/failure result.
- The Window displays the status; it does not own the rule.

## Step 7: Switch Backend At Startup

Once the ViewModel and Window work with fake data, switch the repository from one place: the composition root.

```xojo
Var settings As CustomerBackendSettings

Select Case BackendPopup.SelectedRowText
Case "Local SQLite"
  settings = CustomerBackendSettings.SQLiteFile(SpecialFolder.ApplicationData.Child("customers.sqlite"))
Case "PocketBase"
  settings = CustomerBackendSettings.PocketBase("https://api.example.com", SessionToken)
Else
  settings = CustomerBackendSettings.Fake()
End Select

App.CustomerContext = New CustomerDesktopAppContext(settings)
```

Things to notice:

- Backend choice happens at the app boundary.
- The ViewModel constructor still receives `ICustomerRepository`.
- The Window does not need a new save or search algorithm.

## Step 8: Know Where To Go Deeper

After the quick tutorial, the deeper chapters explain:

- Architecture: why the dependency direction matters.
- From RowSet To MVVM: how existing direct SQL Xojo code maps into the framework patterns.
- MVVM Core: the exact source-backed model, validator, repository, and ViewModels.
- Backend Options: how fake, SQLite, SQL, and PocketBase adapters fit.
- Desktop Composition: how a real Xojo desktop app wires the pieces.
- Testing And Publishing: how the repository proves the framework still works.

The pattern is small, but it compounds. Once one Customer screen follows it, the next screen has a path.
