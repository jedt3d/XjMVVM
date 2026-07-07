#tag Module
Protected Module CustomerValidator
	#tag Method, Flags = &h0
		Function Validate(c As Customer) As ValidationResult
		  Var result As New ValidationResult()
		  
		  If c = Nil Then
		    result.AddError("Customer is required")
		    Return result
		  End If
		  
		  If c.FirstName.Trim() = "" Then result.AddError("First name is required")
		  If c.LastName.Trim() = "" Then result.AddError("Last name is required")
		  
		  If c.Email.Trim() <> "" And c.Email.IndexOf("@") < 1 Then
		    result.AddError("Email must contain @")
		  End If
		  
		  Return result
		End Function
	#tag EndMethod

End Module
#tag EndModule
