#tag Class
Protected Class CustomerRepositoryPocketBase
Implements ICustomerRepository
	#tag Method, Flags = &h0
		Sub Constructor(client As PocketBaseClient, collectionName As String = "customers")
		  mClient = client
		  mCollectionName = collectionName.Trim()
		  If mCollectionName = "" Then mCollectionName = "customers"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count(searchTerm As String) As Integer
		  If mClient = Nil Then Return 0

		  Var query As PocketBaseQuery = BuildQuery(searchTerm, 1, 1)
		  Var response As PocketBaseResponse = mClient.Send("GET", RecordsPath() + query.ToQueryString())
		  If Not response.IsSuccess() Then Return 0

		  Var root As Dictionary = ParseDictionary(response.Body)
		  If root = Nil Or Not root.HasKey("totalItems") Then Return 0

		  Return root.Value("totalItems").IntegerValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Delete(id As String)
		  If mClient = Nil Then Return
		  If id.Trim() = "" Then Return

		  Call mClient.Send("DELETE", RecordsPath() + "/" + id.Trim())
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindByID(id As String) As Customer
		  If mClient = Nil Then Return Nil
		  If id.Trim() = "" Then Return Nil

		  Var response As PocketBaseResponse = mClient.Send("GET", RecordsPath() + "/" + id.Trim())
		  If Not response.IsSuccess() Then Return Nil

		  Return ParseCustomer(response.Body)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindPage(searchTerm As String, pageNumber As Integer, pageSize As Integer) As Customer()
		  Var results() As Customer
		  If mClient = Nil Then Return results
		  If pageSize <= 0 Then Return results

		  Var query As PocketBaseQuery = BuildQuery(searchTerm, pageNumber, pageSize)
		  Var response As PocketBaseResponse = mClient.Send("GET", RecordsPath() + query.ToQueryString())
		  If Not response.IsSuccess() Then Return results

		  Var root As Dictionary = ParseDictionary(response.Body)
		  If root = Nil Or Not root.HasKey("items") Then Return results

		  Var items() As Variant = root.Value("items")
		  For Each item As Variant In items
		    Var record As Dictionary = Dictionary(item)
		    Var c As Customer = PocketBaseRecordMapper.CustomerFromRecord(record)
		    If c <> Nil Then results.Add(c)
		  Next

		  Return results
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Save(customer As Customer) As Customer
		  If mClient = Nil Then Return Nil
		  If customer = Nil Then Return Nil

		  Var body As String = GenerateJSON(PocketBaseRecordMapper.CustomerToDictionary(customer))
		  Var response As PocketBaseResponse

		  If customer.ID.Trim() = "" Then
		    response = mClient.Send("POST", RecordsPath(), body)
		  Else
		    response = mClient.Send("PATCH", RecordsPath() + "/" + customer.ID.Trim(), body)
		  End If

		  If response = Nil Or Not response.IsSuccess() Then Return Nil
		  Return ParseCustomer(response.Body)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildQuery(searchTerm As String, pageNumber As Integer, pageSize As Integer) As PocketBaseQuery
		  Var query As New PocketBaseQuery(pageNumber, pageSize)
		  query.Sort = "last_name,first_name"

		  Var term As String = searchTerm.Trim()
		  If term <> "" Then
		    Var safeTerm As String = term.ReplaceAll("'", "\'")
		    query.Filter = "(first_name~'" + safeTerm + "' || last_name~'" + safeTerm + "' || email~'" + safeTerm + "')"
		  End If

		  Return query
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseCustomer(body As String) As Customer
		  Var record As Dictionary = ParseDictionary(body)
		  Return PocketBaseRecordMapper.CustomerFromRecord(record)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseDictionary(body As String) As Dictionary
		  If body.Trim() = "" Then Return Nil

		  Try
		    Var parsed As Variant = ParseJSON(body)
		    Return Dictionary(parsed)
		  Catch
		    Return Nil
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RecordsPath() As String
		  Return "/api/collections/" + mCollectionName + "/records"
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mClient As PocketBaseClient
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCollectionName As String
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
