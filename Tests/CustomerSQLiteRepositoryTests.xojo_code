#tag Class
Protected Class CustomerSQLiteRepositoryTests
Inherits TestGroup
	#tag Method, Flags = &h21
		Private Function NewRepository() As CustomerRepositorySQLite
		  Var db As New SQLiteDatabase()
		  db.Connect()

		  Var repo As New CustomerRepositorySQLite(db, True)
		  repo.EnsureSchema()
		  Return repo
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Seed(repo As CustomerRepositorySQLite)
		  Call repo.Save(New Customer("Ada", "Lovelace", "ada@example.com"))
		  Call repo.Save(New Customer("Grace", "Hopper", "grace@example.com"))
		  Call repo.Save(New Customer("Katherine", "Johnson", "katherine@example.com"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteRemovesCustomerTest()
		  Var repo As CustomerRepositorySQLite = NewRepository()
		  Seed(repo)

		  repo.Delete("2")

		  Assert.IsNil(repo.FindByID("2"), "Deleted customer should not be returned")
		  Assert.IsTrue(repo.Count("") = 2, "Repository should contain two remaining customers")
		  repo.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FindByIDReturnsSavedCustomerTest()
		  Var repo As CustomerRepositorySQLite = NewRepository()
		  Var saved As Customer = repo.Save(New Customer("Ada", "Lovelace", "ada@example.com"))

		  Var found As Customer = repo.FindByID(saved.ID)

		  Assert.IsNotNil(found)
		  Assert.AreEqual("Ada", found.FirstName)
		  Assert.AreEqual("Lovelace", found.LastName)
		  repo.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FindPageSearchesCustomersTest()
		  Var repo As CustomerRepositorySQLite = NewRepository()
		  Seed(repo)

		  Var customers() As Customer = repo.FindPage("grace", 1, 10)

		  Assert.IsTrue(CType(customers.Count, Integer) = 1, "Search should narrow the result set")
		  Assert.AreEqual("Hopper", customers(0).LastName)
		  Assert.IsTrue(repo.Count("grace") = 1, "Count should respect the same search term")
		  repo.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ListViewModelLoadsFromSQLiteTest()
		  Var repo As CustomerRepositorySQLite = NewRepository()
		  Seed(repo)
		  Var vm As New CustomerListViewModel(repo)

		  vm.LoadPage(1, 2)
		  Var customers() As Customer = vm.Customers()

		  Assert.IsTrue(CType(customers.Count, Integer) = 2, "ViewModel should page through SQLite repository")
		  Assert.IsTrue(vm.TotalCount() = 3, "ViewModel should use SQLite repository count")
		  repo.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveAssignsStringIDTest()
		  Var repo As CustomerRepositorySQLite = NewRepository()

		  Var saved As Customer = repo.Save(New Customer("Grace", "Hopper", "grace@example.com"))

		  Assert.IsNotNil(saved)
		  Assert.IsTrue(saved.ID.Trim() <> "", "SQLite repository should stringify the row ID")
		  Assert.IsTrue(repo.Count("") = 1, "Repository should contain the saved customer")
		  repo.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateExistingCustomerTest()
		  Var repo As CustomerRepositorySQLite = NewRepository()
		  Var saved As Customer = repo.Save(New Customer("Ada", "Lovelace", "ada@example.com"))
		  saved.LastName = "Byron"

		  Var updated As Customer = repo.Save(saved)

		  Assert.IsNotNil(updated)
		  Assert.AreEqual(saved.ID, updated.ID)
		  Assert.AreEqual("Byron", updated.LastName)
		  Assert.IsTrue(repo.Count("") = 1, "Update should not create another row")
		  repo.Close()
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Duration"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FailedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeGroup"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsRunning"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="NotImplementedCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PassedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SkippedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="StopTestOnFail"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
