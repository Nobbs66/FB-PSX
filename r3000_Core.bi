Declare Sub checkOverflow
Declare Sub loadBIOS
Declare Sub validBIOS
Declare Sub initCPU
Declare Sub loadDelay

Declare Sub Exception(ByVal eType As UByte)
Declare Sub setInterrupt(ByVal intc As UByte)
Declare Sub printsr
Declare Sub requestIRQ(ByVal irq As UByte)
#Include "cdrom.bi"
Declare Function WriteByte(ByVal addr As UInteger, ByVal value As UByte) As UInteger
Declare Function writeWord(ByVal addr As UInteger, value As UInteger) As UByte
Declare function ReadByte(ByVal addr As UInteger) As UInteger
Declare Function readWord(ByVal addr As UInteger) As UInteger
Declare Sub set_I_Read(ByVal value As UInteger)


Dim Shared As UInteger temp 


Type cop0s
	reg(0 To &h31) As UInteger 
End Type

Type ports
	memMirror As UByte '2mb or 8mb memory config
	iStat As UInteger 'Interrupt Enable - Edge Sensitive
	iMask As UInteger 'Interrupt Mask 
	cacheCtrl As UInteger 
	temp As UByte = 1
	r_stat As UInteger
End Type


Const As UInteger KUSEG = &h1FFFFF
Const As UInteger KSEG0 = &h80000000
Const As UInteger KSEG1 = &hA0000000
Open "logs/log0.txt" For Output As #99
'Open "writes.txt" For Output As #88
Open "logs/Interrupts.txt" For Output As #111
Dim Shared cop0 As cop0s
Dim Shared port As ports
Dim Shared As UInteger logWrites = 0, logfile = 1, splitLog = 10000000
#Define RD  	((cpu.opcode Shr 11) And &h1F)
#Define RT  	((cpu.opcode Shr 16) And &h1F)
#Define RS  	((cpu.opcode Shr 21) And &h1F)
#Define SA		((cpu.opcode Shr 6)  And &h1f)
#Define imm 	(cpu.opcode And &hFFFF)
#Define Offset ((cpu.opcode And &hFFFF) Shl 2)
#Define Target ((cpu.opcode And &h3FFFFFF) Shl 2)




#Define BEV (((cop0.reg(12) Shr 22) And 1)) 'Bootstrap Exception Vector 

#Define debug 'Debug logging

Sub loadBIOS
If FileExists("BIOS\SCPH1001.BIN") Then Open "BIOS\SCPH1001.BIN" for binary as #1 Else 'print "Please provide a valid BIOS ROM"
get #1,, cpu.bios()
close #1
End Sub
Sub initCPU
	cpu.current_PC = cpu.Reset_Vector
	cop0.reg(12) Or= &h400000 'Set BEV
	'gpu.GPUSTAT(3) = &h10 'Set bit 28
End Sub



Sub set_I_Read(ByVal value As UInteger)
	port.r_stat = value
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
			Print "PANIC! Bad Instruction Fetch at: " & Hex(cpu.current_PC)
			sleep
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
		Case &h1000 To &h1020 'Memory Control 1
		Case &h1040 To &h105F 'Peripheral IO
		Case &h1061 			 'Memory Control 2
		port.memMirror = (value Shr 1)
		Case &h1070 To &h1073 'interrupt Enable
			If (addr And &h3) = 0 Then port.iStat = 0
			temp or= value Shl ((addr And &h3)*8)
			port.iStat And= Not(temp)
			Print #111, "I-Stat Write: " & Hex(port.iStat)
		Case &h1074 To &h1077 'Interrupt Mask
			If (addr And &h3) = 0 Then port.iMask = 0
			port.iMask Or= value Shl ((addr And &h3)*8)
			port.iMask And= &h7FF
			Print #111, "I-Mask Write: " & Hex(port.iMask)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''			
		Case &h1080 To &h1083 'DMA0 Registers
			Print "MDEC DMA?"
			If addr And &h3 = 0 Then DMA0.base_address = 0
			DMA0.base_address Or=value Shl((addr And &h3)*8)
		Case &h1084 To &h1087
			Print "MDEC DMA?"
			If addr And &h3 = 0 Then DMA0.block_control = 0
			DMA0.block_control Or=value Shl((addr And &h3)*8)
		Case &h1088 To &h108B
			Print "MDEC DMA?"
			If addr And &h3 = 0 Then DMA0.channel_control = 0
			DMA0.channel_control Or=value Shl((addr And &h3)*8)
			checkTrigger(0)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''			
		Case &h1090 To &h1093 'DMA1 Registers
			Print "MDEC DMA?"
			If addr And &h3 = 0 Then DMA1.base_address = 0
			DMA1.base_address Or=value Shl((addr And &h3)*8)
		Case &h1094 To &h1097
			Print "MDEC DMA?"
			If addr And &h3 = 0 Then DMA1.block_control = 0
			DMA1.block_control Or=value Shl((addr And &h3)*8)
		Case &h1098 To &h109B
			Print "MDEC DMA?"
			If addr And &h3 = 0 Then DMA1.channel_control = 0
			DMA1.channel_control Or=value Shl((addr And &h3)*8)
			checkTrigger(1)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''			
		Case &h10A0 To &h10A3 'DMA2 Registers
			If addr = &h10A0 Then DMA2.base_address = 0
			DMA2.base_address Or=value Shl((addr And &h3)*8)
		Case &h10A4 To &h10A7
			If addr = &h10A4 Then DMA2.block_control = 0
			DMA2.block_control Or=value Shl((addr And &h3)*8)
		Case &h10A8 To &h10AB
			If addr = &h10A8 Then DMA2.channel_control = 0
			DMA2.channel_control Or=value Shl((addr And &h3)*8)
			checkTrigger(2)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''			
		Case &h10B0 To &h10B3 'DMA3 Registers
			If addr And &h3 = 0 Then DMA3.base_address = 0
			DMA3.base_address Or=value Shl((addr And &h3)*8)
			Print "CD DMA"
		Case &h10B4 To &h10B7
			If addr And &h3 = 0 Then DMA3.block_control = 0
			DMA3.block_control Or=value Shl((addr And &h3)*8)
			Print "CD DMA"
		Case &h10B8 To &h10BB
			If addr And &h3 = 0 Then DMA3.channel_control = 0
			DMA3.channel_control Or=value Shl((addr And &h3)*8)
			Print "CD DMA"
			checkTrigger(3)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h10C0 To &h10C3 'DMA4 Registers
			Print "SPU DMA"
			If &h10C0 - addr = 0 Then DMA4.base_address = 0
			DMA4.base_address Or=value Shl((addr And &h3)*8)
		Case &h10C4 To &h10C7
			Print "SPU DMA"
			If &h10C4 - addr = 0 Then DMA4.block_control = 0	
			DMA4.block_control Or=value Shl((addr And &h3)*8)
		Case &h10C8 To &h10CB
			Print "SPU DMA"
			If &h10C8 - addr = 0 Then DMA4.channel_control = 0
			DMA4.channel_control Or=value Shl((addr And &h3)*8)
			checkTrigger(4)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h10D0 To &h10D3 'DMA5 Registers
			If &h10D0 - addr = 0 Then DMA5.base_address = 0
			DMA5.base_address Or=value Shl((addr And &h3)*8)
		Case &h10D4 To &h10D7
			If &h10D4 - addr = 0 Then DMA5.block_control = 0
			DMA5.block_control Or=value Shl((addr And &h3)*8)
		Case &h10D8 To &h10DB
			If &h10D8 - addr = 0 Then DMA5.channel_control = 0
			DMA5.channel_control Or=value Shl((addr And &h3)*8)
			checkTrigger(5)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h10E0 To &h10E3 'DMA6 Registers
			If &h10E0 - addr = 0 Then DMA6.base_address = 0
			DMA6.base_address Or=value Shl((addr And &h3)*8)
		Case &h10E4 To &h10E7
			If &h10E4 - addr = 0 Then DMA6.block_control = 0	
			DMA6.block_control Or=value Shl((addr And &h3)*8)
		Case &h10E8 To &h10EB
			If &h10E8 - addr = 0 = 0 Then DMA6.channel_control = 0
			DMA6.channel_control Or= value Shl((addr And &h3)*8)
			checkTrigger(6)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h10F0 To &h10F3
			If addr = &h10F0 Then dma_Control = 0
			dma_Control Or=value Shl((addr And &h3)*8)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h10F4 To &h10F7
			If addr = &h10F4 Then dma_Interrupt = 0 
			dma_Interrupt Or=value Shl((addr And &h3)*8)
			Print "writing dma interrupt"
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1100 To &h1120 'Timers
		Case &h1800 To &h1804 'CD ROM
		Print "Writing to CD Reg: " & Hex(addr) 
		Print "Value written: " & Hex(value)
		
		CdWrite(addr,value)
		If cd.cheat = 1 Then set_I_Read(1 Shl 2)
		If addr = &h1801 And index = 0 Then 
			cop0.reg(12) Or= 1 Shl 10
		EndIf
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1810	To &h1813'GP0
			If addr = &h1810 Then temp = 0 
			temp or= value Shl ((addr And &h3) * 8)
			If addr = &h1813 Then 
				gpu.command_Buffer(0) = temp
				gpuCommand()
			EndIf

		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1814	To &h1817'GP1
			If addr = &h1814 Then temp = 0 
			'print #99, "GP1 Command: " & value
			temp or= value Shl ((addr And &h3) * 8)
		'	If addr = &h1817 Then gp1Command(temp)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1820 To &h1828 'MDEC
		Case &hC000 To &h1FFF 'SPU
	End Select
	Else
	addr And= &hFFFF
	Select Case addr
		Case &h130 To &h133 'Cache Control 
	End Select
	EndIf
	Return 0 
End Function

Function WriteByte(ByVal addr As UInteger, ByVal value As UByte) As uinteger
	'Memory is split into a few different regions
	Dim As UByte IsC = ((cop0.reg(12) Shr 16) And 1)
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
			writeIO(addr, value)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1F000000 To &h1F7FFFFF 'Expansion Region
			cpu.expansion(addr And &h7FFFFF) = value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1F802041
			cpu.bootStatus = value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &hFFFE0130 To &hFFFE0133
			writeIO(addr, value)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case Else 
			Print #99, "PANIC! Bad write at: " & Hex(addr)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	End Select
	Else
	EndIf
	return 0 
End Function
Function ReadIO(ByVal addr As UInteger) As ubyte
	Dim value As UByte
	Select Case addr
		''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1F801080 To &h1F801083 'MDEC IN
			value = ((DMA0.base_address Shr(8*addr And 3))) And &hFF
		Case &h1F801084 To &h1F801087
			value = ((DMA0.block_control Shr(8*addr And 3))) And &hFF
		Case &h1F801088 To &h1F80108B
			value = ((DMA0.channel_control Shr(8*addr And 3))) And &hFF
		''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1F801090 To &h1F801093 'MDEC IN
			value = ((DMA1.base_address Shr(8*addr And 3))) And &hFF
		Case &h1F801094 To &h1F801097
			value = ((DMA1.block_control Shr(8*addr And 3))) And &hFF
		Case &h1F801098 To &h1F80109B
			value = ((DMA1.channel_control Shr(8*addr And 3))) And &hFF
		''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1F8010A0 To &h1F8010A3 'GPU DMA
			value = ((DMA2.base_address Shr(8*addr And 3))) And &hFF
		Case &h1F8010A4 To &h1F8010A7
			value = ((DMA2.block_control Shr(8*(addr And 3))) And &hFF)
		Case &h1F8010A8 To &h1F8010AB
			value = ((DMA2.channel_control Shr(8*(addr And 3))) And &hFF)
		'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h1F8010B0 To &h1F8010B3 'CDROM DMA
			value = ((DMA3.base_address Shr(8*addr And 3))) And &hFF
			Print "CD DMA"
		Case &h1F8010B4 To &h1F8010B7
			value = ((DMA3.block_control Shr(8*addr And 3))) And &hFF
			Print "CD DMA"
		Case &h1F8010B8 To &h1F8010BB
			value = ((DMA3.channel_control Shr(8*addr And 3))) And &hFF
			Print "CD DMA"
		'''''''''''''''''''''''''''''''''''''''''''''''''''''''SPU DMA
		Case &h1F8010C0 To &h1F8010C3
			value = ((DMA4.base_address Shr(8*addr And 3))) And &hFF
			Print "SPU DMA"
		Case &h1F8010C4 To &h1F8010C7
			value = ((DMA4.block_control Shr(8*addr And 3))) And &hFF
			Print "SPU DMA"
		Case &h1F8010C8 To &h1F8010CB
			value = ((DMA4.channel_control Shr(8*addr And 3))) And &hFF
			Print "SPU DMA"
		'''''''''''''''''''''''''''''''''''''''''''''''''''''''PIO DMA
		Case &h1F8010D0 To &h1F8010D3
			value = ((DMA5.base_address Shr(8*addr And 3))) And &hFF
			Print "PIO DMA"
		Case &h1F8010D4 To &h1F8010D7
			value = ((DMA5.block_control Shr(8*addr And 3))) And &hFF
			Print "PIO DMA"
		Case &h1F8010D8 To &h1F8010DB
			value = ((DMA5.channel_control Shr(8*addr And 3))) And &hFF
		''''''''''''''''''''''''''''''''''''''''''''''''''OTC CLEAR DMA
		Case &h1F8010E0 To &h1F8010E3
			value = ((DMA6.base_address shr (8*(addr And 3))) And &hFF)
		Case &h1F8010E4 To &h1F8010E7
			value = ((DMA6.block_control shr (8*(addr And 3))) And &hFF)
		Case &h1F8010E8 To &h1F8010EB
			value = ((DMA6.channel_control shr (8*(addr And 3))) And &hFF)
		'''''''''''''''''''''''''''''''''''''''''''''''''''''DMA Control
		Case &h1f8010f0 To &h1f8010f3
			value = ((dma_Control shr (8*(addr And 3))) And &hFF)
		Case &h1f8010f4 To &h1f8010F7
			value = ((dma_Interrupt shr (8*(addr And 3))) And &hFF)
		'''''''''''''''''''''''''''''''''''''''''''''''''''''''GPU STAT
		Case &h1f801814 To &h1f801817
			value = ((gpu.GPUSTAT Shr (8*(addr And 3))) And &hFF) 
		'''''''''''''''''''''''''''''''''''''''''''''''''''''CD-ROM I/O
		Case &h1F801800 To &h1F801803
			Print "CDROM I/O Read" & Hex(addr)
			value = cdRead(addr)
		''''''''''''''''''''''''''''''''''''''''''''''''''''''''IRQ I/O
		Case &h1F801070 To &h1F801073
			value = ((port.r_stat Shr (8*(addr And 3)))And &hFF)
			Print #111, "I Stat Read: " & Hex(value)
		Case &h1F801074 To &h1F801077
			value = ((port.iMask Shr (8*(addr And 3))) And &hFF)
			Print #111, "I-Mask Read: " & Hex(value)
		'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	End Select
	
	Return value
End Function
Function ReadByte(ByVal addr As UInteger) As UInteger
	Dim value as ubyte 
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
		Case &h1F801000 To &h1F801FFC 'I/O Ports
			value = ReadIO(addr)
		Case Else 
			Print #99, "Bad Read Address at: " & Hex(addr)
	End Select
	return value
End Function
Function readWord(ByVal addr As UInteger) As UInteger
	Dim load As integer
	For i As Integer = 0 To 3
		load or= (ReadByte(addr+(3-i)) Shl (24-(i*8)))
	Next
	Return load
End Function
Function writeWord(ByVal addr As UInteger, value As UInteger) As UByte
	Dim load As Byte
	For i As Integer = 0 To 3
		load = ((value Shr i*8) And &hFF)
		WriteByte(addr+i,load)
	Next
Return 0
End Function
Sub printsr

	Print Hex(cop0.reg(12))
End Sub
Sub setIntc(ByVal irq As UByte)
	port.iStat Or= 1 Shl irq
End Sub
Sub requestIRQ(ByVal irq As UByte)
	cd.logReg = 1
	port.iStat Or= 1 Shl irq
	Dim As UInteger comp = port.iStat And port.iMask
	If comp <> 0  Then 
		If Bit(cop0.reg(12),0) = 1 Then 
			Cls
			Print "Starting IRQ"
			cop0.reg(13) Or= 1 Shl 10
			Print "SEtting Up"
			port.iStat = 0
			Print "Doing Exception"
			sleep
			Exception(0)
		Else
			Print "Status Register: " & Hex(cop0.reg(12))
		endif
	Else
		cop0.reg(13) And= Not(1 Shl 10)
	EndIf
End Sub