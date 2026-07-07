#tag Class
Protected Class CustomerRepositoryFactoryTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub NewFakeReturnsWorkingRepositoryTest()
		  Var repo As FakeCustomerRepository = CustomerRepositoryFactory.NewFake()

		  Var saved As Customer = repo.Save(New Customer("Ada", "Lovelace", "ada@example.com"))

		  Assert.IsNotNil(saved)
		  Assert.IsTrue(repo.Count("") = 1, "Fake factory repository should save customers")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NewPocketBaseReturnsRepositoryTest()
		  Var repo As CustomerRepositoryPocketBase = CustomerRepositoryFactory.NewPocketBase("http://127.0.0.1:8090", "token")

		  Assert.IsNotNil(repo)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NewSQLiteReturnsWorkingRepositoryTest()
		  Var db As New SQLiteDatabase()
		  db.Connect()
		  Var repo As CustomerRepositorySQLite = CustomerRepositoryFactory.NewSQLite(db)

		  Var saved As Customer = repo.Save(New Customer("Grace", "Hopper", "grace@example.com"))

		  Assert.IsNotNil(saved)
		  Assert.IsTrue(repo.Count("") = 1, "SQLite factory repository should save customers")
		  db.Close()
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
