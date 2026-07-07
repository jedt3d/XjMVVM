#tag Class
Protected Class CustomerRepositorySQLite
Implements ICustomerRepository
	#tag Method, Flags = &h0
		Sub Constructor(db As SQLiteDatabase, ownsConnection As Boolean = False)
		  mDB = db
		  mOwnsConnection = ownsConnection
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function ForFile(dbFile As FolderItem) As CustomerRepositorySQLite
		  Var db As New SQLiteDatabase()
		  db.DatabaseFile = dbFile
		  db.Connect()

		  Var repo As New CustomerRepositorySQLite(db, True)
		  repo.EnsureSchema()
		  Return repo
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Close()
		  If mDB <> Nil And mOwnsConnection Then
		    mDB.Close()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count(searchTerm As String) As Integer
		  If mDB = Nil Then Return 0

		  Var term As String = searchTerm.Trim().Lowercase()
		  Var rs As RowSet

		  If term = "" Then
		    rs = mDB.SelectSQL("SELECT COUNT(*) AS n FROM customers")
		  Else
		    Var pattern As String = "%" + term + "%"
		    rs = mDB.SelectSQL("SELECT COUNT(*) AS n FROM customers WHERE " + SearchWhere(), pattern, pattern, pattern)
		  End If

		  Var n As Integer = 0
		  If Not rs.AfterLastRow Then n = rs.Column("n").IntegerValue
		  rs.Close()
		  Return n
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Delete(id As String)
		  If mDB = Nil Then Return

		  Var value As Integer = IDValue(id)
		  If value <= 0 Then Return

		  mDB.ExecuteSQL("DELETE FROM customers WHERE id = ?", value)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EnsureSchema()
		  If mDB = Nil Then Return

		  mDB.ExecuteSQL("CREATE TABLE IF NOT EXISTS customers (" + _
		  "id INTEGER PRIMARY KEY AUTOINCREMENT, " + _
		  "owner_id TEXT, " + _
		  "first_name TEXT NOT NULL, " + _
		  "last_name TEXT NOT NULL, " + _
		  "email TEXT, " + _
		  "date_of_birth TEXT, " + _
		  "gender TEXT, " + _
		  "created_at TEXT DEFAULT (datetime('now')), " + _
		  "updated_at TEXT DEFAULT (datetime('now')))")
		  mDB.ExecuteSQL("CREATE INDEX IF NOT EXISTS idx_customers_name ON customers (last_name, first_name)")
		  mDB.ExecuteSQL("CREATE INDEX IF NOT EXISTS idx_customers_email ON customers (email)")
		  If Not ColumnExists("customers", "owner_id") Then
		    mDB.ExecuteSQL("ALTER TABLE customers ADD COLUMN owner_id TEXT")
		  End If
		  mDB.ExecuteSQL("CREATE INDEX IF NOT EXISTS idx_customers_owner_id ON customers (owner_id)")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindByID(id As String) As Customer
		  If mDB = Nil Then Return Nil

		  Var value As Integer = IDValue(id)
		  If value <= 0 Then Return Nil

		  Var rs As RowSet = mDB.SelectSQL("SELECT id, owner_id, first_name, last_name, email, date_of_birth, gender FROM customers WHERE id = ?", value)
		  If rs.AfterLastRow Then
		    rs.Close()
		    Return Nil
		  End If

		  Var c As Customer = CustomerFromRow(rs)
		  rs.Close()
		  Return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindPage(searchTerm As String, pageNumber As Integer, pageSize As Integer) As Customer()
		  Var results() As Customer
		  If mDB = Nil Then Return results
		  If pageSize <= 0 Then Return results
		  If pageNumber < 1 Then pageNumber = 1

		  Var offset As Integer = (pageNumber - 1) * pageSize
		  Var term As String = searchTerm.Trim().Lowercase()
		  Var sql As String = "SELECT id, owner_id, first_name, last_name, email, date_of_birth, gender FROM customers"
		  Var rs As RowSet

		  If term = "" Then
		    sql = sql + " ORDER BY last_name COLLATE NOCASE, first_name COLLATE NOCASE LIMIT ? OFFSET ?"
		    rs = mDB.SelectSQL(sql, pageSize, offset)
		  Else
		    Var pattern As String = "%" + term + "%"
		    sql = sql + " WHERE " + SearchWhere() + " ORDER BY last_name COLLATE NOCASE, first_name COLLATE NOCASE LIMIT ? OFFSET ?"
		    rs = mDB.SelectSQL(sql, pattern, pattern, pattern, pageSize, offset)
		  End If

		  While Not rs.AfterLastRow
		    results.Add(CustomerFromRow(rs))
		    rs.MoveToNextRow()
		  Wend
		  rs.Close()

		  Return results
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Save(customer As Customer) As Customer
		  If mDB = Nil Then Return Nil
		  If customer = Nil Then Return Nil

		  Var saved As Customer = customer.Clone()
		  Var value As Integer = IDValue(saved.ID)

		  If value <= 0 Then
		    mDB.ExecuteSQL("INSERT INTO customers (owner_id, first_name, last_name, email, date_of_birth, gender) VALUES (?, ?, ?, ?, ?, ?)", _
		    saved.OwnerID, saved.FirstName, saved.LastName, saved.Email, saved.DateOfBirth, saved.Gender)
		    saved.ID = mDB.LastRowID.ToString()
		    Return FindByID(saved.ID)
		  End If

		  mDB.ExecuteSQL("UPDATE customers SET owner_id = ?, first_name = ?, last_name = ?, email = ?, date_of_birth = ?, gender = ?, updated_at = datetime('now') WHERE id = ?", _
		  saved.OwnerID, saved.FirstName, saved.LastName, saved.Email, saved.DateOfBirth, saved.Gender, value)
		  Return FindByID(saved.ID)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ColumnExists(tableName As String, columnName As String) As Boolean
		  Var rs As RowSet = mDB.SelectSQL("PRAGMA table_info(" + tableName + ")")
		  While Not rs.AfterLastRow
		    If rs.Column("name").StringValue = columnName Then
		      rs.Close()
		      Return True
		    End If
		    rs.MoveToNextRow()
		  Wend
		  rs.Close()
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CustomerFromRow(rs As RowSet) As Customer
		  Var c As New Customer()
		  c.ID = rs.Column("id").StringValue
		  c.OwnerID = rs.Column("owner_id").StringValue
		  c.FirstName = rs.Column("first_name").StringValue
		  c.LastName = rs.Column("last_name").StringValue
		  c.Email = rs.Column("email").StringValue
		  c.DateOfBirth = rs.Column("date_of_birth").StringValue
		  c.Gender = rs.Column("gender").StringValue
		  Return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IDValue(id As String) As Integer
		  Return Val(id.Trim())
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SearchWhere() As String
		  Return "lower(first_name) LIKE ? OR lower(last_name) LIKE ? OR lower(email) LIKE ?"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mDB As SQLiteDatabase
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOwnsConnection As Boolean
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
