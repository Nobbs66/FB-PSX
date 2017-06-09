'ALU Operations
Declare Sub CPU_ADD
Declare Sub CPU_ADDI
Declare Sub CPU_ADDIU
Declare Sub CPU_ADDU
Declare Sub CPU_AND
Declare Sub CPU_ANDI
Declare Sub CPU_DIV
Declare Sub CPU_DIVU
Declare Sub CPU_MULT
Declare Sub CPU_MULTU
Declare Sub CPU_NOR
Declare Sub CPU_OR
Declare Sub CPU_ORI
Declare Sub CPU_SLL
Declare Sub CPU_SLLV
Declare Sub CPU_SRA
Declare Sub CPU_SRAV
Declare Sub CPU_SRL
Declare Sub CPU_SRLV
Declare Sub CPU_SUB
Declare Sub CPU_SUBU
Declare Sub CPU_XOR
Declare Sub CPU_XORI
'Read Modify Write Operations
Declare Sub CPU_LB
Declare Sub CPU_LBU
Declare Sub CPU_LH
Declare Sub CPU_LHU
Declare Sub CPU_LUI
Declare Sub CPU_LW
Declare Sub CPU_LWL
Declare Sub CPU_LWR
Declare Sub CPU_MFHI
Declare Sub CPU_MFLO
Declare Sub CPU_MTLO
Declare Sub CPU_SB
Declare Sub CPU_SH
Declare Sub CPU_SW
Declare Sub CPU_SWL
Declare Sub CPU_SWR
'Misc. Operations
Declare Sub CPU_SLT
Declare Sub CPU_SLTI
Declare Sub CPU_SLTIU
Declare Sub CPU_SLTU
Declare Sub CPU_SYSCALL
'Logic Flow Operations 
Declare Sub CPU_BEQ
Declare Sub CPU_BGEZ
Declare Sub CPU_BGEZAL
Declare Sub CPU_BGTZ
Declare Sub CPU_BLEZ
Declare Sub CPU_BLTZ
Declare Sub CPU_BLTZAL
Declare Sub CPU_BNE
Declare Sub CPU_BREAK
Declare Sub CPU_JMP
Declare Sub CPU_JAL
Declare Sub CPU_JALR
Declare Sub CPU_JR
'Coprocessor Operations
Declare Sub CPU_CFCz
Declare Sub CPU_COPz
Declare Sub CPU_CTCz
Declare Sub CPU_LWCz
Declare Sub CPU_MFCz
Declare Sub CPU_MTCz
Declare Sub CPU_SWCz

Sub CPU_ADD
	cpu.GPR(RD) = cpu.GPR(RS) + cpu.GPR(RT)
	Check_Overflow
End Sub
Sub CPU_ADDI
	cpu.GPR(RT) = cpu.GPR(RS) + imm
	Check_Overflow
End Sub
Sub CPU_ADDIU
	Dim As UInteger temp = imm And &h8000
	If temp = 1 Then temp = imm Or &hFFFF0000 Else temp = imm
	cpu.GPR(RT) = temp + cpu.GPR(RS)
End Sub
Sub CPU_ADDU
	cpu.GPR(RD) = cpu.GPR(RS) + cpu.GPR(RT)
End Sub
Sub CPU_AND
	cpu.GPR(RD) = cpu.GPR(RS) And cpu.GPR(RT)
End Sub
Sub CPU_ANDI
	cpu.GPR(RT)= cpu.GPR(RS) And imm
End Sub
Sub CPU_BEQ
	If cpu.GPR(RS) = cpu.GPR(RT) Then cpu.current_PC += Offset
End Sub
Sub CPU_BGEZ
	Dim As uinteger test = ((cpu.GPR(RS) And &h80000000)Shr 31)
	If test = 0 Then cpu.current_PC += Offset
End Sub
Sub CPU_BGEZAL
	Dim As UInteger test = ((cpu.GPR(RS) And &h80000000)Shr 31)
	If test = 0 Then cpu.current_PC += Offset
	cpu.GPR(31) = cpu.current_PC + 8	
End Sub
Sub CPU_BGTZ
	Dim As UByte test = ((cpu.GPR(RS) And &h80000000)Shr 31)
	If ((test = 0) And (RS <> 0)) Then cpu.current_PC += Offset
End Sub
Sub CPU_BLEZ
	Dim As UByte test = ((cpu.GPR(RS) And &h80000000)Shr 31)
	If test = 1 Then cpu.current_PC += Offset	
End Sub
Sub CPU_BLTZ
	Dim As UByte test = ((cpu.GPR(RS) And &h80000000)Shr 31)
	If ((test = 1) And (RS <> 0)) Then cpu.delay_slot_PC = cpu.current_PC + 4
	If ((test = 1) And (RS <> 0)) Then cpu.current_PC += Offset
	If ((test = 1) And (RS <> 0)) Then cpu.branch_queued = 1 
End Sub
Sub CPU_BLTZAl
	Dim As UByte test = ((cpu.GPR(RS) And &h80000000)Shr 31)
	If ((test = 0) And (RS <> 0)) Then cpu.current_PC += Offset
	cpu.GPR(31) = cpu.current_PC + 8 
End Sub
Sub CPU_BNE
	If cpu.GPR(RS) <> cpu.GPR(RT) Then cpu.current_PC += Offset	
End Sub
Sub CPU_BREAK
	'Breakpoint Exception
End Sub
Sub CPU_CFCz
	
End Sub
Sub CPU_COPz
	
End Sub
Sub CPU_CTCz
	
End Sub
Sub CPU_DIV
	
End Sub
Sub CPU_DIVU
	
End Sub
Sub CPU_J
	cpu.current_PC += Target
End Sub
Sub CPU_JAL
	cpu.GPR(31) = cpu.current_PC + 8 
	cpu.current_PC += Target
End Sub
Sub CPU_JALR
	cpu.GPR(RD) = cpu.current_PC + 8 
	cpu.current_PC += cpu.GPR(RS)
End Sub
Sub CPU_JR
	cpu.current_PC += cpu.GPR(RS)
End Sub
Sub CPU_NOR 'Maybe correct????
	Dim As UInteger tRD = (RD xor &hFFFFFFFF)
	Dim As UInteger tRT = (RT Xor &hFFFFFFFF)
	Dim As UInteger tRS = (RS Xor &hFFFFFFFF)
	cpu.GPR(RD) = cpu.GPR(tRS) Or cpu.GPR(tRT)
End Sub
Sub CPU_OR
	cpu.GPR(RD) = cpu.GPR(RS) Or cpu.GPR(RT)
End Sub
Sub CPU_ORI
	cpu.GPR(RT)= cpu.GPR(RS) Or imm	
End Sub
Sub CPU_SLL
	cpu.GPR(RD) = cpu.GPR(RT) Shl SA
End Sub
Sub CPU_SLLV
	cpu.GPR(RD) = cpu.GPR(RT) Shl  cpu.GPR(RS)
End Sub
Sub CPU_SLT
	Dim As Integer tRT = cpu.GPR(RT)
	Dim As Integer tRS = cpu.GPR(RS)
	If tRS < tRT Then cpu.GPR(RD) = 1 Else cpu.GPR(RD) = 0
End Sub
Sub CPU_SLTI
	Dim As Integer tImm = imm
	Dim As Integer tRS = cpu.GPR(RS)
	If tRS < tImm Then cpu.GPR(RT) = 1 Else cpu.GPR(RT) = 0 
End Sub
Sub CPU_SLTIU 'Might be correct without sign extension? 
	If cpu.GPR(RS) < imm Then cpu.GPR(RT) = 1 Else cpu.GPR(RT) = 0
End Sub
Sub CPU_SLTU
	If cpu.GPR(RS) < cpu.GPR(RT) Then cpu.GPR(RD) = 1 Else cpu.GPR(RD) = 0 
End Sub
Sub CPU_SRA
	Dim As Integer temp = cpu.GPR(RT) Shr SA 
	cpu.GPR(RD) = temp
End Sub
Sub CPU_SRAV
	Dim As Integer temp = cpu.GPR(RT) Shr  cpu.GPR(RS)
	cpu.GPR(RD) = temp
End Sub
Sub CPU_SRL
	cpu.GPR(RD) = cpu.GPR(RT) Shr SA
End Sub
Sub CPU_SRLV
	cpu.GPR(RD) = cpu.GPR(RT) Shr  cpu.GPR(RS)
End Sub
Sub CPU_SUB
	cpu.GPR(RD) = cpu.GPR(RS) - cpu.GPR(RT)
	Check_Overflow
End Sub
Sub CPU_SUBU
	cpu.GPR(RD) = cpu.GPR(RS) - cpu.GPR(RT)
End Sub
Sub CPU_SYSCALL
	Dim As UInteger code = ((cpu.opcode Shr 6) And &hFFFFF)
	Exception(code,0)
End Sub
Sub CPU_XOR
	cpu.GPR(RD) = cpu.GPR(RS) Xor cpu.GPR(RT)
End Sub
Sub CPU_XORI
	cpu.GPR(RT)= cpu.GPR(RS) xor imm	
End Sub



