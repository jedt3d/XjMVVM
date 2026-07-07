#tag Class
Protected Class CustomerDesktopAppContext
	#tag Method, Flags = &h0
		Sub Constructor(settings As CustomerBackendSettings)
		  If settings = Nil Then
		    mSettings = CustomerBackendSettings.Fake()
		  Else
		    mSettings = settings
		  End If

		  ConfigureRepository()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Close()
		  If mRepository IsA CustomerRepositorySQLite Then
		    CustomerRepositorySQLite(mRepository).Close()
		  ElseIf mRepository IsA CustomerRepositorySQL Then
		    CustomerRepositorySQL(mRepository).Close()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DetailViewModel() As CustomerDetailViewModel
		  Return New CustomerDetailViewModel(mRepository)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ListViewModel() As CustomerListViewModel
		  Return New CustomerListViewModel(mRepository)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Repository() As ICustomerRepository
		  Return mRepository
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ConfigureRepository()
		  StatusMessage = ""

		  Select Case mSettings.Mode
		  Case "fake"
		    mRepository = CustomerRepositoryFactory.NewFake()
		    StatusMessage = "Customer backend: fake"
		  Case "sqlite-file"
		    mRepository = CustomerRepositoryFactory.NewSQLiteFile(mSettings.SQLiteDatabaseFile)
		    StatusMessage = "Customer backend: SQLite file"
		  Case "sql"
		    mRepository = CustomerRepositoryFactory.NewSQL(mSettings.SQLDatabase, mSettings.SQLDialect, mSettings.OwnsSQLConnection)
		    StatusMessage = "Customer backend: direct SQL"
		  Case "pocketbase"
		    mRepository = CustomerRepositoryFactory.NewPocketBase(mSettings.PocketBaseURL, mSettings.PocketBaseAuthToken, mSettings.PocketBaseCollection, mSettings.PocketBaseTimeoutSeconds)
		    StatusMessage = "Customer backend: PocketBase"
		  Else
		    mRepository = CustomerRepositoryFactory.NewFake()
		    StatusMessage = "Unknown customer backend mode; using fake"
		  End Select
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mRepository As ICustomerRepository
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSettings As CustomerBackendSettings
	#tag EndProperty

	#tag Property, Flags = &h0
		StatusMessage As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="StatusMessage"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
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
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
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
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
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
