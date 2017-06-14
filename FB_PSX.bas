#Include Once "fbgfx.bi"
Using fb
#Include Once "file.bi"
#Include Once "r3000_Core.bi"
#Include Once "r3000_cop0.bi"
#Include Once "gte.bi"
#Include Once "r3000_opcodes.bi"
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


''''''''''''Initialize Emu'''''''''''''
'''''''''''''''''''''''''''''''''''''''
loadBIOS 
initCPU
If cpu.bios(0) = &h13 Then ScreenRes(640,480,32)
''''''''''''''Main Loop''''''''''''''''
'''''''''''''''''''''''''''''''''''''''
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

Loop While Not MultiKey(SC_ESCAPE)

