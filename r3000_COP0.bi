'The PSX lacks a TLB and just mirrors addresses


''''''''''''''''''''''NOTES''''''''''''''''''''''
'

 
Type cop0s
	reg(0 To &h31) As UInteger 
End Type
Dim Shared cop0 As cop0s
#Define BPC 		(cop0.reg(3)) 	'Breakpoint on executed 
#Define BDA 		(cop0.reg(5)) 	'Breakpoint on data access
#Define JUMPDEST 	(cop0.reg(6)) 	'Randomly memorised jump address
#Define DCIC 		(cop0.reg(7)) 	'Breakpoint Control
#Define BadVaddr 	(cop0.reg(8)) 	'Bad virtual address
#Define BDAM 		(cop0.reg(9)) 	'Data access breakpoint mask
#Define BPCM 		(cop0.reg(11)) 'Execute breakpoint mask
#Define SR 			(cop0.reg(12)) 'Status register
#Define CAUSE 		(cop0.reg(13)) 'Exception Cause
#Define EPC 		(cop0.reg(14)) 'Exception program counter
#Define PRID 		(cop0.reg(15)) 'Processor ID


#Define BEV (((cop0.reg(8) Shr 22) And 1)) 'Bootstrap Exception Vector 


Const As UInteger eGeneral = &h80000080 'General Exception
Const As UInteger eBreak	= &h80000040 'COP0 Break Exception
Const As UInteger eReset	= &hBFC00000 'Reset Exception 


Declare Function Exception(ByVal syscall As UInteger, ByVal eType As UByte, ByVal addr As UInteger) As UInteger
Declare Sub checkInterrupt
Function Exception(ByVal syscall As UInteger, ByVal eType As UByte, ByVal addr As UInteger) As UInteger
	Print "Exception" 
	Sleep
	
	EPC = cpu.current_PC
	CAUSE = eType
	
	Select Case eType
		Case 0 'Interrupt
			
		Case 4 'Address Error - Load
		Case 5 'Address Error - Store
		Case 6 'Bus Error - Instruction Fetch 
		Case 7 'Bus Error - Data Fetch
		Case 8 'Sycall
			If (BEV = 0) Then 'Check bootstrap status
				cpu.current_PC = eGeneral
			EndIf
	
		Case 9 'Breakpoint 
			If BEV = 0 Then cpu.current_PC = eBreak
			
		Case 11 'Coprocessor Unusable
			cpu.current_PC  = eGeneral
			Print "Coprocessor Unusable "
		Case 12 'Overflow
	End Select

	Return 0
End Function
Sub checkInterrupt
	Dim As UByte srMask = ((SR Shr 8) And &hF)
	Dim As UByte test  = port.iEnable And port.iMask
	If port.iEnable <> 0 Then 
		If test = srMask  Then 
			Select Case port.iEnable
				Case 0 'VBlank
				Case 1 'GPU
				Case 2 'CDROM
				Case 3 'DMA
				Case 4 'TMR0 (Sysclk or Dotclk) 
				Case 5 'TMR1 (Sysclk or HBlank)
				Case 6 'TMR2 (Sysclk or Sysclk/8)
				Case 7 'Controller or Memory card
				Case 8 'SIO
				Case 9 'SPU
				Case 10 'Controller - Lightpen 
			End Select
		EndIf
	EndIf
End Sub