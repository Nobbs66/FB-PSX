
Type GPU
	hRes As UInteger
	vRes As UInteger
	vram (0 To &hFFFFF) As UByte 
	command_Buffer 0 To 11 As UInteger 
End Type
Declare Sub 
Function gpuCommand(ByVal com As UByte)As UInteger
	

End Function

