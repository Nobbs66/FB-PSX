
#Include Once "fbgfx.bi"
Using fb
#Include Once "file.bi"
#Include Once "r3000_Core.bi"
#Include Once "r3000_cop0.bi"
#Include Once "gte.bi"
#Include Once "r3000_opcodes.bi"

Declare Sub CAE
declare sub writeLog
Declare Sub dumpMemory
#Include Once "debugger.bi"
Declare Sub runCPU

#Define debug

Sub writeLog
print #99, "Program Counter: " & hex(cpu.current_PC-4)
Print #99, "Opcode: " & Hex(cpu.opcode) & " = " & cpu.Operation 
If cpu.storeAddress = 1 Then Print #99, Hex(cpu.storedAddress)
Print #99, "A2: " & Hex(cpu.GPR(6)) 
Print #99, cpu.instructions
Print #99, "Boot Status: " & cpu.bootStatus
Print #99, "-----------------------------------"
end Sub
Sub dumpMemory
	Open "mem.txt" For Output As #77
	For i As Integer = 0 To &h1FFFFC Step 4
		Print #77, "ADDR: " & Hex(i) & "   " & Hex(cpu.memory(i+3)) & " " & Hex(cpu.memory(i+2)) & " " & Hex(cpu.memory(i+1)) & " " & Hex(cpu.memory(i))
	Next
End Sub
Sub dumpMemory2
	Open "memDump.txt" For Output As #66
	For i As Integer = &h30000 To &h1FFFFF step 16
		Print #66, Hex(i) &  " " & Hex(cpu.memory(i)) &  " " & Hex(cpu.memory(i+1)) &  " " & Hex(cpu.memory(i+2)) &  " " & Hex(cpu.memory(i+3)) &  " " & Hex(cpu.memory(i+4)) &  " " & Hex(cpu.memory(i+5)) &  " " & Hex(cpu.memory(i+6)) &  " " & Hex(cpu.memory(i+7)) &  " " & Hex(cpu.memory(i+8)) &  " " & Hex(cpu.memory(i+9)) &  " " & Hex(cpu.memory(i+10)) &  " " & Hex(cpu.memory(i+11)) &  " " & Hex(cpu.memory(i+12)) & " " & Hex(cpu.memory(i+13)) & " " & Hex(cpu.memory(i+14)) & " " & Hex(cpu.memory(i+15)) 
	next
End Sub
Sub dumpRegisters
	Open "regs.txt" For Output As #55
	For i As Integer = 1 To &h1F
		Print #55, i & " " & Hex(cpu.GPR(i))
	Next
End Sub
Sub runCPU
'loadDelay
'Suspect Branch delay implementation
If cpu.branch_queued = 1 Then
	cpu.current_PC = cpu.delay_slot_PC
	cpu.branch_queued -= 1
Else 
	If cpu.branch_queued = 2 Then cpu.branch_queued -=1 
EndIf
fetchInstruction
decodeInstruction	
cpu.current_PC += 4
End Sub
Sub CAE 'Cleanup and Exit
	dumpRegisters
	dumpMemory
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
'Wait for start input. 
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
cpu.GPR(0) = 0 'Keep Zero Register clean. 


Print #99, "T6: " & Hex(cpu.GPR(14))

cpu.instructions += 1




If cpu.instructions >= 60000000 Then CAE
If cpu.instructions Mod 5 = 0 Then Print "Instructions Executed " &  cpu.instructions
Loop While Not MultiKey(SC_ESCAPE)

