Type gtes
	gd(0 To 31) As UInteger 'GTE Data Register 0 - 31
	gc(0 To 31) As UInteger 'GTE Control Register 0 - 31
End Type
Dim Shared gte As gtes
'Control Registers
#Define R11 ((gte.gc(0)) And &hFFFF)
#Define R12 (((gte.gc(0) Shr 16) And &hFFFF)
#Define R13 ((gte.gc(1) And &hFFFF)
#Define R21 (((gte.gc(1) Shr 16) And &hFFFF)
#Define R22 ((gte.gc(2) And &hFFFF)
#Define R23 (((gte.gc(2) Shr 16) And &hFFFF)
#Define R31 ((gte.gc(3) And &hFFFF)
#Define R32 (((gte.gc(3) Shr 16) And &hFFFF)
#Define R33 (gte.gc(4))
#Define TRX 	(gte.gc(5)) 	'Translation Vector X
#Define TRY		(gte.gc(6)) 	'Translation Vector Y
#Define TRZ		(gte.gc(7)) 	'Translation Vector Z
#Define L11 ((gte.gc(8)) And &hFFFF)
#Define L12 (((gte.gc(8) Shr 16) And &hFFFF)
#Define L13 ((gte.gc(9) And &hFFFF)
#Define L21 (((gte.gc(9) Shr 16) And &hFFFF)
#Define L22 ((gte.gc(10) And &hFFFF)
#Define L23 (((gte.gc(10) Shr 16) And &hFFFF)
#Define L31 ((gte.gc(11) And &hFFFF)
#Define L32 (((gte.gc(11) Shr 16) And &hFFFF)
#Define L33 (gte.gc(12))
#Define RBK		(gte.gc(13))	'Background color red component
#Define GBK		(gte.gc(14)) 	'Background color green component
#Define BBK		(gte.gc(15))	'Background color blue component
#Define LR1 ((gte.gc(16)) And &hFFFF)
#Define LR2 (((gte.gc(16) Shr 16) And &hFFFF)
#Define LR3 ((gte.gc(17) And &hFFFF)
#Define LG1 (((gte.gc(17) Shr 16) And &hFFFF)
#Define LG2 ((gte.gc(18) And &hFFFF)
#Define LG3 (((gte.gc(18) Shr 16) And &hFFFF)
#Define LB1 ((gte.gc(19) And &hFFFF)
#Define LB2 (((gte.gc(19) Shr 16) And &hFFFF)
#Define LB3 (gte.gc(20))
#Define RFC		(gte.gc(21))	'Far color red component
#Define GFC		(gte.gc(22))	'Far color green component
#Define BFC		(gte.gc(23))	'Far color blue component
#Define OFX		(gte.gc(24))	'Screen offset X
#Define OFY		(gte.gc(25))	'Screen offset Y
#Define H		(gte.gc(26))	'Projection plane distance
#Define DQA		(gte.gc(27))	'Depth queing parameter A. (coefficient)
#Define DQB		(gte.gc(28))	'Depth queing parameter B. (offset)
#Define ZSF3	(gte.gc(29))	'Z3 average scale factor (normally 1/3)
#Define ZSF4	(gte.gc(30))	'Z4 average scale factor (normally 1/4)
#Define FLAG	(gte.gc(31))	'Return calculation errors

'Data Registers
#Define VXY0	(gte.gd(0))		'Vector 0 X and Y. 1,3,12, or 1,15,0
#Define VZ0		(gte.gd(1))		'Vector 0 Z
#Define VXY1	(gte.gd(2))		'Vector 1 X and Y. 1,3,12, or 1,15,0 
#Define VZ1		(gte.gd(3))		'Vector 1 Z
#Define VXY2	(gte.gd(4))		'Vector 2 X and Y. 1,3,12, or 1,15,0
#Define VZ2		(gte.gd(5))		'Vector 2 Z
#Define rRGB	(gte.gd(6)) 	'RGB Value
#Define OTZ		(gte.gd(7))		'Z Average Value
#Define IR0		(gte.gd(8))		'intermediate value 0. *1
#Define IR1		(gte.gd(9))		'intermediate value 1. *1
#Define IR2		(gte.gd(10))	'intermediate value 2. *1
#Define IR3		(gte.gd(11))	'intermediate value 3. *1
#Define SXY0	(gte.gd(12))	'Screen XY coordinate FIFO *2
#Define SXY1	(gte.gd(13))	
#Define SXY2	(gte.gd(14))
#Define SXYP	(gte.gd(15))
#Define SZ0		(gte.gd(16))	'Screen Z FIFO	*2
#Define SZ1		(gte.gd(17))
#Define SZ2		(gte.gd(18))
#Define SZ3		(gte.gd(19))
#Define RGB0	(gte.gd(20))	'Characteristic color FIFO *2
#Define RGB1	(gte.gd(21))	
#Define RGB2	(gte.gd(22))	'CD2: bit pattern of current execution
#Define RES1	(gte.gd(23)) 	'Prohibited
#Define MAC0	(gte.gd(24))	'Sum of products value 0
#Define MAC1	(gte.gd(25))	'Sum of products value 1
#Define MAC2	(gte.gd(26))	'Sum of products value 2
#Define MAC3	(gte.gd(27))	'Sum of products value 3
#Define IRGB	(gte.gd(28))	'*3
#Define ORGB	(gte.gd(29))	'*4
#Define LZCS	(gte.gd(30))	'Leading zero count source data *5
#Define LZCR	(gte.gd(31))	'Leading zero count result *5

Declare Sub RTPS 'Perspective Transform
Declare Sub NCLIP
Declare Sub GTE_Opcode(op As UByte)

Sub RTPS
	Print "[GTE] RTPS"
End Sub

Sub NCLIP
	Print "[GTE] NCLIP"
End Sub

Sub GTE_Opcode(op As UByte)
	Select Case op
		Case &h01
			RTPS
		Case &h06
			NCLIP
		Case Else
			Print "Unknown GTE Opcode"
	End Select
End Sub
