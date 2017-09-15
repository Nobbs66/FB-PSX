Dim Shared As UInteger dma_Control = &h7654321 
Dim Shared As UInteger dma_Interrupt
Dim Shared As UInteger dbase
Dim Shared As UInteger block
Dim Shared As UInteger channel
Dim Shared As UByte dmaEnd
#Define mAddr			((dbase Shr 0) And &hFFFFFF)
#Define size			((block Shr 0) And &hFFFF)
#Define blocks			((block Shr 16) And &hFFFF)
#Define direction		((channel Shr 0) And 1) 
#Define mStep			((channel Shr 1) And 1)
#Define sync			((channel Shr 9) And 3)
#Define start			((channel Shr 24) And 1)


Declare Function checkTrigger(ByVal ch As UByte)As UByte
Declare Function startDMA(ByVal ch As UByte)As UByte
Declare Function read32(ByVal addr As UInteger) As Uinteger
Declare Function write32(ByVal addr As UInteger, value As UInteger) As UByte
Declare Function write8(ByVal addr As UInteger, value As UByte) As UByte
Declare Function read8(ByVal addr As UInteger) As UByte
Declare Sub blockDMA
Declare Sub chopDMA
Declare Sub linkDMA
Declare Sub linkedDMA

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
Function write8(ByVal addr As UInteger, value As UByte) As UByte
	'Memory is split into a few different regions
	Select Case addr
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h0 To &h7FFFFF 'KUSEG
			cpu.memory(addr And &h1FFFFF) = value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		Case &h80000000 To &h807FFFFF 'KSEG0
		 	cpu.memory(addr And &h1FFFFF) = value
		 	Print #88, "Writing KSEG 0"
''''''''''''''''''''''''''''''''''''''''''''''''''''''''		 	
		Case &hA0000000 To &hA07FFFFF 'KSEG1
			cpu.memory(addr And &h1FFFFF) = value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''			
	End select
	return 0 
End Function
Function write32(ByVal addr As UInteger, value As UInteger) As UByte
	Dim load As Byte
	For i As Integer = 0 To 3
		load = ((value Shr i*8) And &hFF)
		write8(addr+i,load)
	Next
Return 0
End Function
Function read32(ByVal addr As UInteger) As UInteger
	Dim As UInteger temp
	For i As Integer = 0 To 3 
		temp or= (read8(addr+(3-i)) Shl (24-(i*8)))
	Next
	Return temp 
End Function
Function read8(ByVal addr As UInteger) As UByte
	Dim As UByte temp = cpu.memory(addr And &h1FFFFF)
	Return temp
End Function
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
	
	Select Case sync
		Case 0
			Print #99, "Block DMA"
			blockDMA
		Case 1
			Print #99, "ChopDMA"
			chopDMA
		Case 2
			Print #99, "Linked List DMA"
			linkDMA
	End Select
	
Return 0
End Function
Function checkTrigger(ByVal ch As UByte)As UByte
	Dim stat As UByte
	Select Case ch
		Case 0
			channel = DMA0.channel_control
			Print #99, "Triggered: " & Hex(start)
			If start = 1 Then startDMA(0)
			DMA0.channel_control -= &h11000000 
		Case 1
			channel = DMA1.channel_control
			Print #99, "Triggered: " & Hex(start)
			If start = 1 Then startDMA(1)
			DMA1.channel_control -= &h11000000
			
		Case 2
			channel = DMA2.channel_control
			Print #99, "Trigger Bit: " & Hex(start)
			Print #99, "Start ADDR: " & Hex(DMA2.base_address)
			If start = 1 Then startDMA(2)
			DMA2.channel_control = BitReset(DMA2.channel_control,24)
		Case 3
			channel = DMA3.channel_control
			Print #99, "Triggered: " & Hex(start)
			If start = 1 Then startDMA(3)
			If dmaEnd <> 0 Then DMA3.channel_control -= &h11000000
			dmaEnd = 0
		Case 4
			channel = DMA4.channel_control
			Print #99, "Triggered: " & Hex(start)
			If start = 1 Then startDMA(4)
			If dmaEnd <> 0 Then DMA4.channel_control -= &h11000000
			dmaEnd = 0
		Case 5
			channel = DMA5.channel_control
			Print #99, "Triggered: " & Hex(start)
			If start = 1 Then startDMA(5)
			If dmaEnd <> 0 Then DMA5.channel_control -= &h11000000
			dmaEnd = 0	
		Case 6
			channel = DMA6.channel_control
			Print #99, "Triggered: " & Hex(start)
			Print #99, "DMA STAT: " & Hex(DMA6.channel_control)
			If start = 1 Then startDMA(6)
			If dmaEnd <> 0 Then DMA6.channel_control -= &h11000000
			dmaEnd = 0
	End Select
Return 0
End Function
Sub blockDMA
	Dim As UInteger mEnd = mAddr - ((size*4)-8)
	If size <> 0 Then 'Protect from underflow. 
		For i As Integer = mAddr To mEnd Step -4
			write32(i,i-4)
			
			Print #88, "Addres: " & Hex(i) & " : " & Hex(cpu.memory(i And &h1FFFFF))
		Next
		write32(mEnd-4,&hFFFFFFFF)
		Print #88, "Addres: " & Hex(mEnd-4) & " : " & Hex(cpu.memory((mEnd -4) And &h1FFFFF))
		dmaEnd = 1 
	endif
End Sub
Sub chopDMA
	
End Sub
'Sub linkDMA
'	Dim As UInteger addr = mAddr
'	Dim As UInteger header = mAddr And &hFFFFFF
'	Dim As UByte MSB = read32(addr)
'	MSB = ((MSB Shr 24) And &hFF)
'	If header <> &hFFFFFF Then 
'	Do 
'		Cls 
'		Print "MSB " & Hex(MSB)
'		sleep
'		If MSB <> 0 Then 
'			Print "Entries: " & Hex(MSB)
'				For i As Integer = 1 To MSB
'					gpu.command_Buffer(i-1) = read32(addr + (4*i))
'					Print #99, Hex(gpu.command_Buffer(i-1))
'				Next
'			gpuCommand(0)
'		EndIf
'		addr = read32(addr And &h1FFFFF)
'		MSB = read32(addr)
'		header = addr And &hFFFFFF
'		MSB = ((MSB Shr 24) And &hFF)
'	Loop While header <> &hFFFFFF
'	EndIf 
'	Print "DMA Done" 
'End Sub
sub linkDMA

dim as uinteger addr = mAddr
dim as uinteger header = (read32(addr and &h1FFFFF) And &hFFFFFF)
dim as uinteger MSB = ((read32(addr) shr 24) and &hFF)

if header <> &hFFFFFF then 
Print #99, Hex(header)
	Do
		if MSB <> 0 then 
			for i as integer = 1 to MSB
				gpu.command_Buffer(i-1) = read32(addr + (4*i))
				print #99, "Command: " & hex(gpu.command_Buffer(i-1))
			next
			gpuCommand(0)
		endif
	addr = read32(addr and &h1FFFFF)
	header = (read32(addr and &h1FFFFF) And &hFFFFFF)
	MSB = ((read32(addr) Shr 24) and &hFF)
	loop while header <> &hFFFFFF
	'Cls 
	'Print "Code: " & Hex(header)
	'sleep
endif
print #99, "DMA Complete"

end Sub



