Dim Shared As UInteger dma_Control = &h7654321 
Dim Shared As UInteger dma_Interrupt
Dim Shared As UInteger dbase
Dim Shared As UInteger block
Dim Shared As UInteger channel

#Define bAddr			((dbase Shr 0) And &hFFFFFF)
#Define size			((block Shr 0) And &hFFFF)
#Define blocks			((block Shr 16) And &hFFFF)
#Define direction		((channel Shr 0) And 1) 
#Define mStep			((channel Shr 1) And 1)
#Define sync			((channel Shr 9) And 2)

Declare Function checkTrigger(ByVal ch As UByte)As UByte
Declare Function startDMA(ByVal ch As UByte)As UByte

Type DMAs0
	base_address As UInteger
	block_control As UInteger
	channel_control As UInteger
End Type
Type DMAs1
	base_address As UInteger
	block_control As UInteger
	channel_control As UInteger
End Type
Type DMAs2
	base_address As UInteger
	block_control As UInteger
	channel_control As UInteger
End Type
Type DMAs3
	base_address As UInteger
	block_control As UInteger
	channel_control As UInteger
End Type
Type DMAs4
	base_address As UInteger
	block_control As UInteger
	channel_control As UInteger
End Type
Type DMAs5
	base_address As UInteger
	block_control As UInteger
	channel_control As UInteger
End Type
Type DMAs6
	base_address As UInteger
	block_control As UInteger
	channel_control As UInteger
End Type

Dim Shared DMA0 As DMAs0
Dim Shared DMA1 As DMAs1
Dim Shared DMA2 As DMAs2
Dim Shared DMA3 As DMAs3
Dim Shared DMA4 As DMAs4
Dim Shared DMA5 As DMAs5
Dim Shared DMA6 As DMAs6

Function startDMA(ByVal ch As UByte)As UByte
	Select Case ch
		Case 0
			Print #99, "DMA0 START"
			dBase = DMA0.base_address
			block = DMA0.block_control
			channel = DMA0.channel_control
			
		Case 1
			Print #99, "DMA1 START"
			dBase = DMA1.base_address
			block = DMA1.block_control
			channel = DMA1.channel_control
		Case 2
			Print #99, "DMA2 START"
			dBase = DMA2.base_address
			block = DMA2.block_control
			channel = DMA2.channel_control
		Case 3
			Print #99, "DMA3 START"
			dBase = DMA3.base_address
			block = DMA3.block_control
			channel = DMA3.channel_control
		Case 4
			Print #99, "DMA4 START"
			dBase = DMA4.base_address
			block = DMA4.block_control
			channel = DMA4.channel_control
		Case 5
			Print #99, "DMA5 START"
			dBase = DMA5.base_address
			block = DMA5.block_control
			channel = DMA5.channel_control
		Case 6
			Print #99, "DMA6 START"
			dBase = DMA6.base_address
			block = DMA6.block_control
			channel = DMA6.channel_control
	End Select
Return 0
End Function

Function checkTrigger(ByVal ch As UByte)As UByte
	Dim stat As UByte
	Select Case ch
		Case 0
			Dim As uinteger temp = ((DMA0.block_control And &h100000)Shr 24)
			If temp = 1 Then startDMA(0)
		Case 1
			Dim As uinteger temp = ((DMA1.block_control And &h100000)Shr 24)
			If temp = 1 Then startDMA(1)
		Case 2
			Dim As uinteger temp = ((DMA2.block_control And &h100000)Shr 24)
			If temp = 1 Then startDMA(2)
		Case 3
			Dim As uinteger temp = ((DMA3.block_control And &h100000)Shr 24)
			If temp = 1 Then startDMA(3)
		Case 4
			Dim As uinteger temp = ((DMA4.block_control And &h100000)Shr 24)
			If temp = 1 Then startDMA(4)
		Case 5
			Dim As uinteger temp = ((DMA5.block_control And &h100000)Shr 24)
			If temp = 1 Then startDMA(5)	
		Case 6
			Dim As uinteger temp = ((DMA6.block_control And &h100000)Shr 24)
			If temp = 1 Then startDMA(6)
	End Select
	Return stat
End Function
