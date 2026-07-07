#tag Class
Protected Class FakeCustomerRepository
Implements ICustomerRepository
	#tag Method, Flags = &h0
		Sub Constructor()
		  mNextID = 1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count(searchTerm As String) As Integer
		  Var n As Integer = 0
		  Var term As String = searchTerm.Trim().Lowercase()

		  For Each c As Customer In mCustomers
		    If MatchesSearch(c, term) Then n = n + 1
		  Next

		  Return n
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Delete(id As String)
		  Var removeIndex As Integer = -1

		  If mCustomers.LastIndex >= 0 Then
		    For i As Integer = 0 To mCustomers.LastIndex
		      If mCustomers(i).ID = id Then
		        removeIndex = i
		        Exit For
		      End If
		    Next
		  End If

		  If removeIndex >= 0 Then mCustomers.RemoveAt(removeIndex)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindByID(id As String) As Customer
		  For Each c As Customer In mCustomers
		    If c.ID = id Then Return c.Clone()
		  Next

		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindPage(searchTerm As String, pageNumber As Integer, pageSize As Integer) As Customer()
		  Var results() As Customer
		  If pageSize <= 0 Then Return results
		  If pageNumber < 1 Then pageNumber = 1

		  Var filtered() As Customer
		  Var term As String = searchTerm.Trim().Lowercase()

		  For Each c As Customer In mCustomers
		    If MatchesSearch(c, term) Then filtered.Add(c.Clone())
		  Next

		  If filtered.LastIndex < 0 Then Return results

		  Var offset As Integer = (pageNumber - 1) * pageSize
		  If offset > filtered.LastIndex Then Return results

		  Var endIndex As Integer = offset + pageSize - 1
		  If endIndex > filtered.LastIndex Then endIndex = filtered.LastIndex

		  For i As Integer = offset To endIndex
		    results.Add(filtered(i).Clone())
		  Next

		  Return results
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MatchesSearch(c As Customer, term As String) As Boolean
		  If term = "" Then Return True
		  If c = Nil Then Return False

		  Var haystack As String = c.FirstName + " " + c.LastName + " " + c.Email
		  haystack = haystack.Lowercase()
		  Return haystack.IndexOf(term) >= 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Save(customer As Customer) As Customer
		  If customer = Nil Then Return Nil

		  Var saved As Customer = customer.Clone()

		  If saved.ID.Trim() = "" Then
		    saved.ID = mNextID.ToString()
		    mNextID = mNextID + 1
		    mCustomers.Add(saved.Clone())
		    Return saved
		  End If

		  If mCustomers.LastIndex >= 0 Then
		    For i As Integer = 0 To mCustomers.LastIndex
		      If mCustomers(i).ID = saved.ID Then
		        mCustomers(i) = saved.Clone()
		        Return saved
		      End If
		    Next
		  End If

		  mCustomers.Add(saved.Clone())
		  Return saved
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mCustomers() As Customer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mNextID As Integer
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
