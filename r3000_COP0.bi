'The PSX lacks a TLB and just mirrors addresses
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

Const As UInteger eGeneral = &h80000080 'General Exception
Const As UInteger eBreak	= &h80000040 'COP0 Break Exception
Const As UInteger eReset	= &hBFC00000 'Reset Exception 
Declare Sub checkInterrupts
Declare Sub RFE
Sub Exception(ByVal eType As UByte)
    'Print "Exception! " & Hex(eType)
    
    Dim As UInteger handler
    if BEV = 0 Then
        handler = &h80000080
    Else
        handler = &hBFC00180
    EndIf    
    If cpu.branch_queued <> 0 Then 
        EPC = cpu.current_PC - 4
        'print #99, "Exception in Delay Slot"
    Else 
        EPC = cpu.current_PC
    EndIf
    CAUSE And= Not(&h7E)
    CAUSE or= (eType Shl 2)
    cpu.current_PC = handler - 4
End Sub
Sub RFE
	Dim As UInteger temp = SR
	temp =  (temp And Not(&hf)) Or ((temp Shr 2) And &hF)
	SR = temp
End Sub

'Sub checkInterrupt
'	Dim As UByte srMask = ((SR Shr 8) And &hF)
'	Dim As UByte test  = port.iEnable And port.iMask
'	If port.iEnable <> 0 Then 
'		If test = srMask  Then 
'			Select Case port.iEnable
'				Case 0 'VBlank
'				Case 1 'GPU
'				Case 2 'CDROM
'				Case 3 'DMA
'				Case 4 'TMR0 (Sysclk or Dotclk) 
'				Case 5 'TMR1 (Sysclk or HBlank)
'				Case 6 'TMR2 (Sysclk or Sysclk/8)
'				Case 7 'Controller or Memory card
'				Case 8 'SIO
'				Case 9 'SPU
'				Case 10 'Controller - Lightpen 
'			End Select
'		EndIf
'	EndIf
'End Sub

Sub checkInterrupts

	Dim As UInteger comp = port.iStat And port.iMask
	
	If comp <> 0  Then 
		If SR = &h401 Then 
			CAUSE Or= 1 Shl 10
			If (CAUSE And &h400) = &h400 Then 
		
				
				port.iStat = 0
				
				Print "Doing Interrupt: " & comp
				
				Exception(0)
			
			Else
				cop0.reg(13) And= Not(1 Shl 10)
			EndIf
		EndIf
	EndIf
End Sub


		'		Print "Interrupt TEST"
		'		Print "IRQ Write: " & Hex(port.iStat)
		'		Print "IRQ MASK: " & Hex(port.iMask)
		'		Print "STATUS: " & Hex(cop0.reg(12))
		
		'		Print #111, "Interrupt at: " & Hex(cpu.current_PC)
		'		Print #111, "Interrpt after: " & cpu.cpu_clocks