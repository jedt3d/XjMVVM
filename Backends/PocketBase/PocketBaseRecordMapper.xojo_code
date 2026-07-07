#tag Module
Protected Module PocketBaseRecordMapper
	#tag Method, Flags = &h21
		Private Function FieldString(record As Dictionary, key As String) As String
		  If record = Nil Then Return ""
		  If Not record.HasKey(key) Then Return ""

		  Var value As Variant = record.Value(key)
		  If value.IsNull Then Return ""
		  Return value.StringValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CustomerFromRecord(record As Dictionary) As Customer
		  If record = Nil Then Return Nil

		  Var c As New Customer()
		  c.ID = FieldString(record, "id")
		  c.FirstName = FieldString(record, "first_name")
		  c.LastName = FieldString(record, "last_name")
		  c.Email = FieldString(record, "email")
		  c.DateOfBirth = FieldString(record, "date_of_birth")
		  c.Gender = FieldString(record, "gender")
		  Return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CustomerToDictionary(c As Customer) As Dictionary
		  Var d As New Dictionary()

		  If c = Nil Then Return d

		  If c.ID.Trim() <> "" Then d.Value("id") = c.ID
		  d.Value("first_name") = c.FirstName
		  d.Value("last_name") = c.LastName
		  d.Value("email") = c.Email
		  d.Value("date_of_birth") = c.DateOfBirth
		  d.Value("gender") = c.Gender
		  Return d
		End Function
	#tag EndMethod

End Module
#tag EndModule
