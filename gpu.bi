Type gpus
	hRes As UInteger
	vRes As UInteger
	vram (0 To &hFFFFF) As UByte 
	GPUSTAT As UInteger = &h1c000000
	command_Count As UByte
	command_Flag As UByte
	command_Buffer(0 To 15) As UInteger 
	command_Pointer As UInteger
End Type
Dim Shared gpu As gpus
#Define R 	(gpu.command_Buffer(0) And &hFF)
#Define G 	(gpu.command_Buffer(0) Shr 8) And &hFF
#Define B 	(gpu.command_Buffer(0) Shr 16) And &hFF

#Define x0 	(gpu.command_Buffer(1) And &hFFFF)
#Define y0 	((gpu.command_Buffer(1) Shr 16) And &hFFFF)

#Define x1 	(gpu.command_Buffer(2) And &hFFFF)
#Define y1 	((gpu.command_Buffer(2) Shr 16) And &hFFFF)

#Define x2 	(gpu.command_Buffer(3) And &hFFFF)
#Define y2 	((gpu.command_Buffer(3) Shr 16) And &hFFFF)

#Define x3	(gpu.command_Buffer(4) And &hFFFF)
#Define y3	((gpu.command_Buffer(4) Shr 16) And &hFFFF)


Declare Function gpuCommand(ByVal port As UShort)As UByte
Declare Function gp1Command(ByVal Data As UInteger) As UByte 'GP1
'Primitive Drawing commands
Declare Sub monoTri
Declare Sub textTri 
Declare Sub monoQuad
Declare Sub textQuad
Declare Sub gradTri
Declare Sub gradTexTri
Declare Sub gradQuad
Declare Sub gradTexQuad
Declare Sub monoLine
Declare Sub monPolyLine
Declare Sub gradLine
Declare Sub gradPolyLine
Declare Sub rectangle
Declare Sub sprite
Declare Sub dot
Declare Sub tileRect
Declare Sub tileSprite
Declare Sub dTileRect
Declare Sub dTileSprite
Function gp1Command(ByVal dat As UInteger) As UByte 'GP1
	Print #99, "GP1 Command Recieved: " & Hex(dat Shr 24)
	Select Case ((dat Shr 24)And &hFF)
		Case 0'Reset GPU
		'	gpu.GPUSTAT = &h14802000
		Case 1 'Reset Command Buffer
			For i As Integer = 0 To &hF
				gpu.command_Buffer(i) = 0 
			Next
		Case 2 'Acknowledge GPU Interrupt
			gpu.GPUSTAT -= &h1000000
		Case 3
			gpu.GPUSTAT Or= &h800000
		Case 4
			Dim As UInteger temp = ((dat And &h3)Shl 29)
			gpu.GPUSTAT Or= temp
		Case 5 'Start of Display
			
		Case 6 'Horizontal Display range
		
		Case 7 'Vertical display Range
			
		Case 8 'Display Mode
			Print #99, "GPUSTAT: " & Hex(gpu.GPUSTAT)
			gpu.GPUSTAT -= &h7F4000 'Clear bits 14, 16-22
			gpu.GPUSTAT Or= ((dat And &h3F) Shl 17) 'Set Bits 17-22
			gpu.GPUSTAT Or= ((dat And &h40) Shl 10) 'Set Bit 16
			gpu.GPUSTAT Or= ((dat And &h80) Shl 7)  'Set Bit 14
			Print #99, "GPUSTAT: " & Hex(gpu.GPUSTAT)
	End Select
	Return 0
End Function
Function gpuCommand(ByVal port As Ushort)As ubyte 'GP0
	Cls 
	Print "Buffer entry: " & Hex(gpu.command_Buffer(0))
	Dim As UInteger entry = ((gpu.command_Buffer(0) Shr 24) And &hFF)
	sleep
	Select Case entry
		
		Case &h00
			'NOP
		Case &h01
			'Clear Cache
		Case &h02
			'Rill Rect VRAM
		Case &h1F
			'IRQ1
		Case &h20
			monoTri
		Case &h24
			textTri
		Case &h28
			monoQuad
		Case &h2C
			textQuad
		Case &h30
			gradTri
		Case &h34
			gradTexTri
		Case &h38
			gradQuad
		Case &h3C
			gradTexQuad
		Case &h40
			monoLine
		Case &h48
			monPolyLine
		Case &h50
			gradLine
		Case &h58
			gradPolyLine
		Case &h60
			rectangle
		Case &h64
			sprite
		Case &h68
			dot
		Case &h70
			tileRect
		Case &h74
			tileSprite
		Case &h78
			dTileRect
		Case &h7C
			dTileSprite
		Case &h80
			'Copy Rect V-V
		Case &hA0
			'Copy Rect C-V
		Case &hC0
			'Copy Rect V-C
	End Select
	Return 0
End Function

Sub monoTri
	If gpu.command_Count = 3 Then 
		'Draw
	Else 
		gpu.command_Count += 1
	EndIf
End Sub
Sub textTri 
	If gpu.command_Count = 4 Then 
		'Draw
	Else 
		gpu.command_Count += 1
	EndIf
End Sub
Sub monoQuad
	Cls
	Print "Drawing Quad"
	Print "Color: " & Hex(R) & ":" & Hex(G) & ":" & Hex(B)
	Print "XY0: " & Hex(x0) & ":" & Hex(y0) & "      " & Hex(gpu.command_Buffer(1)) 
	Print "XY0: " & Hex(x1) & ":" & Hex(y1) & "      " & Hex(gpu.command_Buffer(2)) 
	Print "XY0: " & Hex(x2) & ":" & Hex(y2) & "      " & Hex(gpu.command_Buffer(3))
	Print "XY0: " & Hex(x3) & ":" & Hex(y3) & "      " & Hex(gpu.command_Buffer(4)) 
	Sleep
	Cls
	sleep
	line(x0, y0)-(x1,y1), RGB(255,255,255)
	sleep
	line(x2, y2)-(x3,y3), RGB(255,255,255)
	Sleep
	line(x0, y0)-(x2,y2), RGB(255,255,255)
	Sleep
	line(x1, y1)-(x3,y3), RGB(255,255,255)
	Paint(x3/2, y3/2), RGB(255,255,255),RGB(255,255,255)
	Sleep
	
End Sub
Sub textQuad
	If gpu.command_Count = 8 Then 
		'Draw
	Else 
		gpu.command_Count += 1
	EndIf
End Sub
Sub gradTri
	If gpu.command_Count = 5 Then 
		'Draw
	Else 
		gpu.command_Count += 1
	EndIf
End Sub
Sub gradTexTri
	If gpu.command_Count = 5 Then 
		'Draw
	Else 
		gpu.command_Count += 1
	EndIf
End Sub
Sub gradQuad
	If gpu.command_Count = 8 Then 
		'Draw
	Else 
		gpu.command_Count += 1
	EndIf
End Sub
Sub gradTexQuad
	If gpu.command_Count = 7 Then 
		'Draw
	Else 
		gpu.command_Count += 1
	EndIf
End Sub
Sub monoLine
	
End Sub
Sub monPolyLine
	
End Sub
Sub gradLine
	
End Sub
Sub gradPolyLine
	
End Sub
Sub rectangle
	
End Sub
Sub sprite
	
End Sub
Sub dot
	
End Sub
Sub tileRect
	
End Sub
Sub tileSprite
	
End Sub
Sub dTileRect
	
End Sub
Sub dTileSprite
	
End Sub
