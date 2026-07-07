#tag Class
Protected Class CustomerDesktopAppContextTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub DirectSQLContextSharesRepositoryAcrossViewModelsTest()
		  Var db As New SQLiteDatabase()
		  db.Connect()
		  Var context As New CustomerDesktopAppContext(CustomerBackendSettings.SQL(db, CustomerSQLDialect.SQLite(), True))

		  Var detail As CustomerDetailViewModel = context.DetailViewModel()
		  Var saved As Boolean = detail.Save(New Customer("Grace", "Hopper", "grace@example.com"))
		  Var list As CustomerListViewModel = context.ListViewModel()
		  list.LoadPage(1, 10)

		  Assert.IsTrue(saved, "Detail view model should save through the direct SQL context")
		  Assert.AreEqual(1, CType(list.Customers().Count, Integer), "List view model should see the same repository")
		  Assert.IsTrue(context.StatusMessage.IndexOf("direct SQL") >= 0, "Context should report the selected backend")
		  context.Close()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FakeContextSharesRepositoryAcrossViewModelsTest()
		  Var context As New CustomerDesktopAppContext(CustomerBackendSettings.Fake())

		  Var detail As CustomerDetailViewModel = context.DetailViewModel()
		  Var saved As Boolean = detail.Save(New Customer("Ada", "Lovelace", "ada@example.com"))
		  Var list As CustomerListViewModel = context.ListViewModel()
		  list.LoadPage(1, 10)

		  Assert.IsTrue(saved, "Detail view model should save through the fake context")
		  Assert.AreEqual(1, CType(list.Customers().Count, Integer), "List view model should see the same repository")
		  Assert.IsTrue(context.StatusMessage.IndexOf("fake") >= 0, "Context should report the selected backend")
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
