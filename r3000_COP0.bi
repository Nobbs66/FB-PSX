'The PSX lacks a TLB and just mirrors addresses
Type cop0s
	reg(0 To &h31) As UInteger 
End Type
Dim Shared cop0 As cop0s
#Define BPC 		(cop0.reg(3)) 	'Breakpoint on executed 
#Define BDA 		(cop0.reg(5)) 	'Breakpoint on data access
#Define JUMPDEST 	(cop0.reg(6)) 	'Randomly memorised jump address
#Define DCIC 		(cop0.reg(7)) 	'Breakpoint Control
#Define BadVaddr 	(cop0.reg(8)) 	'Bad virtual address
#Define BDAM 		(cop0.reg(9)) 	'Data access breakpoint mask
#Define BPCM 		(cop0.reg(11)) 'Execute breakpoint mask
#Define SR 			(cop0.reg(12)) 'Status register
#Define CAUSE 		(cop0.reg(13)) 'Exception Cause
#Define EPC 		(cop0.reg(14)) 'Exception program counter
#Define PRID 		(cop0.reg(15)) 'Processor ID
Declare Function Exception(ByVal syscall As UInteger, ByVal eType As UByte) As UInteger
Function Exception(ByVal syscall As UInteger, ByVal eType As UByte) As UInteger
	Select Case eType
		Case 0 To 1 'Not used
		Case 2 To 6 
	End Select
	Return 0
End Function
