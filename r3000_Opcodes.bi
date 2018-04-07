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
Declare Sub CPU_LI
Declare Sub CPU_LUI
Declare Sub CPU_LW
Declare Sub CPU_LWL
Declare Sub CPU_LWR
Declare Sub CPU_MFHI
Declare Sub CPU_MFLO
Declare Sub CPU_MTLO
Declare Sub CPU_MTHI
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
Declare Sub CPU_CFC1 'CFCz
Declare Sub CPU_CFC2 'CFCz
Declare Sub CPU_CFC3 'CFCz
Declare Sub CPU_COP0 'COPz
Declare Sub CPU_COP2 'COPz
Declare Sub CPU_CTC2 'CTCz
Declare Sub CPU_LWC2
Declare Sub CPU_MFC0 'MFCz
Declare Sub CPU_MFC2 'MFCz
Declare Sub CPU_MTC0 'MTCz
Declare Sub CPU_MTC2 'MTCz
Declare Sub CPU_SWC2
Declare Sub CPU_NULL 
Declare Sub decode_instruction
Dim Shared SPECIAL(0 To 63) As Sub() => _
{	@CPU_SLL , @CPU_NULL , @CPU_SRL , @CPU_SRA , @CPU_SLLV   , @CPU_NULL , @CPU_SRLV, @CPU_SRAV,_
	@CPU_JR  , @CPU_JALR , @CPU_NULL, @CPU_NULL, @CPU_SYSCALL, @CPU_BREAK, @CPU_NULL, @CPU_NULL,_
	@CPU_MFHI, @CPU_MTHI , @CPU_MFLO, @CPU_MTLO, @CPU_NULL   , @CPU_NULL , @CPU_NULL, @CPU_NULL,_
	@CPU_MULT, @CPU_MULTU, @CPU_DIV , @CPU_DIVU, @CPU_NULL   , @CPU_NULL , @CPU_NULL, @CPU_NULL,_
	@CPU_ADD , @CPU_ADDU , @CPU_SUB , @CPU_SUBU, @CPU_AND    , @CPU_OR   , @CPU_XOR , @CPU_NOR ,_
	@CPU_NULL, @CPU_NULL , @CPU_SLT , @CPU_SLTU, @CPU_NULL   , @CPU_NULL , @CPU_NULL, @CPU_NULL,_
	@CPU_NULL, @CPU_NULL , @CPU_NULL, @CPU_NULL, @CPU_NULL   , @CPU_NULL , @CPU_NULL, @CPU_NULL,_
	@CPU_NULL, @CPU_NULL , @CPU_NULL, @CPU_NULL, @CPU_NULL   , @CPU_NULL , @CPU_NULL, @CPU_NULL} 
Dim Shared REGIMM(0 To 31) As Sub () => _
{	@CPU_BLTZ  , @CPU_BGEZ  , @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL,_
	@CPU_NULL  , @CPU_NULL  , @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL,_
	@CPU_BLTZAL, @CPU_BGEZAL, @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL,_
	@CPU_NULL  , @CPU_NULL  , @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL}
Dim Shared BASIC(0 To 63) As Sub () => _
{	@CPU_NULL   , @CPU_NULL	 , @CPU_JMP   , @CPU_JAL  , @CPU_BEQ , @CPU_BNE , @CPU_BLEZ, @CPU_BGTZ,_
	@CPU_ADDI   , @CPU_ADDIU , @CPU_SLTI, @CPU_SLTIU, @CPU_ANDI, @CPU_ORI , @CPU_XORI, @CPU_LUI ,_
	@CPU_COP0   , @CPU_NULL  , @CPU_COP2, @CPU_NULL , @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL,_
	@CPU_NULL   , @CPU_NULL  , @CPU_NULL, @CPU_NULL , @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL,_
	@CPU_LB     , @CPU_LH    , @CPU_LWL , @CPU_LW   , @CPU_LBU , @CPU_LHU , @CPU_LWR , @CPU_NULL,_
	@CPU_SB     , @CPU_SH    , @CPU_SWL , @CPU_SW   , @CPU_NULL, @CPU_NULL, @CPU_SWR , @CPU_NULL,_
	@CPU_NULL   , @CPU_NULL  , @CPU_LWC2, @CPU_NULL , @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL,_ 
	@CPU_NULL   , @CPU_NULL  , @CPU_SWC2, @CPU_NULL , @CPU_NULL, @CPU_NULL, @CPU_NULL, @CPU_NULL}
Sub CPU_NULL
	Print "Unrecognized CPU Instruction"
End Sub
Sub CPU_ADD
	cpu.Operation = "ADD"
	cpu.GPR(RD) = (cpu.GPR(RS)) + (cpu.GPR(RT))
	checkOverflow
End Sub
Sub CPU_ADDI
	cpu.Operation = "ADDI"
	Dim As Integer temp = CShort(imm)
	cpu.GPR(RT) = cpu.GPR(RS) + temp
End Sub
Sub CPU_ADDIU
	cpu.Operation = "ADDIU"
	Dim As Integer temp = Cshort(imm)
	cpu.GPR(RT) = temp + cpu.GPR(RS)
End Sub
Sub CPU_ADDU
	cpu.Operation = "ADDU"
	cpu.GPR(RD) = cpu.GPR(RS) + cpu.GPR(RT)
End Sub
Sub CPU_AND
	cpu.Operation = "AND"
	cpu.GPR(RD) = cpu.GPR(RS) And cpu.GPR(RT)
End Sub
Sub CPU_ANDI
	cpu.Operation = "ANDI"
	cpu.GPR(RT)= cpu.GPR(RS) And imm
End Sub
Sub CPU_BEQ
	cpu.Operation = "BEQ"
	If cpu.GPR(RS) = cpu.GPR(RT) Then 
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	EndIf
End Sub
Sub CPU_BGEZ
	cpu.Operation = "BEQ"
	Dim As uinteger test = ((cpu.GPR(RS) And &h80000000)Shr 31)
	If test = 0 Then 
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	EndIf
End Sub
Sub CPU_BGEZAL
	cpu.Operation = "BGEZAL"
	Dim As UInteger test = CInt(cpu.GPR(RS))
	If test >= 0 Then 
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	EndIf
	cpu.GPR(31) = cpu.current_PC + 8
End Sub
Sub CPU_BGTZ
	cpu.Operation = "BGTZ"
	Dim As UInteger test = CInt(cpu.GPR(RS))
	If test > 0 Then 
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	EndIf

End Sub
Sub CPU_BLEZ
	cpu.Operation = "BLEZ"
	Dim As UByte test = CInt(cpu.GPR(RS))
	If test <= 0 Then 
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	EndIf
End Sub
Sub CPU_BLTZ
	cpu.Operation = "BLTZ"
	Dim As UByte test = CInt(cpu.GPR(RS))
	If test < 0 Then 
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	EndIf
End Sub
Sub CPU_BLTZAl
	cpu.Operation = "BLTZAL"
	Dim As UByte test = CInt(cpu.GPR(RS))
	If test < 0 Then 
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	EndIf
	cpu.GPR(31) = cpu.current_PC + 8
End Sub
Sub CPU_BNE
	cpu.Operation = "BNE"
	If cpu.GPR(RS) <> cpu.GPR(RT) Then 
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	EndIf
End Sub
Sub CPU_BREAK
	'Breakpoint Exception
	Exception(9)
End Sub
Sub CPU_CFC2
	Print "COP2"
	Dim As UByte temp = ((SR Shr 30) And 1)
	If temp <> 0 Then 
		cpu.GPR(RT) = gte.gc(RD)
	Else 
		Exception(11) 'COP2 Unusable 
	EndIf
End Sub
Sub CPU_COP0
	Select Case (cpu.opcode And &h1ffffff)
		Case &h10
			RFE
	End Select
End Sub
Sub CPU_COP2
	Print "COP2"
	Dim As UByte temp = ((SR Shr 30) And 1) 
	If temp <> 0 Then
		'Execute Coprocessor Function
	Else
		Exception(11) 'COP2 Unusable
	EndIf
End Sub
Sub CPU_CTC2
	Print "COP2"
	
	Dim As UByte temp = ((SR Shr 30) And 1) 
	If temp <> 0 Then
		gte.gc(RD) = cpu.GPR(RT)
	Else
		Exception(11) 'COP2 Unusable
	EndIf
End Sub
Sub CPU_DIV
	cpu.Operation = "DIV"
	If cpu.GPR(RT) <> 0 Then 
		Dim As Integer dRS = CInt(cpu.GPR(RS))
		Dim As Integer dRT = CInt(cpu.GPR(RT))
		cpu.LO = dRS / dRT
		cpu.HI = dRS Mod dRT
	EndIf
End Sub
Sub CPU_DIVU
	cpu.Operation = "DIVU"
	If cpu.GPR(RT) <> 0 Then 
		cpu.LO = cpu.GPR(RS) / cpu.GPR(RT)
		cpu.HI = cpu.GPR(RT) Mod cpu.GPR(RT)
	EndIf 
End Sub
Sub CPU_JMP
	cpu.Operation = "J"
	cpu.delay_slot_PC = cpu.current_PC And &hF0000000
	cpu.delay_slot_PC or= Target 
	cpu.branch_queued = 2
End Sub
Sub CPU_JAL
	cpu.Operation = "JAL"
	cpu.GPR(31) = cpu.current_PC + 8
	cpu.delay_slot_PC = cpu.current_PC And &hF0000000
	cpu.delay_slot_PC or= Target 
	cpu.branch_queued = 2
End Sub
Sub CPU_JALR
	cpu.Operation = "JALR"
	dim as integer temp = cint(cpu.GPR(RS))
	cpu.GPR(RD) = cpu.current_PC + 8
	cpu.delay_slot_PC = temp
	cpu.branch_queued = 2
End Sub
Sub CPU_JR
	cpu.Operation = "JR"
	Dim As Integer temp = CInt(cpu.GPR(RS))
	cpu.delay_slot_PC = temp
	cpu.branch_queued = 2
End Sub
Sub CPU_LB
	cpu.Operation = "LB"
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	Dim As Integer value = ReadByte(addr)
	cpu.GPR(RT) = CByte(value)
	cpu.fGPR(RT) = 2
	if (addr shr 24) = &hA0 then cpu.cpu_Cycles += 6
End Sub
Sub CPU_LBU
	cpu.Operation = "LBU"
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	cpu.GPR(RT) = ReadByte(addr)
	cpu.delayFlag = 2
	if (addr shr 24) = &hA0 then cpu.cpu_Cycles += 6
End Sub
Sub CPU_LH
	cpu.Operation = "LH"
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	Dim As Byte test = addr And 1
	Dim load As integer
	For i As uInteger = 0 To 1
	load Or= (ReadByte(addr+i) Shl i*8)
	Next
	cpu.GPR(RT) = CShort(load)
	cpu.fGPR(RT) = 2
	if (addr shr 24) = &hA0 then cpu.cpu_Cycles += 6
End Sub
Sub CPU_LHU
	cpu.Operation = "LHU"
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	Dim As Byte test = addr And 1
	Dim load As integer
	For i As uInteger = 0 To 1
	load Or= (ReadByte(addr+i) Shl i*8)
	Next
	cpu.GPR(RT) = load
	cpu.fGPR(RT) = 2
End Sub
Sub CPU_LUI 
	cpu.Operation = "LUI"
	cpu.GPR(RT) = (imm Shl 16)
	cpu.fGPR(RT) = 2
End Sub
Sub CPU_LW
	cpu.Operation = "LW"
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	Dim As Byte test = addr And 1
	cpu.GPR(RT) = 0 
	Dim load As integer
	For i As Integer = 0 To 3
	load or= (ReadByte(addr+(3-i)) Shl (24-(i*8)))
	Next
	cpu.GPR(RT) = load
	cpu.fGPR(RT) = 2
	if (addr shr 24) = &hA0 then cpu.cpu_Cycles += 6
End Sub
Sub CPU_LWC2
	Print "COP2"
	Dim As UByte temp = ((SR Shr 30) And 1) 
	If temp <> 0 Then 
		Dim As Integer temp = Offset 
		temp += cpu.GPR(RS)
		Dim As Byte test = temp And 1
		cpu.GPR(RT) = 0 
		Dim load As integer
		For i As Integer = 0 To 3
			load Or= (cpu.memory(temp+i) Shl i*8)
		Next
		gte.gd(RT) = load	
	Else 
		Exception(11) 'COP2 Unusable 
	EndIf
End Sub

Sub CPU_LWL
	'print #99, "Unimplemented Op: LWL" 
	Print "LWL"
End Sub
Sub CPU_LWR
	'print #99, "Unimplemented Op: LWR"
	Print "LWR"
End Sub
Sub CPU_MFC0
	cpu.Operation = "MFCO"
	Dim As UByte KUc = SR And &h2 'Check for Kernel Mode
	If  KUC = 2 Then 
		Dim As UByte temp = ((SR Shr 28) And 1) 
		If temp <> 0 Then 
			cpu.GPR(RT) = cop0.reg(RD)
		Else 
			Exception(11) 'COP0 Unusable 
		EndIf
	Else 
		cpu.GPR(RT) = cop0.reg(RD)
	EndIf
End Sub
Sub CPU_MFC2
	Print "COP2"
	Dim As UByte temp = ((SR Shr 30) And 1) 
	If temp <> 0 Then 
		cpu.GPR(RT) = gte.gd(RD)	
	Else 
		Exception(11) 'COP2 Unusable 
	EndIf
End Sub
Sub CPU_MFHI
	cpu.Operation = "MFHI"
	cpu.GPR(RD) = cpu.HI
End Sub

Sub CPU_MFLO
	cpu.Operation = "MFLO"
	cpu.GPR(RD) = cpu.LO
End Sub
Sub CPU_MTC0
	cpu.Operation = "MTCO"
	Dim As UByte KUc = SR And &h2 'Check for Kernel Mode
	If KUc = 2 Then 
		Dim As UByte temp = ((SR Shr 28) And 1)
		If temp <> 0 Then 
		Else 
			Exception(11) 'COP0 Unusable 
		EndIf
	Else
		cop0.reg(RD) = cpu.GPR(RT)
	EndIf		
End Sub
Sub CPU_MTC2
	Print "COP2"
	Dim As UByte temp = ((SR Shr 30) And 1) 
	If temp <> 0 Then 
		gte.gd(RD) = cpu.GPR(RT)	
	Else 
		Exception(11) 'COP2 Unusable 
	EndIf
End Sub
Sub CPU_MTHI
	cpu.Operation = "MTHI"
	cpu.HI = cpu.GPR(RS)
End Sub
Sub CPU_MTLO
	cpu.Operation = "MTLO"
	cpu.LO = cpu.GPR(RS)
End Sub
Sub CPU_MULT
	cpu.Operation = "MULT"
	Dim As Integer mRS = CInt(cpu.GPR(RS))
	Dim As Integer mRT = CInt(cpu.GPR(RT))
	Dim As ULongInt result = mRS * mRT
	cpu.LO = result And &hFFFFFFFF
	cpu.HI = (result Shr 32) And &hFFFFFFFF 
End Sub
Sub CPU_MULTU
	cpu.Operation = "MULTU"
	dim as ulongint result = cpu.GPR(RS) * cpu.GPR(RT)
	cpu.LO = result And &hFFFFFFFF
	cpu.HI = (result Shr 32) And &hFFFFFFFF 
End Sub
Sub CPU_NOR
	cpu.Operation = "NOR"
	cpu.GPR(rd) = Not(cpu.GPR(rs) Or cpu.GPR(rt))
End Sub
Sub CPU_OR
	cpu.Operation = "OR"
	cpu.GPR(RD) = cpu.GPR(RS) Or cpu.GPR(RT)
End Sub
Sub CPU_ORI
	cpu.Operation = "ORI"
	cpu.GPR(RT)= cpu.GPR(RS) + imm
End Sub
Sub CPU_SB
	cpu.Operation = "SB"
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	Dim As Integer value = cpu.GPR(RT) And &hFF
	WriteByte(addr,value)
	If (addr shr 24) = &hA0 then cpu.cpu_Cycles += 6
End Sub

Sub CPU_SH
	cpu.Operation = "SH"
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	Dim load As Byte
	For i As Integer = 0 To 1
		load = ((cpu.GPR(RT) Shr i*8) And &hFF)
		WriteByte(addr+i,load)
	Next
	if (addr shr 24) = &hA0 then cpu.cpu_Cycles += 6
End Sub
Sub CPU_SLL
	cpu.Operation = "SLL"
	cpu.GPR(RD) = cpu.GPR(RT) Shl SA
End Sub
Sub CPU_SLLV
	cpu.Operation = "SLLV"
	cpu.GPR(RD) = cpu.GPR(RT) Shl  (cpu.GPR(RS) And &h1F)
End Sub
Sub CPU_SLT
	cpu.Operation = "SLT"
	Dim As Integer tRS = CInt(cpu.GPR(RS))
	Dim As Integer tRT = CInt(cpu.GPR(RT))
	If tRS < tRT Then cpu.GPR(RD) = 1 Else cpu.GPR(RD) = 0
End Sub
Sub CPU_SLTI
	cpu.Operation = "SLTI"
	Dim As Integer tImm = CShort(imm)
	Dim As Integer tRS = CInt(cpu.GPR(RS))
	If tRS < tImm Then cpu.GPR(RT) = 1 Else cpu.GPR(RT) = 0
End Sub
Sub CPU_SLTIU
	cpu.Operation = "SLTIU"
	If cpu.GPR(RS) < CShort(imm) Then cpu.GPR(RT) = 1 Else cpu.GPR(RT) = 0
End Sub
Sub CPU_SLTU
	cpu.Operation = "SLTU"
	If cpu.GPR(RS) < cpu.GPR(RT) Then cpu.GPR(RD) = 1 Else cpu.GPR(RD) = 0
End Sub
Sub CPU_SRA
	cpu.Operation = "SRA"
	Dim As Integer temp = cpu.GPR(RT) Shr SA
	cpu.GPR(RD) = temp
End Sub
Sub CPU_SRAV
	cpu.Operation = "SRAV"
	Dim As Integer temp = cpu.GPR(RT) Shr  cpu.GPR(RS)
	cpu.GPR(RD) = temp
End Sub
Sub CPU_SRL
	cpu.Operation = "SRL"
	cpu.GPR(RD) = cpu.GPR(RT) Shr SA
End Sub
Sub CPU_SRLV
	cpu.Operation = "SRLV"
	cpu.GPR(RD) = cpu.GPR(RT) Shr  cpu.GPR(RS)
End Sub
Sub CPU_SUB
	cpu.Operation = "SUB"
	cpu.GPR(RD) = cpu.GPR(RS) - cpu.GPR(RT)
	checkOverflow
End Sub
Sub CPU_SUBU
	cpu.Operation = "SUBU"
	cpu.GPR(RD) = cpu.GPR(RS) - cpu.GPR(RT)
End Sub
Sub CPU_SW
	cpu.Operation = "SW"
	Dim As UInteger addr = cpu.GPR(RS) + Cshort(imm)
	Dim As Byte test = addr And 1
	Dim load As Byte
	For i As Integer = 0 To 3
		load = ((cpu.GPR(RT) Shr i*8) And &hFF)
		WriteByte(addr+i,load)
		cpu.storeValue = load 
	Next
	if (addr shr 24) = &hA0 then cpu.cpu_Cycles += 6
End Sub

Sub CPU_SWC2
	Print "COP2"
	'print #99, "Unimplemented Op"
End Sub

Sub CPU_SWL
	'print #99, "Unimplemented Op"
End Sub

Sub CPU_SWR
	'print #99, "Unimplemented Op"
End Sub
Sub CPU_SYSCALL
	Dim As UInteger code = ((cpu.opcode Shr 6) And &hFFFFF)
	Exception(8)
End Sub
Sub CPU_XOR
	cpu.GPR(RD) = cpu.GPR(RS) Xor cpu.GPR(RT)
End Sub
Sub CPU_XORI
	cpu.GPR(RT)= cpu.GPR(RS) xor imm
End Sub
Sub decodeInstruction
	Select Case (cpu.opcode Shr 21)
		Case &h242 'CFZ0
			cpu.Operation = "CFC2"
			CPU_CFC2
		Case &h246 'CTC2
			cpu.Operation = "CTC2"
			CPU_CTC2
		Case &h204 'MTC0
			cpu.Operation = "MTC0"
			CPU_MTC0
		Case &h244 'MTC2
			cpu.Operation = "MTC2"
			CPU_MTC2
		Case &h200 'MFC0
			cpu.Operation = "MFC0"
			CPU_MFC0
		Case &h240 'MFC2
			cpu.Operation = "MFC2"
			CPU_MFC2
		Case Else
	End Select
	Select Case (cpu.opcode Shr 26)
		Case &h0 'Special
			SPECIAL(cpu.opcode And &h3F)()
		Case &h1 'REGIMM
			REGIMM((cpu.opcode Shr 16) And &h1F)()
		Case Else
			BASIC((cpu.opcode Shr 26)And &h3F)()
	End Select
End Sub



