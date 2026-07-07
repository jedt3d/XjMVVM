#tag Class
Protected Class CustomerRepositorySQLTests
Inherits TestGroup
	#tag Method, Flags = &h21
		Private Function NewRepository() As CustomerRepositorySQL
		  Var db As New SQLiteDatabase()
		  db.Connect()

		  Var repo As New CustomerRepositorySQL(db, CustomerSQLDialect.SQLite(), True)
		  repo.EnsureSchema()
		  Return repo
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Seed(repo As CustomerRepositorySQL)
		  Call repo.Save(New Customer("Ada", "Lovelace", "ada@example.com"))
		  Call repo.Save(New Customer("Grace", "Hopper", "grace@example.com"))
		  Call repo.Save(New Customer("Katherine", "Johnson", "katherine@example.com"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteRemovesCustomerTest()
		  Var repo As CustomerRepositorySQL = NewRepository()
		  Var saved As Customer = repo.Save(New Customer("Ada", "Lovelace", "ada@example.com"))

		  repo.Delete(saved.ID)

		  Assert.IsNil(repo.FindByID(saved.ID), "Deleted customer should not be returned")
		  Assert.IsTrue(repo.Count("") = 0, "Repository should not contain deleted customers")
		  repo.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FindPageSearchesCustomersTest()
		  Var repo As CustomerRepositorySQL = NewRepository()
		  Seed(repo)

		  Var customers() As Customer = repo.FindPage("grace", 1, 10)

		  Assert.AreEqual(1, CType(customers.Count, Integer), "Search should narrow the result set")
		  Assert.AreEqual("Hopper", customers(0).LastName)
		  Assert.IsTrue(repo.Count("grace") = 1, "Count should respect the same search term")
		  repo.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveAssignsGeneratedStringIDAndOwnerTest()
		  Var repo As CustomerRepositorySQL = NewRepository()
		  Var customer As New Customer("Grace", "Hopper", "grace@example.com")
		  customer.OwnerID = "user123"

		  Var saved As Customer = repo.Save(customer)
		  Var found As Customer = repo.FindByID(saved.ID)

		  Assert.IsNotNil(saved)
		  Assert.IsTrue(saved.ID.Left(1) = "c", "Direct SQL repository should generate a string ID")
		  Assert.IsNotNil(found)
		  Assert.AreEqual("user123", found.OwnerID)
		  repo.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateExistingCustomerTest()
		  Var repo As CustomerRepositorySQL = NewRepository()
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
