Declare Sub modifyRAM
Declare Sub modfyGPR
Declare Sub menu
Declare Sub breakPoint
Declare Sub checkDebug
Sub modifyRAM
	Dim As UInteger addr
	Dim As UByte value
	Input "Enter the address followed by the data ", addr, value
	cpu.memory(addr) = value
	Print "Address: " & Hex(addr) & " = " & Hex(cpu.memory(addr))
End Sub
Sub modifyGPR
	Dim As UInteger value
	Dim As UByte reg
	Input "Enter GPR followed by the data ", reg, value
	cpu.GPR(reg) = value
	Print "GPR: " & reg & " " & Hex(cpu.GPR(reg)) 
End Sub
Sub menu
	Dim As String in
	Input "Enter a command ", in
	Select Case in
	Case "Exit"
		CAE
	Case "Mem Dump"
		dumpMemory
	End Select
	
End Sub
Sub breakPoint
	Dim As UInteger break
'	Input "Enter a breakpoint ",cpu.bPoint
'	Print "Breakpoint set at: " & cpu.bPoint
End Sub
Sub checkDebug
	If MultiKey(SC_R) Then 
	modifyGPR
	Sleep 2000
	EndIf
If MultiKey(SC_M) Then 
	modifyRAM
	Sleep 2000
EndIf
If MultiKey(SC_C) Then 
	menu
	Sleep 1000
EndIf
If MultiKey(SC_B) Then 
	breakPoint
	Sleep 1000
EndIf
End Sub