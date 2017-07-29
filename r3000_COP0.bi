'The PSX lacks a TLB and just mirrors addresses


''''''''''''''''''''''NOTES''''''''''''''''''''''
'

 

Const As UInteger eGeneral = &h80000080 'General Exception
Const As UInteger eBreak	= &h80000040 'COP0 Break Exception
Const As UInteger eReset	= &hBFC00000 'Reset Exception 


Declare Function Exception(ByVal syscall As UInteger, ByVal eType As UByte, ByVal addr As UInteger) As UInteger
Declare Sub checkInterrupt
Function Exception(ByVal syscall As UInteger, ByVal eType As UByte, ByVal addr As UInteger) As UInteger
	Dim As UInteger handler
	if BEV = 0 Then
		handler = &h80000080
	Else
		handler = &hBFC00180
	EndIf    
	
	EPC = cpu.current_PC
	CAUSE = eType
	cpu.current_PC = handler - 4
	'Print "SR: " & BEV
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