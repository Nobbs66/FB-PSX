Declare Sub checkOverflow
Declare Sub loadBIOS
Declare Sub validBIOS
Declare Sub initCPU
Declare Sub loadDelay
Declare Function WriteByte(ByVal addr As UInteger, ByVal value As UByte) As UInteger
Declare function ReadByte(ByVal addr As UInteger) As UInteger
Dim Shared As UInteger temp 
Type cpus
	memory(&h200000) As UByte
	iCache(&hFFF) As ubyte
	dCache(&h400) As UByte
	expansion(&h800000) As UByte
	GPR(32) As UInteger
	dGPR(32) As UInteger 'Load Delay GPR set
	fGPR(32) As Ubyte 'Load Delay flags
	current_PC As UInteger
	delayReg As UByte
	delayValue As UInteger
	delayFlag As UByte
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
	storeAddress As UByte
   storedAddress As UInteger
   storeValue As UInteger
	ophistory(0 To &hFF) As String 
   const Reset_Vector As UInteger = &hBFC00000
   bootStatus As UByte
   instructions As Uinteger 
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
Open "logs/log0.txt" For Output As #99
Open "writes.txt" For Output As #88
Dim Shared cpu As cpus
Dim Shared cop0 As cop0s
Dim Shared port As ports
Dim Shared As UInteger logWrites = 0, logfile = 0, splitLog = 10000000
#Define RD  	((cpu.opcode Shr 11) And &h1F)
#Define RT  	((cpu.opcode Shr 16) And &h1F)
#Define RS  	((cpu.opcode Shr 21) And &h1F)
#Define SA		((cpu.opcode Shr 6)  And &h1f)
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

#Define debug 'Debug logging

Sub loadBIOS
If FileExists("BIOS\SCPH1001.BIN") Then Open "BIOS\SCPH1001.BIN" for binary as #1 Else Print "Please provide a valid BIOS ROM"
get #1,, cpu.bios()
close #1
End Sub
Sub initCPU
	'cpu.current_PC = &hBFC00000
	cpu.current_PC = cpu.Reset_Vector
	cop0.reg(12) Or= &h400000 'Set BEV
	'gpu.GPUSTAT(3) = &h10 'Set bit 28
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
			For i As Integer = 0 To 3
			cpu.opcode Or= (cpu.memory((cpu.current_PC+i)And &h1FFFFF) Shl i*8)
			Next
	'''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &hA0000000 To &hA01FFFFF
			For i As Integer = 0 To 3
			cpu.opcode Or= (cpu.memory((cpu.current_PC+i)And &h1FFFFF) Shl i*8)
			Next
	'''''''''''''''''''''''''''''''''''''''''''''''''''''
		case &h1FC00000 to &h1FC7FFFF
			For i As Integer = 0 To 3
				cpu.opcode Or= (cpu.bios((cpu.current_PC+i)And &h7FFFF) Shl i*8)
			Next
	'''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &hBFC00000 To &hBFC7FFFF
			For i As Integer = 0 To 3
			cpu.opcode Or= (cpu.bios((cpu.current_PC+i) And &h7FFFF) Shl i*8)
			Next
	'''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case Else 
			Print #99, "Instruction Fetch Failure" 
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
		'If port.memMirror = 5 Then cpu.memSize = 8 
		'Print "Memory Size: " & cpu.memSize
		Case &h1070 To &h1073 'interrupt Enable
			port.iEnable or= (value Shl (24-((addr And &h3)*8))) 
		Case &h1074 To &h1077 'Interrupt Mask
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''			
		Case &h1080 To &h1083 'DMA0 Registers
			If addr And &h3 = 0 Then DMA0.base_address = 0
			DMA0.base_address Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA0 Base Address"
			If (addr And 3) = 3 Then Print #99, Hex(DMA0.base_address)
		Case &h1084 To &h1087
			If addr And &h3 = 0 Then DMA0.block_control = 0
			DMA0.block_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA0 Block Control"
			If (addr And 3) = 3 Then Print #99, Hex(DMA0.block_control)
			checkTrigger(0)
		Case &h1088 To &h108B
			If addr And &h3 = 0 Then DMA0.channel_control = 0
			DMA0.channel_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA0 Channel Control"
			If (addr And &h3) = 3 Then print Hex(DMA0.channel_control)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''			
		Case &h1090 To &h1093 'DMA1 Registers
			If addr And &h3 = 0 Then DMA1.base_address = 0
			DMA1.base_address Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA1 Base Address"
			If (addr And 3) = 3 Then Print #99, Hex(DMA1.base_address)
		Case &h1094 To &h1097
			If addr And &h3 = 0 Then DMA1.block_control = 0
			DMA1.block_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA1 Block Control"
			If (addr And 3) = 3 Then Print #99, Hex(DMA1.block_control)
			checkTrigger(1)
		Case &h1098 To &h109B
			If addr And &h3 = 0 Then DMA1.channel_control = 0
			DMA1.channel_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA1 Channel Control"
			If (addr And &h3) = 3 Then print Hex(DMA1.channel_control)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''			
		Case &h10A0 To &h10A3 'DMA2 Registers
			If addr And &h3 = 0 Then DMA2.base_address = 0
			DMA2.base_address Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA2 Base Address" 
			If (addr And 3) = 3 Then Print #99, Hex(DMA2.base_address)
		Case &h10A4 To &h10A7
			If addr And &h3 = 0 Then DMA2.block_control = 0
			DMA2.block_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA2 Block Control"
			If (addr And 3) = 3 Then Print #99, Hex(DMA2.block_control)
			checkTrigger(2)
		Case &h10A8 To &h10AB
			If addr And &h3 = 0 Then DMA2.channel_control = 0
			DMA2.channel_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA2 Channel Control"
			If (addr And &h3) = 3 Then print Hex(DMA2.channel_control)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''			
		Case &h10B0 To &h10B3 'DMA3 Registers
			If addr And &h3 = 0 Then DMA3.base_address = 0
			DMA3.base_address Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA3 Base Address"
			If (addr And 3) = 3 Then Print #99, Hex(DMA3.base_address)
		Case &h10B4 To &h10B7
			If addr And &h3 = 0 Then DMA3.block_control = 0
			DMA3.block_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA3 Block Control"
			If (addr And 3) = 3 Then Print #99, Hex(DMA3.block_control)
			checkTrigger(3)
		Case &h10B8 To &h10BB
			If addr And &h3 = 0 Then DMA3.channel_control = 0
			DMA3.channel_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA Channel Control"
			If (addr And &h3) = 3 Then print Hex(DMA3.channel_control)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h10C0 To &h10C3 'DMA4 Registers
			If addr And &h3 = 0 Then DMA4.base_address = 0
			DMA4.base_address Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA4 Base Address"
			If (addr And 3) = 3 Then Print #99, Hex(DMA4.base_address)
		Case &h10C4 To &h10C7
			If addr And &h3 = 0 Then DMA4.block_control = 0	
			DMA4.block_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA4 Block Control"
			If (addr And 3) = 3 Then Print #99, Hex(DMA4.block_control)
			checkTrigger(4)
		Case &h10C8 To &h10CB
			If addr And &h3 = 0 Then DMA4.channel_control = 0
			DMA4.channel_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA4 Channel Control"
			If (addr And &h3) = 3 Then print Hex(DMA4.channel_control)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h10D0 To &h10D3 'DMA5 Registers
			If addr And &h3 = 0 Then DMA5.base_address = 0
			DMA5.base_address Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA5 Base Address"
			If (addr And 3) = 3 Then Print #99, Hex(DMA5.base_address)
		Case &h10D4 To &h10D7
			If addr And &h3 = 0 Then DMA5.block_control = 0
			DMA5.block_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA5 Block Control"
			If (addr And 3) = 3 Then Print #99, Hex(DMA5.block_control)
			checkTrigger(5)
		Case &h10D8 To &h10DB
			If addr And &h3 = 0 Then DMA5.channel_control = 0
			DMA5.channel_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA5 Channel Control"
			If (addr And &h3) = 3 Then print Hex(DMA5.channel_control)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h10E0 To &h10E3 'DMA6 Registers
			If addr And &h3 = 0 Then DMA6.base_address = 0
			DMA6.base_address Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA6 Base Address"
			If (addr And 3) = 3 Then Print #99, Hex(DMA6.base_address)
		Case &h10E4 To &h10E7
			If addr And &h3 = 0 Then DMA6.block_control = 0	
			DMA6.block_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA6 Block Control"
			If (addr And 3) = 3 Then Print #99, Hex(DMA6.block_control)
			checkTrigger(6)
		Case &h10E8 To &h10EB
			If addr And &h3 = 0 Then DMA6.channel_control = 0
			DMA6.channel_control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Set DMA6 Channel Control"
			If (addr And &h3) = 3 Then print Hex(DMA6.channel_control)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h10F0 To &h10F3
			If addr And &h3 = 0 Then dma_Control = 0
			dma_Control Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Writing DMA Control"
			If (addr And &h3) = 3 Then Print dma_Control
		Case &h10F4 To &h10F7
			If addr And &h3 = 0 Then dma_Interrupt = 0 
			dma_Interrupt Or=(value Shl(24-((addr And &h3)*8)))
			Print #99, "Writing DMA Interrupt"
			If (addr And &h3) = 3 Then Print #99, (dma_Interrupt)
		Case &h1100 To &h1120 'Timers
		Case &h1800 To &h1804 'CD ROM
		Case &h1810	'GP0
			gpuCommand(&h1810)
		Case &h1814	'GP1
			temp or= (value shl(24-((addr and &h3)*8)))
			If (addr And 3) = 3 Then gp1Command(temp)
		Case &h1820 To &h1828 'MDEC
		Case &hC000 To &h1FFF 'SPU
	End Select
	Else
	addr And= &hFFFF
	Select Case addr
		Case &h130 To &h133 'Cache Control 
			'Print "Addr: " & addr
			'Print "Value: " & value
			'sleep
	End Select
	endif
'	Print port.memMirror
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
		 	Print #88, "Writing KSEG 0"
''''''''''''''''''''''''''''''''''''''''''''''''''''''''		 	
		Case &hA0000000 To &hA07FFFFF 'KSEG1
			cpu.memory(addr And &h1FFFFF) = value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''			
		Case &h1F800000 To &h1F8003FF 'Scratchpad
			cpu.dCache(addr And &h3FF) = value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1F801000 To &h1F801FFC 'I/O Ports
			Print #99, "Writing I/O Port at: " & Hex(addr)
			writeIO(addr, value)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1F000000 To &h1F7FFFFF 'Expansion Region
			cpu.expansion(addr And &h7FFFFF) = value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1F802041
			cpu.bootStatus = value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &hFFFE0130 To &hFFFE0133
			Print #99, "Writing Cache Control " & Hex(addr)
			writeIO(addr, value)
			
		Case Else 
			Print #99, "Bad write"
			Print #99, "ADDRESS: " & Hex(addr)
			Print #99, "DATA: " & Hex(value)
	End Select
	Else
	'cpu.iCache(addr And &Hfff) = value 
	EndIf
	return 0 
End Function
Function ReadIO(ByVal addr As UInteger) As ubyte
	Dim value As UByte
	Select Case addr
		Case &h1f8010f0 To &h1f8010f3
			value = ((dma_Control Shr (8*(addr And 3))) And &hFF)
			Print #99, "Reading DMA Control"
		Case &h1f8010f4 To &h1f8010F7
			value = ((dma_Interrupt Shr (8*(addr And 3))) And &hFF)
			Print #99, "Reading DMA Interrupt"
		Case &h1f801814 To &h1f801817
			value = ((gpu.GPUSTAT Shr (8*(addr And 3))) And &hFF) 
			Print #99, "Reading GPUSTAT!" 

	End Select
	
	Return value
End Function
Function ReadByte(ByVal addr As UInteger) As UInteger
		'Memory is split into a few different regions
		dim value as ubyte 
	Select Case addr
		Case &h0 To &h7FFFFF 'KSEG0
			value = cpu.memory(addr And &h1FFFFF) 
		Case &h80000000 To &h801FFFFF 'KSEG0 
		 	value = cpu.memory(addr And &h1FFFFF) 
		Case &hA0000000 To &hA01FFFFF 'KSEG1
			value = cpu.memory(addr And &h1FFFFF) 
		Case &hBFC00000 To &hBFC7FFFF 'BIOS(Read only)
			value = cpu.bios(addr and &h7FFFF)
		Case &h1F000000 To &h1F7FFFFF 'Expansion Port
			value = cpu.expansion(addr And &h7FFFFF)
		Case &h1F8010F0 To &h1F8010F3
			value = (dma_Interrupt Shr ((addr And 3)*8) And &hFF)
			Print #99, "Reading DMA Control"
		Case &h1F801000 To &h1F801FFC 'I/O Ports
			Print #99, "Reading I/O Port at: " & Hex(addr)
			value = ReadIO(addr)
		'Case &h1FC00000 To &h1FC7FFFF
		'	value = cpu.bios(addr - &h1FC00000)
		Case Else 
			Print #99, "Bad Read Address at: " & Hex(addr)
	End Select
	return value
End Function
Sub loadDelay 'Fix this
    For i As Integer = 1 To &h1F
        Select Case cpu.fGPR(i)
        Case 0
            cpu.dGPR(i) = cpu.GPR(i)
        Case 1
            cpu.GPR(i) = cpu.dGPR(i)
            cpu.fGPR(i) = 0
        Case 2
            'Do Nothing
            cpu.fGPR(i) = 1
        End select
    	cpu.GPR(i) = cpu.dGPR(i)
    Next
End Sub
