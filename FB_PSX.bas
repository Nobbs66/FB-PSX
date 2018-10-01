#Include Once "fbgfx.bi"
Using fb
ScreenRes (640, 480, 32)

Type cpus
    memory(&h200000) As UByte
    iCache(&hFFF) As ubyte
    dCache(&h400) As UByte
    expansion(&h800000) As UByte
    GPR(32) As UInteger
    dGPR(32) As UInteger 'Load Delay GPR set
    fGPR(32) As Ubyte 'Load Delay flags
    cpu_Clock As UInteger = 44100 * &h300 '33.8688mhz
    current_PC As UInteger
    cpu_Cycles As UInteger
    cpu_clocks As UInteger
    delayReg As UByte
    delayValue As UInteger
    delayFlag As UByte
    delay_slot_PC As UInteger 
    branch_queued As UByte
    HI As UInteger
    breakPoint As UByte
    LO As UInteger
    bios(&h80000) As UByte
    opcode As UInteger
    Operation As String
    memSize As UByte
    delayLatch As UByte
    storeAddress As UByte
    storedAddress As UInteger
    storeValue As UInteger
    ophistory(0 To &hFF) As String 
    const Reset_Vector As UInteger = &hBFC00000
    bootStatus As UByte
    instructions As Uinteger 
    logs As UByte
    tpc As UShort
    fCounter As Double
End Type
Dim Shared cpu As cpus

#Include Once "file.bi"
#Include Once "gpu.bi"
Declare Sub setIntc(ByVal irq As UByte)
#Include "dma.bi"
#Include Once "r3000_Core.bi"
#Include Once "r3000_cop0.bi"
#Include Once "gte.bi"
#Include Once "r3000_opcodes.bi"
Declare Sub CAE
#Include Once "debugger.bi"
Declare Sub runCPU
Sub runCPU
If cpu.branch_queued = 1 Then
    cpu.current_PC = cpu.delay_slot_PC
    cpu.branch_queued -= 1
Else 
    If cpu.branch_queued = 2 Then cpu.branch_queued -=1 
EndIf
checkInterrupts()
fetchInstruction()
decodeInstruction()
cop0.reg(12) And= Not(&h800)
cpu.current_PC += 4
cpu.cpu_Cycles += 1
cpu.cpu_clocks += cpu.cpu_Cycles
cpu.GPR(0) = 0 'Keep Zero Register clean. 
End Sub

Sub runGPU
    gpu.vb_counter = cpu.cpu_Cycles * (11/7)
    If gpu.vb_counter = 897619 Then 
        port.iStat Or= 1
        gpu.vb_counter = 0 
        cpu.cpu_Cycles = 0
    EndIf
End Sub
Sub CAE 'Cleanup and Exit
    dumpRegisters()
    dumpMemory()
    CLS()
    Print("Closing")
    close
    Sleep(1000, 1)
    end
End Sub

''''''''''''Initialize Emu'''''''''''''
'''''''''''''''''''''''''''''''''''''''
loadBIOS()
initCPU()
'Wait for start input. 
Do
    screenLock()
    cls()
    Print("Press S to start")
    screenUnlock()
    Sleep(10, 1)
Loop While Not MultiKey(SC_S)
Cls()

'Main loop
Do
    runCPU()
    runGPU()
    cpu.instructions += 1
    gpu.GPUSTAT Or= &hC000000
    'If cd.logging = 1 Then 
    '   writeLog
    'EndIf
Loop While Not MultiKey(SC_ESCAPE)

