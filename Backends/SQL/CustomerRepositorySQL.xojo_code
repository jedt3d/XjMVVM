#tag Class
Protected Class CustomerRepositorySQL
Implements ICustomerRepository
	#tag Method, Flags = &h0
		Sub Constructor(db As Database, dialect As CustomerSQLDialect = Nil, ownsConnection As Boolean = False)
		  mDB = db
		  If dialect = Nil Then
		    mDialect = CustomerSQLDialect.Generic()
		  Else
		    mDialect = dialect
		  End If
		  mOwnsConnection = ownsConnection
		End Sub
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
		    rs = mDB.SelectSQL("SELECT COUNT(*) AS n FROM customers WHERE " + mDialect.SearchWhere(1), pattern, pattern, pattern)
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
		  If id.Trim() = "" Then Return

		  mDB.ExecuteSQL("DELETE FROM customers WHERE id = " + mDialect.Placeholder(1), id.Trim())
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EnsureSchema()
		  If mDB = Nil Then Return

		  mDB.ExecuteSQL(mDialect.CustomerSchemaSQL())
		  For Each sql As String In mDialect.CustomerIndexesSQL()
		    mDB.ExecuteSQL(sql)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindByID(id As String) As Customer
		  If mDB = Nil Then Return Nil
		  If id.Trim() = "" Then Return Nil

		  Var rs As RowSet = mDB.SelectSQL("SELECT id, owner_id, first_name, last_name, email, date_of_birth, gender FROM customers WHERE id = " + mDialect.Placeholder(1), id.Trim())
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
		    sql = sql + " ORDER BY lower(last_name), lower(first_name)" + mDialect.LimitOffsetClause(1, 2)
		    rs = mDB.SelectSQL(sql, pageSize, offset)
		  Else
		    Var pattern As String = "%" + term + "%"
		    sql = sql + " WHERE " + mDialect.SearchWhere(1) + " ORDER BY lower(last_name), lower(first_name)" + mDialect.LimitOffsetClause(4, 5)
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
		  Var now As String = DateTime.Now.SQLDateTime

		  If saved.ID.Trim() = "" Then
		    saved.ID = NewID()
		    mDB.ExecuteSQL("INSERT INTO customers (id, owner_id, first_name, last_name, email, date_of_birth, gender, created_at, updated_at) VALUES (" + mDialect.PlaceholderList(9) + ")", _
		    saved.ID, saved.OwnerID, saved.FirstName, saved.LastName, saved.Email, saved.DateOfBirth, saved.Gender, now, now)
		    Return FindByID(saved.ID)
		  End If

		  mDB.ExecuteSQL("UPDATE customers SET owner_id = " + mDialect.Placeholder(1) + _
		  ", first_name = " + mDialect.Placeholder(2) + _
		  ", last_name = " + mDialect.Placeholder(3) + _
		  ", email = " + mDialect.Placeholder(4) + _
		  ", date_of_birth = " + mDialect.Placeholder(5) + _
		  ", gender = " + mDialect.Placeholder(6) + _
		  ", updated_at = " + mDialect.Placeholder(7) + _
		  " WHERE id = " + mDialect.Placeholder(8), _
		  saved.OwnerID, saved.FirstName, saved.LastName, saved.Email, saved.DateOfBirth, saved.Gender, now, saved.ID.Trim())
		  Return FindByID(saved.ID)
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
		Private Function NewID() As String
		  Return "c" + EncodeHex(Crypto.GenerateRandomBytes(12)).Lowercase()
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mDB As Database
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDialect As CustomerSQLDialect
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
