Declare Sub modifyRAM
Declare Sub modfyGPR
Declare Sub menu
Declare Sub breakPoint
Declare Sub checkDebug
Declare Sub dumRAM
Declare Sub writeLog
Declare Sub dumpMemory

'#Define debug
Sub dumpRAM
	
End Sub
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
Sub dumpMemory
	Open "mem.txt" For Output As #77
	For i As Integer = 0 To &h1FFFFC Step 4
		Print #77, "ADDR: " & Hex(i) & "   " & Hex(cpu.memory(i+3)) & " " & Hex(cpu.memory(i+2)) & " " & Hex(cpu.memory(i+1)) & " " & Hex(cpu.memory(i))
	Next
End Sub
Sub dumpRegisters
	Open "regs.txt" For Output As #55
	For i As Integer = 1 To &h1F
		Print #55, i & " " & Hex(cpu.GPR(i))
	Next
	Print #55, "PC: " & Hex(cpu.current_PC)
End Sub
Sub writeLog
Print #99, "-----------------------------------"
print #99, "Program Counter: " & hex(cpu.current_PC-4)
Print #99, "Opcode: " & Hex(cpu.opcode) & " = " & cpu.Operation 
Print #99, "A2: " & Hex(cpu.GPR(6)) 
Print #99, cpu.instructions
Print #99, Hex(SR)
Print #99, "Boot Status: " & cpu.bootStatus
Print #99, "-----------------------------------"
logWrites+=1
If logWrites >= splitlog Then
	logfile+=1
	logWrites = 0
	Close #99
	Open "logs/log" + Str(logFile) + ".txt" For Output As #99
EndIf
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