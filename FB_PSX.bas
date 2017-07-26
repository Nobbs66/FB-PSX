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
Dim As Integer instructions
#Define debug
declare sub writeLog
sub writeLog
print #99, hex(cpu.current_PC-4) & ": " &  cpu.Operation & ": " & Hex(RS) & ", " & Hex(RT) & ", " & Hex(imm) 
If cpu.storeAddress = 1 Then Print #99, Hex(cpu.storedAddress)
Print #99, "-----------------------------------"
end Sub
Sub runCPU
'Suspect Branch delay implementation
If cpu.branch_queued = 1 Then
	cpu.current_PC = cpu.delay_slot_PC
	cpu.branch_queued -= 1
Else 
	If cpu.branch_queued = 2 Then cpu.branch_queued -=1 
EndIf
fetchInstruction
decodeInstruction	
Print Hex(cpu.current_PC)
Print "Operands: " & cpu.Operation & ": " & Hex(RS) & ", " & Hex(RT) & ", " & Hex(imm) 
Print "-----------------------------------"

cpu.current_PC += 4
End Sub
Sub CAE 'Cleanup and Exit
	CLS
	Print "Closing " 
	Sleep 1000
	end
End Sub
''''''''''''Initialize Emu'''''''''''''
'''''''''''''''''''''''''''''''''''''''
loadBIOS 
initCPU
ScreenRes(600,800,32)

Do 
	cls
	Print "Press S to start"
	Sleep 10
Loop While Not MultiKey(SC_S)
Cls

'Main loop
Do 
runCPU
writeLog

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





#Ifdef debug
Print "Memory Mirror: " & Hex(port.memMirror)
Print "T1: " & Hex(cpu.GPR(9))
Print Hex(cpu.memory(0)) & " " & Hex(cpu.memory(1)) & " " & Hex(cpu.memory(2)) & " " & Hex(cpu.memory(3))
#EndIf



cpu.GPR(0) = 0
instructions += 1
cpu.storeAddress = 0 

'If cpu.current_PC >= cpu.bPoint Then sleep 
Print "Instructions Executed " &  instructions
Loop While Not MultiKey(SC_ESCAPE)

