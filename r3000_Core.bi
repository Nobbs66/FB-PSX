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
	memSize As UByte
   const Reset_Vector As UInteger = &hBFC00000
End Type
Type ports
	memMirror As UByte '2mb or 8mb memory config

End Type
Const As UInteger KUSEG = &h1FFFFF
Const As UInteger KSEG0 = &h80000000
Const As UInteger KSEG1 = &hA0000000
Dim Shared cpu As cpus
Dim Shared port As ports
#Define RD  	((cpu.opcode Shr 11) And &h1F)
#Define RT  	((cpu.opcode Shr 16) And &h1F)
#Define RS  	((cpu.opcode Shr 21) And &h1F)
#Define SA		(cpu.opcode And &h1f)
#Define imm 	(cpu.opcode And &hFFFF)
#Define Offset ((cpu.opcode And &hFFFF) Shl 2)
#Define Target ((cpu.opcode And &h3FFFFFF) Shl 2)

Sub loadBIOS
'Open "BIOS\SCPH1001.BIN" for binary as #1
Open "BIOS\SCPH1001.BIN" For Binary As #1
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
Function writeIO(ByVal addr As UInteger, ByVal value As UByte) As UInteger
	addr And= &hFFFF
	Select Case addr
		Case &h0130	To &h0133 'Cache Control 
		Case &h1000 To &h1020 'Memory Control 1
		Case &h1040 To &h105F 'Peripheral IO
		Case &h1061 			 'Memory Control 2
		port.memMirror = (value Shr 1)
		If port.memMirror = 5 Then cpu.memSize = 8 
		Print "Memory Size: " & cpu.memSize
		Case &h1070 To &h1078 'Interrupt Control
		Case &h1080 To &h10F4 'DMA Registers
		Case &h1100 To &h1120 'Timers
		Case &h1800 To &h1804 'CD ROM
		Case &h1820 To &h1828 'MDEC
		Case &hC000 To &h1FFF 'SPU
	End Select
	Print port.memMirror
	Return 0 
End Function
Function WriteByte(ByVal addr As UInteger, ByVal value As UByte) As uinteger
	'Memory is split into a few different regions
	Select Case addr
		Case &h0 To (KUSEG*8) 'KUSEG
			cpu.memory(addr) = value
		Case KSEG1 To KSEG1+(KUSEG*8)'KSEG0
		 	cpu.memory(addr And &h1FFFFF) = value
		Case KSEG1 To KSEG1+(KUSEG*8) 'KSEG1
			cpu.memory(addr And &h1FFFFF) = value
		Case &h1F800000 To &h1F8003FF 'Scratchpad
			cpu.dCache(addr And &h3FF) = value
		Case &h1F801000 To &h1F801FFC 'I/O Ports
			Print "Writing I/O Port at: " & Hex(addr)
			writeIO(addr, value)
		Case &hFFFE0130 To &hFFFE0133
			Print "Writing Cache Control " & Hex(addr)
			writeIO(addr, value)
		Case Else 
			Print "WHY ARE YOU WRITING HERE STUPID THING!"
			Print "ADDRESS: " & Hex(addr)
			Print "DATA: " & Hex(value)
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

