Declare Sub checkOverflow
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
	delayReg As UByte
	delayValue As UInteger
	delayFlag As UByte
	'ldQueue As UByte 'THis shouldn't need to be more than a byte unless we're doing more than 255 consecutive loads. 
	delay_slot_PC As UInteger 
	branch_queued As UByte
	HI As UInteger
	breakPoint As UByte
	LO As UInteger
	bios(&h80000) As UByte
	opcode As UInteger
	Operation As String
	memSize As UByte
	delayLatch As UByte
	ophistory(0 To &hFF) As String 
   const Reset_Vector As UInteger = &hBFC00000
   storeAddress As UByte
   storedAddress As UInteger
   storeValue As UInteger
End Type


Type cop0s
	reg(0 To &h31) As UInteger 
End Type

Type ports
	memMirror As UByte '2mb or 8mb memory config
	iEnable As UInteger 'Interrupt Enable - Edge Sensitive
	iMask As UInteger 'Interrupt Mask 
	cacheCtrl As UInteger 
End Type


Const As UInteger KUSEG = &h1FFFFF
Const As UInteger KSEG0 = &h80000000
Const As UInteger KSEG1 = &hA0000000
Open "log.txt" For Output As #99

Dim Shared cpu As cpus
Dim Shared cop0 As cop0s
Dim Shared port As ports
#Define RD  	((cpu.opcode Shr 11) And &h1F)
#Define RT  	((cpu.opcode Shr 16) And &h1F)
#Define RS  	((cpu.opcode Shr 21) And &h1F)
#Define SA		(cpu.opcode And &h1f)
#Define imm 	(cpu.opcode And &hFFFF)
#Define Offset ((cpu.opcode And &hFFFF) Shl 2)
#Define Target ((cpu.opcode And &h3FFFFFF) Shl 2)

#Define BPC 		(cop0.reg(3)) 	'Breakpoint on executed 
#Define BDA 		(cop0.reg(5)) 	'Breakpoint on data access
#Define JUMPDEST 	(cop0.reg(6)) 	'Randomly memorised jump address
#Define DCIC 		(cop0.reg(7)) 	'Breakpoint Control
#Define BadVaddr 	(cop0.reg(8)) 	'Bad virtual adsdress
#Define BDAM 		(cop0.reg(9)) 	'Data access breakpoint mask
#Define BPCM 		(cop0.reg(11)) 'Execute breakpoint mask
#Define SR 			(cop0.reg(12)) 'Status register
#Define CAUSE 		(cop0.reg(13)) 'Exception Cause
#Define EPC 		(cop0.reg(14)) 'Exception program counter
#Define PRID 		(cop0.reg(15)) 'Processor ID


#Define BEV (((cop0.reg(12) Shr 22) And 1)) 'Bootstrap Exception Vector 

Sub loadBIOS
Open "BIOS\SCPH1001.BIN" for binary as #1
'Open "BIOS\SCPH1001.BIN" For Binary As #1
'Open "BIOS\LDTEST.BIN" For Binary As #1
for i as uinteger  = 0 to &h80000
get #1, i, cpu.bios(i-1)
Next
close #1
End Sub
Sub initCPU
	'cpu.current_PC = &hBFC00000
	cpu.current_PC = cpu.Reset_Vector
	cop0.reg(12) Or= &h400000 'Set BEV
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
		Case &h80000000 To &h803FFFFF
			Dim As UInteger addr = cpu.current_PC And &h1FFFFF
				For i As Integer = 0 To &hF
				Print Hex(cpu.memory(addr + i))
				Next
	'''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &hA0000000 To &hA01FFFFF
		cpu.current_PC and= &h1FFFFF
			For i As Integer = 0 To 3
			cpu.opcode Or= (cpu.memory((cpu.current_PC+i)And &h1FFFFF) Shl i*8)
			Next
	'''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &hBFC00000 To &hBFC7FFFF
			For i As Integer = 0 To 3
			cpu.opcode Or= (cpu.bios((cpu.current_PC+i) And &h7FFFF) Shl i*8)
			Next
	'''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case Else 
			Print "Instruction Fetch Failure" 
	End Select 
End Sub
Sub checkOverflow
	'Overflow check not implemented
End Sub
Function writeIO(ByVal addr As UInteger, ByVal value As UByte) As UInteger
	If (addr Shr 16) = &h1F80 Then 
	addr And= &hFFFF
	Select Case addr
		Case &h0130	To &h0133 'Cache Control 
			'Print "Addr: " & Hex(addr)
			'Print "Data: " & Hex(value)
			'sleep
		Case &h1000 To &h1020 'Memory Control 1
		Case &h1040 To &h105F 'Peripheral IO
		Case &h1061 			 'Memory Control 2
		port.memMirror = (value Shr 1)
		If port.memMirror = 5 Then cpu.memSize = 8 
		Print "Memory Size: " & cpu.memSize
		Case &h1070 To &h1073 'interrupt Enable
			port.iEnable or= (value Shl (24-((addr And &h3)*8))) 
		Case &h1074 To &h1077 'Interrupt Mask
			
		Case &h1080 To &h10F4 'DMA Registers
		Case &h1100 To &h1120 'Timers
		Case &h1800 To &h1804 'CD ROM
		Case &h1820 To &h1828 'MDEC
		Case &hC000 To &h1FFF 'SPU
	End Select
	Else
	addr And= &hFFFF
	Select Case addr
		Case &h130 To &h133 'Cache Control 
			Print "Addr: " & addr
			Print "Value: " & value
			'sleep
	End Select
	endif
	Print port.memMirror
	Return 0 
End Function

Function WriteByte(ByVal addr As UInteger, ByVal value As UByte) As uinteger
	'Memory is split into a few different regions
	Dim As UByte IsC = ((SR Shr 16) And 1)
	If IsC = 0 Then 
	Select Case addr
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h0 To &h7FFFFF 'KUSEG
			cpu.memory(addr And &h1FFFFF) = value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h80000000 To &h807FFFFF 'KSEG0
		 	cpu.memory(addr And &h1FFFFF) = value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''		 	
		Case &hA0000000 To &hA07FFFFF 'KSEG1
			cpu.memory(addr And &h1FFFFF) = value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''			
		Case &h1F800000 To &h1F8003FF 'Scratchpad
			cpu.dCache(addr And &h3FF) = value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1F801000 To &h1F801FFC 'I/O Ports
			Print "Writing I/O Port at: " & Hex(addr)
			writeIO(addr, value)
		Case &hFFFE0130 To &hFFFE0133
			Print "Writing Cache Control " & Hex(addr)
			writeIO(addr, value)
		Case Else 
			Print "Bad write"
			Print "ADDRESS: " & Hex(addr)
			Print "DATA: " & Hex(value)
	End Select
	Else
	cpu.iCache(addr) = value 
	EndIf

	return 0 
End Function
function ReadByte(ByVal addr As UInteger) As UInteger
		'Memory is split into a few different regions
		dim value as ubyte 
	Select Case addr
		Case &h0 To &h1FFFFF 'KSEG0
			value = cpu.memory(addr) 
		Case &h80000000 To &h801FFFFF 'KSEG0 
		 	value = cpu.memory(addr And &h1FFFFF) 
		Case &hA0000000 To &hA01FFFFF 'KSEG1
			value = cpu.memory(addr And &h1FFFFF) 
		Case &hBFC00000 To &hBFC7FFFF 'BIOS(Read only)
			value = cpu.bios(addr and &h7FFFF)
		Case &h1F801000 To &h1F801FFC 'I/O Ports
			Print "Reading I/O Port at: " & Hex(addr)
			writeIO(addr, value)
		Case Else 
			Print "Bad Read Address"
	End Select
	return value
End Function

