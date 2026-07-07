#tag Class
Protected Class CustomerBackendSettings
	#tag Method, Flags = &h0
		Sub Constructor()
		  Mode = "fake"
		  PocketBaseCollection = "customers"
		  PocketBaseTimeoutSeconds = 30
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Fake() As CustomerBackendSettings
		  Var settings As New CustomerBackendSettings()
		  settings.Mode = "fake"
		  Return settings
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function PocketBase(baseURL As String, authToken As String = "", collectionName As String = "customers", timeoutSeconds As Integer = 30) As CustomerBackendSettings
		  Var settings As New CustomerBackendSettings()
		  settings.Mode = "pocketbase"
		  settings.PocketBaseURL = baseURL
		  settings.PocketBaseAuthToken = authToken
		  settings.PocketBaseCollection = collectionName
		  settings.PocketBaseTimeoutSeconds = timeoutSeconds
		  Return settings
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function SQL(db As Database, dialect As CustomerSQLDialect = Nil, ownsConnection As Boolean = False) As CustomerBackendSettings
		  Var settings As New CustomerBackendSettings()
		  settings.Mode = "sql"
		  settings.SQLDatabase = db
		  settings.SQLDialect = dialect
		  settings.OwnsSQLConnection = ownsConnection
		  Return settings
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function SQLiteFile(dbFile As FolderItem) As CustomerBackendSettings
		  Var settings As New CustomerBackendSettings()
		  settings.Mode = "sqlite-file"
		  settings.SQLiteDatabaseFile = dbFile
		  Return settings
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Mode As String
	#tag EndProperty

	#tag Property, Flags = &h0
		OwnsSQLConnection As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		PocketBaseAuthToken As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PocketBaseCollection As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PocketBaseTimeoutSeconds As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		PocketBaseURL As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SQLiteDatabaseFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		SQLDatabase As Database
	#tag EndProperty

	#tag Property, Flags = &h0
		SQLDialect As CustomerSQLDialect
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Mode"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="OwnsSQLConnection"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PocketBaseAuthToken"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PocketBaseCollection"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PocketBaseTimeoutSeconds"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PocketBaseURL"
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
