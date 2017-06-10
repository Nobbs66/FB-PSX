Declare Sub Check_Overflow
Declare Sub loadBIOS
Declare Sub validBIOS
Declare Sub initCPU
Declare Function WriteByte(ByVal addr As UInteger, ByVal value As UByte) As UInteger
Declare function ReadByte(ByVal addr As UInteger) As UInteger
Type cpus
	memory(&h200000) As UByte
	iCache(&hFFF) As ubyte
	dCache(&h400) As UByte
	GPR(32) As UInteger
	current_PC As UInteger
	old_PC As UInteger
	delay_slot_PC As UInteger 
	branch_queued As UByte
	HI As UInteger
	LO As UInteger
	bios(&h80000) As UByte
	opcode As UInteger
	Operation As String
   const Reset_Vector As UInteger = &hBFC00000
End Type
Dim Shared cpu As cpus

#Define RD  	((cpu.opcode Shr 11) And &h1F)
#Define RT  	((cpu.opcode Shr 16) And &h1F)
#Define RS  	((cpu.opcode Shr 21) And &h1F)
#Define SA		(cpu.opcode And &h1f)
#Define imm 	(cpu.opcode And &hFFFF)
#Define Offset ((cpu.opcode And &hFFFF) Shl 2)
#Define Target ((cpu.opcode And &h3FFFFFF) Shl 2)

Sub loadBIOS
Open "BIOS\SCPH1001.BIN" for binary as #1
for i as uinteger  = 0 to &h80000
get #1, i, cpu.bios(i-1)
Next
close #1
End Sub
Sub initCPU
	cpu.current_PC = &hBFC00000
End Sub
Sub fetchInstruction 'Copies 4 bytes to a 32-bit opcode variable
	cpu.opcode = 0 'Not clearing opcode breaks things horribly! 
	Select Case cpu.current_PC
	'''''''''''''''''''''''''''''''''''''''''''''''
		Case 0 To &h1FFFFF
		For i As Integer = 0 To 3
		cpu.opcode Or= (cpu.memory(cpu.current_PC+i) Shl i*8)
		Next
	'''''''''''''''''''''''''''''''''''''''''''''''
		Case &h80000000 To &h801FFFFF
		cpu.current_PC and= &h1FFFFF
			For i As Integer = 0 To 3
			cpu.opcode Or= (cpu.memory(cpu.current_PC+i) Shl i*8)
			Next
	'''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &hA0000000 To &hA01FFFFF
		cpu.current_PC and= &h1FFFFF
			For i As Integer = 0 To 3
			cpu.opcode Or= (cpu.memory(cpu.current_PC+i) Shl i*8)
			Next
	'''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &hBFC00000 To &hBFC7FFFF
			For i As Integer = 0 To 3
			cpu.opcode Or= (cpu.bios((cpu.current_PC+i) And &h7FFFF) Shl i*8)
			Next
	'''''''''''''''''''''''''''''''''''''''''''''''''''''
	End Select 

End Sub

Sub Check_Overflow
	
End Sub
Function WriteByte(ByVal addr As UInteger, ByVal value As UByte) As uinteger
	'Memory is split into a few different regions
	Select Case addr
		Case &h0 To &h1FFFFF
			cpu.memory(addr) = value
		Case &h80000000 To &h801FFFFF
		 	cpu.memory(addr And &h1FFFFF) = value
		Case &hA0000000 To &hA01FFFFF
			cpu.memory(addr And &h1FFFFF) = value
		Case Else 
			Print "WHY ARE YOU WRITING HERE STUPID THING!"
	End Select
	return 0 
End Function
function ReadByte(ByVal addr As UInteger) As UInteger
		'Memory is split into a few different regions
		dim value as ubyte 
	Select Case addr
		Case &h0 To &h1FFFFF
			value = cpu.memory(addr) 
		Case &h80000000 To &h801FFFFF
		 	value = cpu.memory(addr And &h1FFFFF) 
		Case &hA0000000 To &hA01FFFFF
			value = cpu.memory(addr And &h1FFFFF) 
		Case &hBFC00000 To &hBFC7FFFF
			value = cpu.bios(addr and &h7FFFF)
		Case Else 
			Print "DO YOU REALLY NEED THIS DATA?"
	End Select
	return value
End Function

