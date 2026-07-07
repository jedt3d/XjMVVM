#tag Class
Protected Class CustomerDetailViewModel
	#tag Method, Flags = &h0
		Sub Constructor(repository As ICustomerRepository)
		  mRepository = repository
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Current() As Customer
		  If mCustomer = Nil Then Return Nil
		  Return mCustomer.Clone()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Load(id As String)
		  StatusMessage = ""
		  mCustomer = Nil

		  If mRepository = Nil Then
		    StatusMessage = "No customer repository"
		    Return
		  End If

		  mCustomer = mRepository.FindByID(id)
		  If mCustomer = Nil Then
		    StatusMessage = "Customer not found"
		  Else
		    StatusMessage = "Loaded customer " + mCustomer.ID
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Save(c As Customer) As Boolean
		  StatusMessage = ""

		  If mRepository = Nil Then
		    StatusMessage = "No customer repository"
		    Return False
		  End If

		  Var validation As ValidationResult = CustomerValidator.Validate(c)
		  If Not validation.IsValid() Then
		    StatusMessage = validation.Summary()
		    Return False
		  End If

		  mCustomer = mRepository.Save(c)
		  If mCustomer = Nil Then
		    StatusMessage = "Customer save failed"
		    Return False
		  End If

		  StatusMessage = "Saved customer " + mCustomer.ID
		  Return True
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mCustomer As Customer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRepository As ICustomerRepository
	#tag EndProperty

	#tag Property, Flags = &h0
		StatusMessage As String
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
