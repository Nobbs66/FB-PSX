Declare Sub modifyRAM
Declare Sub modfyGPR
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
