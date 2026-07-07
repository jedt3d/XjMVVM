#tag Module
Protected Module CustomerRepositoryFactory
	#tag Method, Flags = &h0
		Function NewFake() As FakeCustomerRepository
		  Return New FakeCustomerRepository()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NewPocketBase(baseURL As String, authToken As String = "", collectionName As String = "customers", timeoutSeconds As Integer = 30) As CustomerRepositoryPocketBase
		  Var transport As New PocketBaseURLConnectionTransport(timeoutSeconds)
		  Var client As New PocketBaseClient(baseURL, transport, authToken)
		  Return New CustomerRepositoryPocketBase(client, collectionName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NewSQLite(db As SQLiteDatabase, ownsConnection As Boolean = False) As CustomerRepositorySQLite
		  Var repo As New CustomerRepositorySQLite(db, ownsConnection)
		  repo.EnsureSchema()
		  Return repo
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NewSQLiteFile(dbFile As FolderItem) As CustomerRepositorySQLite
		  Return CustomerRepositorySQLite.ForFile(dbFile)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NewSQL(db As Database, dialect As CustomerSQLDialect = Nil, ownsConnection As Boolean = False) As CustomerRepositorySQL
		  Var repo As New CustomerRepositorySQL(db, dialect, ownsConnection)
		  repo.EnsureSchema()
		  Return repo
		End Function
	#tag EndMethod

End Module
#tag EndModule
