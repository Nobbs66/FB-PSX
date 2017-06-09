'The PSX lacks a TLB and just mirrors addresses
Type cop0s
Dim Cause As UInteger 
Dim Status As UInteger 
Dim PRId As UInteger 
Dim EPC As UInteger 
Dim BadVaddr As UInteger 
End Type
Dim Shared cop0 As cop0s
Declare Function Exception(ByVal syscall As UInteger, ByVal eType As UByte) As UInteger
Function Exception(ByVal syscall As UInteger, ByVal eType As UByte) As UInteger
	Select Case eType
		Case 0 'SysCall
		cop0.Cause Or= (8 Shl 2)	
	End Select
End Function
