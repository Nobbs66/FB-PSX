Declare Sub Check_Overflow
Declare Sub loadBIOS
Declare Sub validBIOS
Declare Function Write32(ByVal addr As UInteger, ByVal value As UByte) As UInteger
Declare function Read32(ByVal addr As UInteger) As UInteger
Type cpus
	Dim memory(&h200000) As UByte
	Dim iCache(&hFFF) As ubyte
	Dim dCache(&h400) As UByte
	Dim GPR(32) As UInteger
	Dim current_PC As UInteger
	Dim old_PC As UInteger
	Dim delay_slot_PC As UInteger 
	Dim branch_queued As UByte
	Dim HI As UInteger
	Dim LO As UInteger
	Dim bios(&h80000) As UByte
	Dim opcode As UInteger
	Dim Operation As String
   const Reset_Vector As UInteger = &hBFC00000
End Type
Dim Shared cpu As cpus

#Define RD  	((cpu.opcode Shr 11) And &h1F)
#Define RT  	((cpu.opcode Shr 16) And &h1F)
#Define RS  	((cpu.opcode Shr 21) And &h1F)
#Define OP		((cpu.opcode Shr 
#Define SA		(cpu.opcode And &h1f)
#Define imm 	(cpu.opcode And &hFFFF)
#Define Offset ((cpu.opcode And &hFFFF) Shl 2)
#Define Target ((cpu.opcode And &h3FFFFFF) Shl 2)

Sub loadBIOS
Open "BIOS\SCPH1001.BIN" for binary as #1
for i as uinteger  = 0 to &h80000
get #1, i, cpu.bios(i-1)
if eof(1) then exit For
Next
close #1
End Sub
Sub fetchInstruction 'Copies 4 bytes to a 32-bit opcode variable
	cpu.opcode = cpu.memory(cpu.current_PC)
	cpu.opcode Or= (cpu.memory(cpu.current_PC+1) Shl 8)
	cpu.opcode Or= (cpu.memory(cpu.current_PC+2) Shl 16)
	cpu.opcode Or= (cpu.memory(cpu.current_PC+3) Shl 24) 
End Sub
Sub decodeInstruction
	'Must stop working on this or Blyss won't have any work to do...
	
	Select Case (cpu.opcode Shr 26)
		Case &h0 'Special 
			Select Case(cpu.opcode And &h3F)
				Case &h20
					cpu.Operation = "ADD"
				Case &h21
					cpu.Operation = "ADDU"
				Case &h24
					cpu.Operation = "AND"
				Case &h0D
					cpu.Operation = "BREAK"
				Case &h1A
					cpu.Operation = "DIV"
				Case &h1B
					cpu.Operation = "DIVU"
				Case &h09
					cpu.Operation = "JALR"
				Case &h08
					cpu.Operation = "JR"
				Case &h10
					cpu.Operation = "MFHI"
				Case &h12
					cpu.Operation = "MFLO"
				Case &h11
					cpu.Operation = "MTHI"
				Case &h13
					cpu.Operation = "MTLO"
			End Select
		Case &h1
		Case &h2
		Case &hD
			cpu.Operation = "ORI"
	End Select
End Sub
Sub Check_Overflow
	
End Sub
Function Write32(ByVal addr As UInteger, ByVal value As UByte) As uinteger
	'Memory is split into a few different regions
	
End Function
function Read32(ByVal addr As UInteger) As UInteger
	
End Function

