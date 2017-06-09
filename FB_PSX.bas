#Include Once "fbgfx.bi"
#Include Once "file.bi"
#Include Once "r3000_Core.bi"
#Include Once "r3000_cop0.bi"
#Include Once "r3000_opcodes.bi"

Using fb
#Include Once "debugger.bi"

loadBIOS
For i As Integer = 0 To &hFF
	cpu.memory(i) = cpu.bios(i)
Next


If cpu.bios(0) = &h13 Then ScreenRes(640,480,32)
Do 
	

fetchInstruction
decodeInstruction
Print Hex(cpu.opcode)
Print cpu.Operation & ": " & Hex(RT) & ", " & Hex(imm) 
cpu.current_PC+=4
fetchInstruction
decodeInstruction
Print Hex(cpu.opcode)
Print cpu.Operation & ": " & Hex(RS) & ", " & Hex(RT) & ", " & Hex(imm) 
'cpu.Operation = "NO OP"
If MultiKey(SC_M) Then memoryModify  
If cpu.current_PC >= &hFF Then cpu.current_PC = 0 
Loop While Not MultiKey(SC_ENTER)
Sleep
