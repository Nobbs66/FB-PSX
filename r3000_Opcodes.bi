'ALU Operations
Declare Sub RFE
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
Declare Sub decode_instruction

Sub CPU_RFE
	Dim As uInteger temp = SR And &hFFFFFFC0
	temp Or= ((SR And &h3C) Shr 2)
	SR = temp
End Sub
Sub CPU_ADD
	cpu.GPR(RD) = (cpu.GPR(RS)) + (cpu.GPR(RT))
	checkOverflow
End Sub
Sub CPU_ADDI
	Dim As Integer temp = CShort(imm)
	cpu.GPR(RT) = cpu.GPR(RS) + temp
End Sub
Sub CPU_ADDIU
	Dim As Integer temp = Cshort(imm)
	cpu.GPR(RT) = temp + cpu.GPR(RS)
End Sub
Sub CPU_ADDU
	cpu.GPR(RD) = cpu.GPR(RS) + cpu.GPR(RT)
End Sub
Sub CPU_AND
	cpu.GPR(RD) = cpu.GPR(RS) And cpu.GPR(RT)
	Print #99, Hex(cpu.GPR(RS)) & ":" & Hex(cpu.GPR(RT)) & ":" & Hex(cpu.GPR(RD))
End Sub
Sub CPU_ANDI
	cpu.GPR(RT)= cpu.GPR(RS) And imm
End Sub
Sub CPU_BEQ
	If cpu.GPR(RS) = cpu.GPR(RT) Then 
		Print #99, "Branch = True"
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	Else
		Print #99, "Branch = False"
	EndIf
		Print #99, "REGS " & RS & " " & RT
End Sub
Sub CPU_BGEZ
	Dim As uinteger test = ((cpu.GPR(RS) And &h80000000)Shr 31)
	If test = 0 Then 
		Print #99, "Branch = True"
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	Else
		Print #99, "Branch = False"
	EndIf
End Sub
Sub CPU_BGEZAL
	Dim As UInteger test = CInt(cpu.GPR(RS))
	If test >= 0 Then 
		Print #99, "Branch = True"
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	Else
		Print #99, "Branch = False"
	EndIf
	cpu.GPR(31) = cpu.current_PC + 8
End Sub
Sub CPU_BGTZ
	Dim As UInteger test = CInt(cpu.GPR(RS))
	Print #99,  "RS: " & RS & " = " & Hex(cpu.GPR(RS))
	If test > 0 Then 
		Print #99, "Branch = True"
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	
	Else
		Print #99, "Branch = False"
	EndIf

End Sub
Sub CPU_BLEZ
	Dim As UByte test = CInt(cpu.GPR(RS))
	If test <= 0 Then 
		Print #99, "Branch = True"
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	Else
		Print #99, "Branch = False"
	EndIf
End Sub
Sub CPU_BLTZ
	Dim As UByte test = CInt(cpu.GPR(RS))
	If test < 0 Then 
		Print #99, "Branch = True"
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	Else
		Print #99, "Branch = False"
	EndIf
End Sub
Sub CPU_BLTZAl
	Dim As UByte test = CInt(cpu.GPR(RS))
	If test < 0 Then 
		Print #99, "Branch = True"
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	Else
		Print #99, "Branch = False"
	EndIf
	cpu.GPR(31) = cpu.current_PC + 8
End Sub
Sub CPU_BNE
	If cpu.GPR(RS) <> cpu.GPR(RT) Then 
		Print #99, "Branch = True"
		cpu.branch_queued = 2
		Dim As Short temp = CShort(imm)
		Dim As Integer bTarget = temp Shl 2
		cpu.delay_slot_PC = cpu.current_PC + bTarget + 4
	Else
		Print #99, "Branch = False"
	EndIf
End Sub
Sub CPU_BREAK
	'Breakpoint Exception
	Exception(0,9,0)
End Sub
Sub CPU_CFC2
	Dim As UByte temp = ((SR Shr 30) And 1)
	If temp <> 0 Then 
		cpu.GPR(RT) = gte.gc(RD)
	Else 
		Exception(0,11,0) 'COP2 Unusable 
	EndIf
End Sub
Sub CPU_COP0
Dim As UByte KUc = SR And &h2 'Check for Kernel Mode
If KUc = 2 Then 
	Dim As UByte temp = ((SR Shr 28) And 1)
	If temp <> 0 Then 
		'Execute Coprocessor Function
		
	Else 
		Exception(0,11,0) 'COP0 Unusable 
	EndIf
Else
	'Execute Coprocessor Function
endif
End Sub
Sub CPU_COP2
	Dim As UByte temp = ((SR Shr 30) And 1) 
	If temp <> 0 Then
		'Execute Coprocessor Function
	Else
		Exception(0,11,0) 'COP2 Unusable
	EndIf
End Sub
Sub CPU_CTC2
	Dim As UByte temp = ((SR Shr 30) And 1) 
	If temp <> 0 Then
		gte.gc(RD) = cpu.GPR(RT)
	Else
		Exception(0,11,0) 'COP2 Unusable
	EndIf
End Sub
Sub CPU_DIV
	If cpu.GPR(RT) <> 0 Then 
		Dim As Integer dRS = CInt(cpu.GPR(RS))
		Dim As Integer dRT = CInt(cpu.GPR(RT))
		cpu.LO = dRS / dRT
		cpu.HI = dRS Mod dRT
	EndIf
End Sub
Sub CPU_DIVU
	If cpu.GPR(RT) <> 0 Then 
		cpu.LO = cpu.GPR(RS) / cpu.GPR(RT)
		cpu.HI = cpu.GPR(RT) Mod cpu.GPR(RT)
	EndIf 
End Sub
Sub CPU_J
	cpu.delay_slot_PC = cpu.current_PC And &hF0000000
	cpu.delay_slot_PC or= Target 
	cpu.branch_queued = 2
End Sub
Sub CPU_JAL
	cpu.GPR(31) = cpu.current_PC + 8
	cpu.delay_slot_PC = cpu.current_PC And &hF0000000
	cpu.delay_slot_PC or= Target 
	cpu.branch_queued = 2
End Sub
Sub CPU_JALR
	dim as integer temp = cint(cpu.GPR(RS))
	cpu.GPR(RD) = cpu.current_PC + 8
	cpu.delay_slot_PC = temp
	cpu.branch_queued = 2
End Sub
Sub CPU_JR
	Dim As Integer temp = CInt(cpu.GPR(RS))
	cpu.delay_slot_PC = temp
	cpu.branch_queued = 2
End Sub
Sub CPU_LB
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	Dim As Integer value = ReadByte(addr)
	cpu.GPR(RT) = CByte(value)
	cpu.fGPR(RT) = 2
	#Ifdef debug
	Print #88, "-----------------------------------------------"
	Print #88, "ADDR: " & Hex(addr) & ":" & Hex(value)
	Print #88, "LB:" & Hex(cpu.current_PC)
	Print #88, "Cycles: " & cpu.instructions
	Print #88, "-----------------------------------------------"
	#EndIf
End Sub
Sub CPU_LBU
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	cpu.GPR(RT) = ReadByte(addr)
	cpu.delayFlag = 2
	#Ifdef debug
	Print #88, "-----------------------------------------------"
	Print #88, "LBU:" & Hex(cpu.current_PC)
	Print #88, "Cycles: " & cpu.instructions
	Print #88, "-----------------------------------------------"
	#EndIf
End Sub
Sub CPU_LH
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	Dim As Byte test = addr And 1
	Dim load As integer
	For i As uInteger = 0 To 1
	load Or= (ReadByte(addr+i) Shl i*8)
	Next
	#Ifdef debug
	Print #88, "-----------------------------------------------"
	Print #88, "ADDR: " & Hex(addr) & ":" & Hex(load)
	Print #88, "LH:" & Hex(cpu.current_PC)
	Print #88, "Cycles: " & cpu.instructions
	Print #88, "-----------------------------------------------"
	#EndIf
	cpu.GPR(RT) = CShort(load)
	cpu.fGPR(RT) = 2
End Sub
Sub CPU_LHU
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	Dim As Byte test = addr And 1
	Dim load As integer
	For i As uInteger = 0 To 1
	load Or= (ReadByte(addr+i) Shl i*8)
	Next
	#Ifdef debug
	Print #88, "-----------------------------------------------"
	Print #88, "ADDR: " & Hex(addr) & ":" & Hex(load)
	Print #88, "LHU:" & Hex(cpu.current_PC)
	Print #88, "Cycles: " & cpu.instructions
	Print #88, "-----------------------------------------------"
	#EndIf
	cpu.GPR(RT) = load
	cpu.fGPR(RT) = 2
End Sub
Sub CPU_LUI 
	cpu.GPR(RT) = (imm Shl 16)
	cpu.fGPR(RT) = 2
	#Ifdef debug
	Print #88, "-----------------------------------------------"
	Print #99, Hex(imm Shl 16)
	Print #99, Hex(cpu.GPR(RT))
	Print #88, "LUI: " & Hex(cpu.current_PC)
	Print #88, "Cycles: " & cpu.instructions &  " : " & Hex(imm)
	Print #88, "-----------------------------------------------"
	#EndIf
End Sub
Sub CPU_LW
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	Dim As Byte test = addr And 1
	cpu.GPR(RT) = 0 
	Dim load As integer
	For i As Integer = 0 To 3
	load or= (ReadByte(addr+(3-i)) Shl (24-(i*8)))
	Next
	#Ifdef debug
	Print #88, "-----------------------------------------------"
	Print #88, "ADDR: " & Hex(addr) & ":" & Hex(load)
	Print #88, "LW:" & Hex(cpu.current_PC)
	Print #88, cpu.instructions
	Print #88, "-----------------------------------------------"
	#EndIf
	cpu.GPR(RT) = load
	cpu.fGPR(RT) = 2
	
End Sub
Sub CPU_LWC2
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
		Exception(0,11,0) 'COP2 Unusable 
	EndIf
End Sub

Sub CPU_LWL
	#Ifdef debug
	Print #99, "Unimplemented Op: LWL" 
	#EndIf
End Sub
Sub CPU_LWR
	#Ifdef debug
	Print #99, "Unimplemented Op: LWR"
	#EndIf
End Sub
Sub CPU_MFC0	
Dim As UByte KUc = SR And &h2 'Check for Kernel Mode
If  KUC = 2 Then 
	Dim As UByte temp = ((SR Shr 28) And 1) 
	If temp <> 0 Then 
		cpu.GPR(RT) = cop0.reg(RD)
	Else 
		Exception(0,11,0) 'COP0 Unusable 
	EndIf
Else 
	cpu.GPR(RT) = cop0.reg(RD)
endif
End Sub
Sub CPU_MFC2
	Dim As UByte temp = ((SR Shr 30) And 1) 
	If temp <> 0 Then 
		cpu.GPR(RT) = gte.gd(RD)	
	Else 
		Exception(0,11,0) 'COP2 Unusable 
	EndIf
End Sub
Sub CPU_MFHI
	cpu.GPR(RD) = cpu.HI
End Sub

Sub CPU_MFLO
	cpu.GPR(RD) = cpu.LO
End Sub
Sub CPU_MTC0
Dim As UByte KUc = SR And &h2 'Check for Kernel Mode
If KUc = 2 Then 
		Dim As UByte temp = ((SR Shr 28) And 1)
		If temp <> 0 Then 
		Else 
			Exception(0,11,0) 'COP0 Unusable 
		EndIf
Else
	cop0.reg(RD) = cpu.GPR(RT)
endif		
End Sub
Sub CPU_MTC2
	Dim As UByte temp = ((SR Shr 30) And 1) 
	If temp <> 0 Then 
		gte.gd(RD) = cpu.GPR(RT)	
	Else 
		Exception(0,11,0) 'COP2 Unusable 
	EndIf
End Sub
Sub CPU_MTHI
	cpu.HI = cpu.GPR(RS)
End Sub
Sub CPU_MTLO
	cpu.LO = cpu.GPR(RS)
End Sub
Sub CPU_MULT
	Dim As Integer mRS = CInt(cpu.GPR(RS))
	Dim As Integer mRT = CInt(cpu.GPR(RT))
	Dim As ULongInt result = mRS * mRT
	cpu.LO = result And &hFFFFFFFF
	cpu.HI = (result Shr 32) And &hFFFFFFFF 
End Sub
Sub CPU_MULTU
	dim as ulongint result = cpu.GPR(RS) * cpu.GPR(RT)
	cpu.LO = result And &hFFFFFFFF
	cpu.HI = (result Shr 32) And &hFFFFFFFF 
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
	cpu.GPR(RT)= cpu.GPR(RS) + imm
End Sub

Sub CPU_SB
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	Dim As Integer value = cpu.GPR(RT) And &hFF
	WriteByte(addr,value)
	#Ifdef debug6
	Print #88, "addr: " & Hex(addr) & ":" & "value: " & Hex(value)
	Print #88, "SB" & Hex(cpu.current_PC)
	Print #88, "Cycles: " & cpu.instructions
	#endif
End Sub

Sub CPU_SH
	'I'm not confident with this one
	Dim As Integer addr = CShort(imm) + cpu.GPR(RS)
	Dim load As Byte
	For i As Integer = 0 To 1
		load = ((cpu.GPR(RT) Shr i*8) And &hFF)
		WriteByte(addr+i,load)
		Print #88, "ADDR: " & Hex(addr + i) & ":" & Hex(load)
		
	Next
	#Ifdef debug
	Print #88, "-----------------------------------------------"
	Print #88, "SH" & Hex(cpu.current_PC)
	Print #88, "Cycles: " & cpu.instructions
	Print #88, "-----------------------------------------------"
	#EndIf
End Sub
Sub CPU_SLL
	cpu.GPR(RD) = cpu.GPR(RT) Shl SA
	#Ifdef debug
	Print #99, Hex(cpu.GPR(RD)) & ":" & Hex(cpu.GPR(RT)) & ":" & Hex(SA)
	#EndIf
End Sub
Sub CPU_SLLV
	cpu.GPR(RD) = cpu.GPR(RT) Shl  (cpu.GPR(RS) And &h1F)
End Sub
Sub CPU_SLT
	Dim As Integer tRS = CInt(cpu.GPR(RS))
	Dim As Integer tRT = CInt(cpu.GPR(RT))
	If tRS < tRT Then cpu.GPR(RD) = 1 Else cpu.GPR(RD) = 0
End Sub
Sub CPU_SLTI
	Dim As Integer tImm = CShort(imm)
	Dim As Integer tRS = CInt(cpu.GPR(RS))
	If tRS < tImm Then cpu.GPR(RT) = 1 Else cpu.GPR(RT) = 0
End Sub
Sub CPU_SLTIU 'Might be correct without sign extension?
	If cpu.GPR(RS) < CShort(imm) Then cpu.GPR(RT) = 1 Else cpu.GPR(RT) = 0
End Sub
Sub CPU_SLTU
	Print #99, Hex(cpu.GPR(RS)) & ":" & Hex(cpu.GPR(RT))
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
	checkOverflow
End Sub
Sub CPU_SUBU
	cpu.GPR(RD) = cpu.GPR(RS) - cpu.GPR(RT)
End Sub

Sub CPU_SW
	'I'm not confident with this one
	Dim As UInteger addr = cpu.GPR(RS) + Cshort(imm)
	Dim As Byte test = addr And 1
	Dim load As Byte
	For i As Integer = 0 To 3
		load = ((cpu.GPR(RT) Shr i*8) And &hFF)
		WriteByte(addr+i,load)
		cpu.storeValue = load 
	Next
	#Ifdef debug
	Print #88, "-----------------------------------------------"
	Print #88, "Address: " & Hex(addr) & " = " & Hex(load)
	Print #88, "RT   " & RT & ": " & Hex(cpu.GPR(RT))
	Print #88, "SW   " & Hex(cpu.current_PC)
	Print #88, "Cycles: " & cpu.instructions
	Print #88, "-----------------------------------------------"
	#EndIf
End Sub

Sub CPU_SWC2
	#Ifdef debug
	Print #99, "Unimplemented Op"
	#EndIf
End Sub

Sub CPU_SWL
	#Ifdef debug
	Print #99, "Unimplemented Op"
	#EndIf
End Sub

Sub CPU_SWR
	#Ifdef debug
	Print #99, "Unimplemented Op"
	#EndIf
End Sub
Sub CPU_SYSCALL
	Dim As UInteger code = ((cpu.opcode Shr 6) And &hFFFFF)
	Exception(code,8,0)
End Sub
Sub CPU_XOR
	cpu.GPR(RD) = cpu.GPR(RS) Xor cpu.GPR(RT)
End Sub
Sub CPU_XORI
	cpu.GPR(RT)= cpu.GPR(RS) xor imm
End Sub
Sub decodeInstruction
	'If cpu.opcode <> 0 Then 
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
	Select Case (cpu.opcode Shr 25)
        Case &h21
            Dim As Uinteger temp = cpu.opcode
            temp = temp Shl 26
            temp = temp Shr 26
            If temp = &h10 Then 
                cpu.Operation = "RFE" 
                CPU_RFE 
            Else 
                cpu.Operation = "COP0"
                CPU_COP0
            EndIf
		Case &h25
			cpu.Operation = "COP2"
			CPU_COP2
	End Select
	Select Case (cpu.opcode Shr 26)
		Case &h0 'Special
			Select Case(cpu.opcode And &h3F)
				Case &h0
					cpu.operation = "SLL"
					CPU_SLL
				Case &h2
					cpu.operation = "SRL"
					CPU_SRL
				Case &h3
					cpu.operation = "SRA"
					CPU_SRA
				Case &h4
					cpu.operation = "SLLV"
					CPU_SLLV
				Case &h6
					cpu.operation = "SRLV"
					CPU_SRLV
				Case &h7
					cpu.operation = "SRAV"
					CPU_SRAV
				Case &hc
					cpu.operation = "SYSCALL"
					CPU_SYSCALL
				Case &h20
					cpu.Operation = "ADD"
					CPU_ADD
				Case &h21
					cpu.Operation = "ADDU"
					CPU_ADDU
				Case &h24
					cpu.Operation = "AND"
					CPU_AND
				Case &h0D
					cpu.Operation = "BREAK"
					CPU_BREAK
				Case &h1A
					cpu.Operation = "DIV"
					CPU_DIV
				Case &h1B
					cpu.Operation = "DIVU"
					CPU_DIVU
				Case &h09
					cpu.Operation = "JALR"
					CPU_JALR
				Case &h08
					cpu.Operation = "JR"
					CPU_JR
				Case &h10
					cpu.Operation = "MFHI"
					CPU_MFHI
				Case &h12
					cpu.Operation = "MFLO"
					CPU_MFLO
				Case &h11
					cpu.Operation = "MTHI"
					CPU_MTHI
				Case &h13
					cpu.Operation = "MTLO"
					CPU_MTLO
				Case &h18
					cpu.operation = "MULT"
					CPU_MULT
				Case &h19
					cpu.operation = "MULTU"
					CPU_MULTU
				Case &h22
					cpu.operation = "SUB"
					CPU_SUB
				Case &H23
					cpu.operation = "SUBU"
					CPU_SUBU
				Case &h25
					cpu.operation = "OR"
					CPU_OR
				Case &h26
					cpu.operation = "XOR"
					CPU_XOR
				Case &h27
					cpu.operation = "NOR"
					CPU_NOR
				Case &h2A
					cpu.operation = "SLT"
					CPU_SLT
				Case &h2B
					cpu.operation = "SLTU"
					CPU_SLTU
			End Select
		Case &h1 'REGIMM = 000001
			Select Case ((cpu.opcode Shr 16) And &H1F)
				Case &h0
					cpu.operation = "BLTZ"
					CPU_BLTZ
				Case &h1
					cpu.operation = "BGEZ"
					CPU_BGEZ
				Case &h10
					cpu.operation = "BLTZAL"
					CPU_BLTZAL
				Case &h11
					cpu.operation = "BGEZAL"
					CPU_BGEZAL
			End Select
		Case &h2
			cpu.operation = "J"
			CPU_J
		Case &h3
			cpu.operation = "JAL"
			CPU_JAL
		Case &h4
			cpu.operation = "BEQ"
			CPU_BEQ
		Case &h5
			cpu.operation = "BNE"
			CPU_BNE
		Case &h6
			cpu.operation = "BLEZ"
			CPU_BLEZ
		Case &h7
			cpu.operation = "BGTZ"
			CPU_BGTZ
		Case &h8
			cpu.operation = "ADDI"
			CPU_ADDI
		Case &h9
			cpu.operation = "ADDIU"
			CPU_ADDIU
		Case &hA
			cpu.operation = "SLTI"
			CPU_SLTI
		Case &HB
			cpu.operation = "SLTIU"
			CPU_SLTIU
		Case &hc
			cpu.operation = "ANDI"
			CPU_ANDI
		Case &hD
			cpu.Operation = "ORI"
			CPU_ORI
		Case &he
			cpu.operation = "XORI"
			CPU_XORI
		Case &hF
			cpu.operation  = "LUI"
			CPU_LUI
		Case &h20
			cpu.operation = "LB"
			CPU_LB
		Case &H21
			cpu.operation = "LH"
			CPU_LH
		Case &h22
			cpu.operation = "LWL"
			CPU_LWL
		Case &h23
			cpu.operation = "LW"
			CPU_LW
		Case &h24
			cpu.operation = "LBU"
			CPU_LBU
		Case &h25
			cpu.operation = "LHU"
			CPU_LHU
		Case &h26
			cpu.operation = "LWR"
			CPU_LWR
		Case &h28
			cpu.operation = "SB"
			CPU_SB
		Case &h2B
			cpu.operation = "SW"
			CPU_SW
		Case &h29
			cpu.operation = "SH"
			CPU_SH
		Case &h2A
			cpu.operation = "SWL"
			CPU_SWL
		Case &h2e
			cpu.operation = "SWR"
			CPU_SWR
		Case &h32
			cpu.operation = "LWC2"
			CPU_LWC2
		Case &h3A
			cpu.operation = "SWC2"
			CPU_SWC2
		
	End Select
End Sub



