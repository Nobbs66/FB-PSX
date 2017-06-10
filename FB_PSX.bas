#Include Once "fbgfx.bi"
Using fb
#Include Once "file.bi"
#Include Once "r3000_Core.bi"
#Include Once "r3000_cop0.bi"
#Include Once "r3000_opcodes.bi"
#Include Once "debugger.bi"

loadBIOS 
initCPU


If cpu.bios(0) = &h13 Then ScreenRes(640,480,32)

Do 
fetchInstruction
decodeInstruction
Print Hex(cpu.current_PC)
Print "Operands: " & cpu.Operation & ": " & Hex(RS) & ", " & Hex(RT) & ", " & Hex(imm) 
Print ""
cpu.current_PC+=4
Loop While Not MultiKey(SC_ESCAPE)

