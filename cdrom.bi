Type cdrom
	Status As UByte = &h19
	comRegister As UInteger
	param As UByte
	request As UInteger
	dataFifo As UInteger
	response(0 To &hF) As UByte 
	commandReg As UByte
	irqEnable As UByte
	irqFlag As UByte
	cheat As UByte
	logging As UByte
	testing As UByte
	logReg As UByte
End Type
Dim Shared cd As cdrom
Declare Sub checkCDInterrupt
Declare Sub CdWrite(ByVal addr As Ushort, ByVal value As UByte)
Declare Sub cdTEST
Declare Sub cdCommand
#Define index (cd.Status And 3)
Sub checkCDInterrupt
	
End Sub
Sub cdWrite(ByVal addr As UShort, ByVal value As UByte)'	cd.cdac = 1
	Select Case (addr And 3)
		Case 0
			cd.Status And= Not(3)
			cd.Status Or= (value And &h3)
		Case 1
			Select Case index
				Case 0
					cd.comRegister = value
					cdCommand
				Case 1
					Print "Sound Map Data Out???"
				Case 2
					Print "Unknown CD write" & Hex(addr) & " " & index
				Case 3
					Print "Unknown CD write" & Hex(addr) & " " & index
			End Select
		Case 2
			Select Case index
				Case 0
					cd.param = value
					cd.Status And= Not((1 Shl 3))
				Case 1
					cd.irqEnable = 1
			End Select
		Case 3
			Select Case index
				Case 0
					Print "Unknown CD write"
				Case 1 
					cd.irqFlag = value
				Case 2
					Print "Unknown CD write" & Hex(addr) & " " & index
				Case 3
					Print "Unknown CD write" & Hex(addr) & " " & index
			End Select
	End Select
End Sub
Function cdRead(ByVal addr As UShort) As UByte
	Dim As UByte value
	Select Case (addr And 3)
		Case 0
			value = cd.Status
		Case 1
			Print "Reading Response FIFO"
		Case 2
			Print "Reading CD Reg 1802h. " & index
		Case 3
			Select Case index
				Case 1
					value = cd.irqFlag
				Case Else
					Print "Reading CD Reg 1803h. " & index
			End Select
	End Select
	Return value
End Function
Sub cdCommand
	Select Case (cd.comRegister)
		Case &h19
			cdTEST
			requestIRQ(2)
		Case Else
			Print "Unhandled CD ROM Command"
	End Select
End Sub


Sub cdTEST
	Dim As UByte com = cd.param
	Select Case (com)
		Case &h20
			cd.response(3) = &h97
			cd.response(2) = &h01
			cd.response(1) = &h10
			cd.response(0) = &hc2
			cd.Status Or= (1 Shl 5)
			cd.irqFlag Or= 3
			cd.logging = 1
		Case Else
			Print "Unknown CD Command"
	End Select
End Sub
