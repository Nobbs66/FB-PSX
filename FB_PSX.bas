#Include Once "fbgfx.bi"
Using fb
#Include Once "file.bi"
#Include Once "r3000_Core.bi"
#Include Once "r3000_cop0.bi"
#Include Once "gte.bi"
#Include Once "r3000_opcodes.bi"
Declare Sub CAE
#Include Once "debugger.bi"
Declare Sub runCPU

Sub runCPU
fetchInstruction
decodeInstruction	
Print Hex(cpu.current_PC)
Print "Operands: " & cpu.Operation & ": " & Hex(RS) & ", " & Hex(RT) & ", " & Hex(imm) 
Print "T0: " & Hex(cpu.GPR(8))
Print "-----------------------------------"
cpu.current_PC+=4
'If cpu.current_PC >= &hBFC00020 Then Sleep

End Sub
Sub CAE 'Close and Exit
	Print "Closing " 
End Sub

''''''''''''Initialize Emu'''''''''''''
'''''''''''''''''''''''''''''''''''''''
loadBIOS 
initCPU
If cpu.bios(0) = &h13 Then ScreenRes(640,480,32)
''''''''''''''Main Loop''''''''''''''''
'''''''''''''''''''''''''''''''''''''''
Do 
	cls
	Print "Press S to start"
	Sleep 10
Loop While Not MultiKey(SC_S)
cls
Do 
runCPU
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
Print "Memory Mirror: " & Hex(port.memMirror)
Print "T1: " & Hex(cpu.GPR(9))
Print Hex(cpu.memory(0)) & " " & Hex(cpu.memory(1)) & " " & Hex(cpu.memory(2)) & " " & Hex(cpu.memory(3))
Sleep 30


Loop While Not MultiKey(SC_ESCAPE)

