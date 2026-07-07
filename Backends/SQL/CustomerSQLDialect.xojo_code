#tag Class
Protected Class CustomerSQLDialect
	#tag Method, Flags = &h0
		Sub Constructor(name As String = "generic", usesNumberedPlaceholders As Boolean = False)
		  Self.Name = name
		  Self.UsesNumberedPlaceholders = usesNumberedPlaceholders
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CustomerIndexesSQL() As String()
		  Var statements() As String
		  statements.Add("CREATE INDEX IF NOT EXISTS idx_customers_name ON customers (last_name, first_name)")
		  statements.Add("CREATE INDEX IF NOT EXISTS idx_customers_email ON customers (email)")
		  statements.Add("CREATE INDEX IF NOT EXISTS idx_customers_owner_id ON customers (owner_id)")
		  Return statements
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CustomerSchemaSQL() As String
		  Return "CREATE TABLE IF NOT EXISTS customers (" + _
		  "id TEXT PRIMARY KEY, " + _
		  "owner_id TEXT, " + _
		  "first_name TEXT NOT NULL, " + _
		  "last_name TEXT NOT NULL, " + _
		  "email TEXT, " + _
		  "date_of_birth TEXT, " + _
		  "gender TEXT, " + _
		  "created_at TEXT, " + _
		  "updated_at TEXT)"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Generic() As CustomerSQLDialect
		  Return New CustomerSQLDialect("generic", False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LimitOffsetClause(limitIndex As Integer, offsetIndex As Integer) As String
		  Return " LIMIT " + Placeholder(limitIndex) + " OFFSET " + Placeholder(offsetIndex)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function MySQL() As CustomerSQLDialect
		  Return New CustomerSQLDialect("mysql", False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function ODBC() As CustomerSQLDialect
		  Return New CustomerSQLDialect("odbc", False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Placeholder(index As Integer) As String
		  If index < 1 Then index = 1
		  If UsesNumberedPlaceholders Then Return "$" + index.ToString()
		  Return "?"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PlaceholderList(count As Integer, startIndex As Integer = 1) As String
		  Var parts() As String
		  If count <= 0 Then Return ""

		  For i As Integer = startIndex To startIndex + count - 1
		    parts.Add(Placeholder(i))
		  Next

		  Return String.FromArray(parts, ", ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function PostgreSQL() As CustomerSQLDialect
		  Return New CustomerSQLDialect("postgresql", True)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SearchWhere(firstIndex As Integer = 1) As String
		  Return "lower(first_name) LIKE " + Placeholder(firstIndex) + _
		  " OR lower(last_name) LIKE " + Placeholder(firstIndex + 1) + _
		  " OR lower(email) LIKE " + Placeholder(firstIndex + 2)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function SQLite() As CustomerSQLDialect
		  Return New CustomerSQLDialect("sqlite", False)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag Property, Flags = &h0
		UsesNumberedPlaceholders As Boolean
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="UsesNumberedPlaceholders"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
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
