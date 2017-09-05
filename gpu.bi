Type gpu
	hRes As UInteger
	vRes As UInteger
	vram (0 To &hFFFFF) As UByte 
	command_Buffer 0 To 11 As UInteger 
End Type
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


Declare Sub gpuCommand
'Primitive Drawing commands
Declare Sub monoTri
Declare Sub textTri 
Declare Sub monoQuad
Declare Sub textQuad
Declare Sub gradTri
Declare Sub gradTexTri
Declare Sub gradQuad
Declare Sub graTexQuad
Declare Sub monoLine
Declare Sub monPolyLine
Declare Sub gradLine
Declare Sub graPolyLine
Declare Sub rectangle
Declare Sub sprite
Declare Sub dot
Declare Sub tileRect
Declare Sub tileSprite
Declare Sub dTileRect
Declare Sub dTileSprite
Sub gpuCommand
	Select Case command_Buffer(0)
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
			gmonPolyLine
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
	End Select
End Sub

Sub monoTri
End Sub
