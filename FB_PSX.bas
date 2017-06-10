#Include Once "fbgfx.bi"
Using fb
#Include Once "file.bi"
#Include Once "r3000_Core.bi"
#Include Once "r3000_cop0.bi"
#Include Once "r3000_opcodes.bi"
#Include Once "debugger.bi"

loadBIOS
'This is for testing only. 
For i As Integer = 0 To &h7FFFF
	cpu.memory(i) = cpu.bios(i)
Next


If cpu.bios(0) = &h13 Then ScreenRes(640,480,32)
Do 

fetchInstruction
decodeInstruction
Print "Bytes: " & Hex(cpu.memory(cpu.current_PC)) & " " & Hex(cpu.memory(cpu.current_PC+1)) & " " & Hex(cpu.memory(cpu.current_PC+2)) & " " & Hex(cpu.memory(cpu.current_PC+3)) 
Print "Instruction: " & Hex(cpu.opcode)
Print "Operands: " & cpu.Operation & ": " & Hex(RS) & ", " & Hex(RT) & ", " & Hex(imm) 
Print ""
cpu.current_PC+=4
If MultiKey(SC_M) Then memoryModify  
'If cpu.current_PC >= &hFF Then cpu.current_PC = 0 
Sleep 100
Loop While Not MultiKey(SC_ESCAPE)
Sleep
