Type gpus
	hRes As UInteger
	vRes As UInteger
	vram (0 To &hFFFFF) As UByte 
	GPUSTAT As UInteger = &h10000000
	command_Count As UByte
	command_Flag As UByte
	command_Buffer(0 To 11) As UInteger 
End Type
Dim Shared gpu As gpus
#Define R 	(gpu.command_Buffer(0) And &hFF)
#Define G 	(cpu.command_Buffer(0) Shr 8) And &hFF
#Define B 	(gpu.command_Buffer(0) Shr 16) And &hFF
#Define x1 	CShort(gpu.command_Buffer(1) And &h7FF)
#Define y1 	CShort((gpu.command_Buffer(1) Shr 16) And &h7FF)
#Define x2 	CShort(gpu.command_Buffer(2) And &h7FF)
#Define y2 	CShort((gpu.command_Buffer(2) Shr 16) And &h7FF)
#Define x3 	CShort(gpu.command_Buffer(3) And &h7FF)
#Define y3 	CShort((gpu.command_Buffer(3) Shr 16) And &h7FF)
#Define x4	CShort(gpu.command_Buffer(4) And &h7FF)
#Define y4	CShort((gpu.command_Buffer(5) Shr 16) And &h7FF)


Declare Function gpuCommand(ByVal port As UShort)As ubyte
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
Function gpuCommand(ByVal port As Ushort)As ubyte 'GP0
	If port = &h1810 Then 
	Select Case gpu.command_Buffer(0)
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
	ElseIf port = &h1814 Then 
	EndIf
	
For i As Integer = 0 To 11 'Clear buffer after drawing
	gpu.command_Buffer(i) = 0 
Next

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
	If gpu.command_Count = 4 Then 
		'Draw
	Else 
		gpu.command_Count += 1
	EndIf
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
