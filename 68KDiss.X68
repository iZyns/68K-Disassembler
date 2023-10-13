*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Team BLUE - Aditya Pillai, Vincent Wirawan, Kevin Lee, Nishant Narayana
* Date       : 
* Description: A program to convert machine-language instructions set in memory within a 68K arch to human-readable assembly code.
*-----------------------------------------------------------


    ORG    $1000

START    
 LEA    INPUTSTART,A1
        MOVE.B #14,D0
        TRAP   #15
        MOVEA.L #0,A1
        MOVE.B  #2,D0           ; trap code for reading input from console and store it into A1 
        TRAP    #15 
    
        CMP.B   BADLENGTH,D1
        BEQ     BADINPUT 
        MOVE.B  #8,D2          ;assuming the input length is 8 chars   
        MOVE.B  #00000000,D5
        BRA     CONV
    
CONV    CMP.B   #0,D2      
        BEQ     TRFDATA 
        LSL.L   #4,D5
        MOVE.B  (A1)+,D4   
        SUB.B   #1,D2          
        CMP.B   #'9',D4    
        BLE     CONVNUM    
        BGT     CONVLET    
    
CONVNUM SUB.B   #'0',D4  
        ADD.L   D4,D5     
        BRA     CONV       
    
CONVLET SUB.B   #7,D4      
        ADD.L   D4,D5  
        BRA     CONV  
    
TRFDATA CMP.B     #0,D7
        BEQ     TRFSTART
        BNE     TRFEND
        
TRFSTART MOVE.L  D5,A5  ;A5 holds the starting addr
         ADDI.B  #1,D7
         MOVEA.L #0,A4
         CLR     D2
         CLR     D4
         MOVE.L  #0,D5
         BRA     GETENDING 

TRFEND  MOVEA.L D5,A6   ;A6 holds the ending addr
        MOVE.B  #0,D7   ;clear out D7
        MOVEA.L #0,A4   ;clear out A4
        CLR     D2
        CLR     D4
        MOVE.L  #0,D5
        BRA     TESTSTART   
    
*****GETTING ENDING ADDRESS*****
GETENDING    MOVE.B  #0,D1   ;clear out D1
             LEA     INPUTEND,A1
             MOVE.B  #14,D0
             TRAP    #15
             MOVE.B  #2,D0           ; trap code for reading input from console and store it into A1 
             TRAP    #15
             
             CMP.B   BADLENGTH,D1
             BEQ     BADINPUT 
             MOVE.B  #8,D2   
             BRA     CONV    

BADINPUT    MOVE.B  #0,D0   ;temp for debugging purposes

TESTSTART   CMP.L   #STARTADDR,A5
            BGT     TESTEND
            BRA     BADINPUT

TESTEND     CMP.L   #ENDADDR,A6    
            BLE     TESTADDR
            BRA     BADINPUT      
            
TESTADDR    CMPA.L   A5,A6
            BLT     LOOPSTART

*_____________________________________________________________________________________________________*

LOOPSTART   
            MOVEA.L A5,A2       Copies starting addr from A5 to A2 (addr ptr)
            MOVE    #0,D7       Clears D7 for counter
            BRA     PRLOOP      Enters program loop
            
            RTS
            
PRLOOP      CMP.L   A2,A6       Compares addr pointer and ends program if
            BEQ     ENDLOOP     equal to end address
            JSR     ReadNextInstruction    Reads next set of data
            JSR     NEWLINE     Enters a new line
            
            ADDQ.L  #2,A2       Increments A2 (addr ptr) by 4
            ADDQ.L  #1,D7       Increments D7 display counter by 1
            CMP.L   #CTRMAX,D7  Checks if counter reaches max of CTRMAX
            BEQ     CONTINUEMSG Branches to CONTINUEMSG
            BRA     PRLOOP
            
NEWLINE     LEA     EMPTY,A1
            MOVE.B  #13,D0
            TRAP    #15         Enters a new line using EMPTY
            RTS
            
READNEXT    JSR     TMPDISPLAY  Temporary subroutine for testing
                    RTS
                    
CONTINUEMSG CMP.L   A2,A6       Double checks there are more addresses
            BEQ     END         for edge cases where the counter ends
                               ;when program reaches the end address 
            
            JSR     NEWLINE     Enters a new line
            LEA     CONTINUE,A1
            MOVE.B  #14,D0      Displays CONTINUE message, prompting
            TRAP    #15         user to press enter
            JSR     NEWLINE     Enters a new line
            MOVE.B  #2,D0
            TRAP    #15         Waits for user to press enter
            
            MOVE.L  #0,A1       Clears A1
            MOVE.L  #0,D7       Resets D7 counter
            BRA     PRLOOP      Branches back to program loop
            
ENDLOOP     JSR     NEWLINE     Fills remaining white space with empty
            ADDQ    #1,D7       spaces
            CMP.L   #CTRMAX,D7
            BEQ     END
            BRA     ENDLOOP

END         JSR     NEWLINE
            LEA     LOOPEND,A1
            MOVE.B  #13,D0
            TRAP    #15         Displays end of program message
            SIMHALT             Ends the program

TMPDISPLAY  MOVE    #3,D0
            MOVE.L  A2,D1
            TRAP    #15         Displays current address
            RTS

    

  



***______________Branching_System:Main______________***

_NOP
    LEA     INSTNOP, A1
    TRAP    #15
    RTS


ReadNextInstruction
    
    
    
    MOVE.B  #3, D0
    MOVE    A2, D1
    JSR     HexPrinterLong
        
    MOVE.B  #14, D0         Setting trap code for strings
    MOVE.W  (A2), D1        Load instruction into D1
    
    ASL.W   #1, D1          Last minute inclusion of NOP
    BCS  OtherInst
    ASL.W   #1, D1
    BCC   OtherInst
    ASL.W   #1, D1
    BCS    OtherInst
    ASL.W   #1, D1
    BCS   OtherInst
    ASL.W   #1, D1
    BCC   OtherInst
    ASL.W   #1, D1
    BCC   OtherInst
    ASL.W   #1, D1
    BCC   OtherInst
    ASL.W   #1, D1
    BCS   OtherInst
    ASL.W   #1, D1
    BCS   OtherInst
    ASL.W   #1, D1
    BCC    OtherInst
    ASL.W   #1, D1
    BCC    OtherInst
    ASL.W   #1, D1
    BCC    OtherInst
    ASL.W   #1, D1
    BCS    OtherInst
    ASL.W   #1, D1
    BCS    OtherInst
    ASL.W   #1, D1
    BCS    OtherInst
    JMP     _NOP
    BCC    OtherInst
    JMP     _NOP
OtherInst    
    
    
    
    MOVE.W  (A2), D1        Load instruction into D1
    
    ASL.W   #1, D1          Repeat shifting out bits and comparing to find out instruction
    BCS     _1              BCS to branch on C set, BCC to branch on clear
    BCC     _0    
_1

    ASL.W   #1, D1
    BCS     _11
    BCC     _10

_10
    
    ASL.W   #1, D1
    BCS     BadBuffer
    BCC     _100
    
_100
    
    ASL.W   #1, D1
    BCS     _1001_SUB   
    BCC     _1000_OR
    
_1000_OR

    NOP                 Insert
    LEA     INSTADD,A1
    TRAP    #15
    JMP     OpmodeInstSetHandling
    RTS   
    
_1001_SUB

    NOP                 Insert
    
    MOVE.W  (A2), D1
    ASL.W   #4, D1      Need to refill due to RTS instruction checking
    
    LEA     INSTSUB,A1
    TRAP    #15
    JMP     OpmodeInstSetHandling
    RTS

_11

    ASL.W   #1, D1
    BCS     _111
    BCC     _110
    
_110
    ASL.W   #1, D1
    BCS     _1101_ADD
    BCC     _1100_AND


_1101_ADD
    
    NOP                 Insert
    LEA     INSTADD,A1
    TRAP    #15
    JMP     OpmodeInstSetHandling
    RTS
                

_1100_AND

    NOP                 Insert
    LEA     INSTAND,A1
    TRAP    #15
    JMP     OpmodeInstSetHandling
    RTS
    
_111

    ASL.W   #1, D1
    BCC     _1110_ROTSHIFT
    BCS     BadBuffer

_1110_ROTSHIFT

    NOP                     Insert (Note: same code is shared with rotate and shift)
    ASL.W   #3, D1          Get rid of remaining count/reg bitsc


    ASL.W   #1, D1          Directionaget
    BCS     _1110_1_Lefties
    BCC     _1110_0_Righties
    
_1110_1_Lefties

    ASL.W   #3, D1  Clean out size and i/r bit
    ASL.W   #1, D1  Const
    BCC     _1110_1_0_Lefties
    BCS     _1110_1_1_Lefties
    
    
_1110_1_0_Lefties

    ASL.W #1, D1        Make sure to refill both branches
    BCC   _1110_ASL
    BCS   _1110_LSL   

_1110_1_1_Lefties

    ASL.W #1, D1
    BCS   _1110_ROL     Remember to refill on branch
    BCC   BadBuffer     11 is ROL, 10 is garbage
    
_1110_0_Righties

    ASL.W   #3, D1  Clean out size and i/r bit
    ASL.W   #1, D1  Const
    BCC     _1110_0_0_Righties
    BCS     _1110_0_1_Righties

_1110_0_0_Righties
    
    ASL.W #1, D1        Make sure to refill both branches
    BCC   _1110_ASR
    BCS   _1110_LSR   

_1110_0_1_Righties

    ASL.W #1, D1
    BCS   _1110_ROR     Remember to refill on branch
    BCC   BadBuffer     Just like the ROL case, 11 is ROR, 10 is garbage
    
_1110_ASR

    NOP                 Insert
    LEA     INSTASR, A1
    TRAP    #15
    
    JMP     SRGroupFormatter     
    
_1110_LSR

    NOP                 Insert
    LEA     INSTLSR, A1
    TRAP    #15
    
    JMP     SRGroupFormatter  

_1110_ROR

    NOP                 Insert
    LEA     INSTROR, A1
    TRAP    #15
    
    JMP     SRGroupFormatter 

_1110_ASL

    NOP                 Insert
    LEA     INSTASL, A1
    TRAP    #15
    
    JMP     SRGroupFormatter 

_1110_LSL

    NOP                 Insert
    LEA     INSTLSL, A1
    TRAP    #15
    
    JMP     SRGroupFormatter 

_1110_ROL    

    NOP                 Insert
    LEA     INSTROL, A1
    TRAP    #15
    
    JMP     SRGroupFormatter 
    

SRGroupFormatter

    MOVE.W  (A2), D1
    ASL.W   #8, D1
    JSR     TRANSSIZE
    
    MOVE.B  #14, D0
    LEA     CHARTAB, A1
    TRAP    #15         Print Size + tab

    NOP                 Print a D character or a # character depending on the ir bit
    ASL.W   #1, D1
    BCS     SRGIF_D
    BCC     SRGIF_IMD
    
SRGIF_Resume
    
    MOVE.W  (A2), D1
    ASL.W   #4, D1
    JSR     DECODER3
    CMP.B   #0, D3
    
    BEQ     The8Case

Processed8Check
    
    MOVE.W  D3, D1
    MOVE.B  #3, D0
    TRAP    #15
    
    ASL.W   #6, D1
    JSR     DECODER3
    
    MOVE.B  #14, D0
    LEA     Comma, A1
    TRAP    #15
    LEA     CHARD, A1
    TRAP    #15

    MOVE.W  D3, D1
    MOVE.B  #3, D0
    TRAP    #15

    RTS 
    
    
The8Case

    NOP     A zero in the count apparently signifies 8
    MOVE.B  #8, D3
    JMP     Processed8Check    
    
    
SRGIF_D

    LEA     CHARD, A1
    TRAP    #15
    JMP     SRGIF_Resume  
    
SRGIF_IMD

    LEA     CHARIMD, A1
    TRAP    #15
    JMP     SRGIF_Resume  
    
_0
    ASL.W   #1, D1       Repeat shifting out bits and comparing to find out instruction
    BCS     _01          Branch to 01 if set
    BRA     _00_MOVEA    00 = MOVE/MOVA
    
_01
    
    ASL.W   #1, D1
    BCS     _011
    BCC     _010
    
_010
    ASL.W   #1, D1
    BCS     _0101_ADDQ
    BCC     _0100_JSR
    
    
_0101_ADDQ

    ASL.W   #4, D1      Additional verification that this is, in fact, ADDQ
    BCS     BadBuffer   BadBuffer if constant doesn't line up    
    
    MOVE.W  (A2), D1    Refill if haven't jumped
    ASL.W   #4, D1
    
    NOP                     Insert
    
    LEA     INSTADDQ, A1
    TRAP    #15             Print name
    
    
    ASL.W   #4, D1
    JSR     TRANSSIZE       Now print size after print inst
    
    LEA     CHARTAB, A1
    TRAP    #15
    LEA     CHARIMD, A1
    TRAP    #15             Print the #
    
    
    MOVE.W  (A2), D1        Refill, move to data section
    ASL.W   #4, D1
    JSR     DECODER3        get 3 bit data
    
    MOVE.B  #3, D0
    JSR     SetTempHold
    MOVE.L  D3, D1
    TRAP    #15             data value
    
    JSR     ResetTempHold
    
    MOVE.B  #14, D0         
    LEA     Comma, A1
    TRAP    #15    
    
    ASL.W   #3, D1
    JSR     GeneralEAHandler
    
    RTS
    
    

_0100_JSR

    ASL.W   #1, D1      Binary reduction to find if inst is LEA, NOT or JSR
    BCC.W   _0100_NOT   1    
    ASL.W   #1, D1
    BCC.W   _0100_NOT   1
    ASL.W   #1, D1
    BCC.W   _0100_NOT   1
    ASL.W   #1, D1
    BCS.W   _0100_NOT   0
    ASL.W   #1, D1
    BCC.W   _0100_NOT   1
    ASL.W   #1, D1
    BCS.W   _0100_JMP   0   
    
    NOP                Insert
    MOVE.W  (A2), D1
    ASL.W   #8, D1
    ASL.W   #2, D1
    
    LEA     INSTJSR, A1
    TRAP    #15
    
    JSR     GeneralEaHandler
    RTS
    
_0100_JMP
    
    NOP                Insert
    MOVE.W  (A2), D1
    ASL.W   #8, D1
    ASL.W   #2, D1
    
    LEA     INSTJMP, A1
    TRAP    #15
    
    JSR     GeneralEaHandler
    RTS

        
    
_0100_NOT

    MOVE.W  (A2), D1    Refill, then check again
    ASL.W   #4, D1      ignore 4 binary constants
    
    ASL.W   #1, D1      
    BCS     _0100_LEA   0
    ASL.W   #1, D1 
    BCC     _0100_LEA   1
    ASL.W   #1, D1
    BCC     _0100_LEA   1
    ASL.W   #1, D1
    BCS     _0100_LEA   0
    
    NOP                 Insert
    MOVE.W  (A2), D1
    ASL.W   #4, D1
    
    LEA     INSTNOT, A1
    TRAP    #15
    JSR     TRANSSIZE
    
    MOVE.B  #14, D0
    LEA     CHARTAB, A1
    TRAP    #15
    
    JSR     GeneralEaHandler
    RTS
    
    
_0100_LEA
    
    MOVE.L  A2, A0
    MOVE.W  (A2), D1    Refill, then check again
    ASL.W   #7, D1      ignore 4 binary constants, then 3 binary variants
    ASL.W   #1, D1
    BCC.W   _0100_RTS   1
    ASL.W   #1, D1
    BCC.W   _0100_RTS   1
    ASL.W   #1, D1
    BCC.W   _0100_RTS   1
    MOVE.W  (A2), D1    Refill
    ASL.W   #4, D1      Remove constants
    
    NOP                 Insert
    LEA     INSTLEA, A1
    TRAP    #15
    
    ASL.W   #6, D1
    JSR     GeneralEaHandler
    
    MOVE    #14, D0
    LEA     Comma, A1
    TRAP    #15
    
    MOVE.W  (A0), D1
    ASL.W   #4, D1
    LEA     CHARA, A1
    TRAP    #15
    
    JSR     DECODER3
    MOVE.L  D3, D1
    MOVE.B  #3, D0
    TRAP    #15

    RTS



_0100_RTS

    MOVE.W  (A2), D1
    
    ASL.W   #1, D1
    BCS     BadBuffer   0
    ASL.W   #1, D1
    BCC     BadBuffer   1
    ASL.W   #1, D1
    BCS     BadBuffer   0
    ASL.W   #1, D1
    BCS     BadBuffer   0
    ASL.W   #1, D1
    BCC     BadBuffer   1
    ASL.W   #1, D1
    BCC     BadBuffer   1
    ASL.W   #1, D1
    BCC     BadBuffer   1
    ASL.W   #1, D1
    BCS     BadBuffer   0       
    ASL.W   #1, D1
    BCS     BadBuffer   0
    ASL.W   #1, D1
    BCC     BadBuffer   1
    ASL.W   #1, D1
    BCC     BadBuffer   1
    ASL.W   #1, D1
    BCC     BadBuffer   1
    ASL.W   #1, D1
    BCS     BadBuffer   0
    ASL.W   #1, D1
    BCC     BadBuffer   1
    ASL.W   #1, D1
    BCS     BadBuffer   0
    ASL.W   #1, D1
    BCC     BadBuffer   1
 
        
    NOP                 Insert (no inst sections here, just print) 
    LEA     INSTRTS, A1
    TRAP    #15
    RTS
    
    
_011

    ASL.W   #1, D1
    BCS     _0111_MOVEQ
    BCC     _0110           This one goes into the branch set of instructions
    
_0110
    
    ASL.W   #1, D1
    BCC     _0110_0
    BCS     _0110_1

_0110_1

    ASL.W   #1, D1
    BCC     BadBuffer
    ASL.W   #1, D1
    BCC     BadBuffer
    ASL.W   #1, D1
    BCC     _0110_1110_BGT
    BCS     _0110_1111_BLE

_0110_1110_BGT

    NOP                 Insert
    
    LEA     INSTBGT, A1
    TRAP    #15
    
    JMP     DisplacementHandler
    

_0110_1111_BLE

    NOP                 Insert
    
    LEA     INSTBLE, A1
    TRAP    #15
    
    JMP     DisplacementHandler
    
_0110_0    
    
    ASL.W   #1, D1
    BCC     _0110_00_BRA
    BCS     _0110_01
    
_0110_00_BRA

    ASL.W   #1, D1
    BCS     BadBuffer
    ASL.W   #1, D1
    BCS     BadBuffer
    
    NOP                 Insert
    
    LEA     INSTBRA, A1
    TRAP    #15
    
    JMP     DisplacementHandler
    
    

_0110_01

    ASL.W   #1, D1
    BCC     _0110_010_BCC
    BCS     _0110_011_BEQ
    
_0110_010_BCC

    ASL.W   #1, D1
    BCS     _BCS
    NOP                 Insert

    LEA     INSTBCC, A1
    TRAP    #15
    
    JMP     DisplacementHandler

_BCS
    
    LEA     INSTBCS, A1
    TRAP    #15
    
    JMP     DisplacementHandler

        
    
_0110_011_BEQ
    
    ASL.W   #1, D1
    BCC     _BNE
    
    NOP                 Insert
    
    LEA     INSTBEQ, A1
    TRAP    #15
    
    JMP     DisplacementHandler
    

_BNE

    LEA     INSTBEQ, A1
    TRAP    #15
    
    JMP     DisplacementHandler
    
        
    
_0111_MOVEQ
    
    NOP                 Insert
    ASL.W   #4, D1
    
    LEA     INSTMOVEQ, A1
    TRAP    #15
    
    LEA     CHARIMD, A1
    TRAP    #15       
    
    MOVE.B  #8, D2
    JSR     SHIFTER     The bits are within the word sized instruction, so this should still work
    
    MOVE.L  D3, D1
    MOVE.B  #3, D0
    TRAP    #15
    
    CLR     D1
    CLR     D3
    
    MOVE.B  #14, D0
    LEA     Comma, A1
    TRAP    #15
    
    LEA     CHARD, A1
    TRAP    #15
    
    MOVE.W  (A2), D1
    ASL.W   #4, D1
    MOVE.B  #3, D0
    JSR     DECODER3
    MOVE.B  D3, D1
    
    RTS

_00_MOVEA

    ASL.W   #5, D1       Clean varient bits
    ASL.W   #1, D1
    BCS.W   _00_MOVE     continue if 0
    ASL.W   #1, D1
    BCS.W   _00_MOVE     continue if 0
    ASL.W   #1, D1
    BCC.W   _00_MOVE     continue if 1
    
    MOVE.W  (A2), D1    Refill instruction
    ASL.W   #2, D1      Const out
    
    NOP                 Insert for MOVEA
    
    LEA     INSTMOVEA, A1
    TRAP    #15
    JSR     TRANSSIZE
    LEA     CHARTAB, A1
    TRAP    #15
    
    ASL.W   #6, D1      Destination operand will always be an address register: Ea first, then AReg
    JSR     GeneralEaHandler
    
    MOVE.B  #14, D0
    LEA     Comma, A1
    TRAP    #15
    LEA     CHARA, A1
    TRAP    #15         Print character A, then get decoder value
    
    MOVE.W  (A2), D1
    ASL.W   #5, D1
    JSR     DECODER3
    MOVE.L  D3, D1
    MOVE.B  #3, D0
    TRAP    #15 

    RTS     
    
    
    
_00_MOVE

    MOVE.W  (A2), D1    Refill instruction
    ASL.W   #2, D1
    NOP                 Insert
    NOP                 This is a special instruction: we don't have anything for handling reg into mode, but we can reuse the GEH subroutine if we reconstruct the instruction, allowing use to process this instruction.
    NOP                 Use ASL and ASR to single out destmode and destreg, then shift destmode to left, and use move.b on dest reg to combine the two. 
    NOP                 
    
    LEA     INSTMOVE, A1
    TRAP    #15
    
    JSR     TRANSSIZE   Start with the size 
    MOVE.B  #14, D0
    LEA     CHARTAB, A1
    TRAP    #15
    
    NOP                 INSTRUCTION RECONSTRUCTION
    
    ASL.W   #6, D1
    JSR     GeneralEaHandler
    
    
    MOVE.B  #14, D0
    LEA     Comma, A1
    TRAP    #15
    
    JSR     MOVEReconst
    
    JSR     GeneralEaHandler
    
    RTS
    
MOVEReconst
   
    MOVE    (A2), D1        _ _ _ _ R R R M M M _ _ _ _ _ _
    ASL.W   #7, D1          M M M _ _ _ _ _ _ X X X X X X X 
    ASL.L   #3, D1   M M M -R R R X X X X X X X X X X X X X   
    MOVE.L  D1, D3   M M M 
    
    MOVE    (A2), D1 
    ASL.W   #4, D1   R R R M M M _ _ _ _ _ _
    MOVE.W  D1, D3   M M M - R R R
    ASR.L   #3, D3   - M M M R R R
    MOVE.L  D3, D1
    CLR     D3
    
    RTS
    
SkipOver
    RTS    
BadBuffer
    
    NOP                 Insert
    
    LEA     CHARTAB, A1
    TRAP    #15
    LEA     _BadBuffer, A1
    TRAP    #15
    LEA     CHARTAB, A1
    
    MOVE.W  (A2), D1
    CMP.W   #$FFFF, D1
    BEQ     SkipOver
    
    MOVE.W  (A2), D1        Still need to check for EA
    ASL.W   #8, D1
    JSR     TRANSSIZE
    
    
    
    MOVE.W  (A2), D1
    ASL.W   #5, D1
    ASL.W   #5, D1
    JSR     GeneralEaHandler    
    RTS
     
***______________Branching_System:MISC_Address_Handling______________***
    
FoundOPW_EA

    MOVE.L   A2, A3
    ADD      #2, A3      Move the A3 pointer to start of location of data carrying word address
    MOVE.W  (A3), D5    Read and move the data there into D5 (don't need D5 content since already used to read EA Type)  
    
    BRA     OISHResume  Can't use RTS since BEQ branches don't load return address into PC
     
FoundOPL_EA

    MOVE.L   A2, A3
    ADD      #2, A3      Move the A3 pointer to start of location of data carrying word address
    MOVE.L  (A3), D5    Read and move the data there into D5 (don't need D5 content since already used to read EA Type) 
    ADD     #6, A3
 
    BRA     OISHResume  Can't use RTS since BEQ branches don't load return address into PC


DisplacementHandler

    NOP                 Assumes pointer is at start of 8 bit displacement field
    MOVE.B  #8, D2
    JSR     SHIFTER
    
    MOVE.B  #3, D0
    CMP     #0, D3
    BEQ     WordDisplace
    CMP     #255, D3
    BEQ     LongDisplace
    
    MOVE.B  D3, D1
    
    
    TRAP    #15
    
    RTS

DoneHexLoop
    RTS

HexPrinterLong

    NOP                     Assumes hex number to be printed out is in D1, will stop once nothing is in D1
    MOVE.B  #14, D0
    MOVE.W  #8, A4
    JMP     HexStart        By starting past loop control, ensures at least one character is printed out.
HexLoop
    SUB.W   #1, A4
    CMP.L   #0, A4
    BEQ     DoneHexLoop

HexStart    
    MOVE.B  #4, D2
    JSR     LONGSHIFTER
    
    CMP     #0, D3
    BEQ     _Char0
    CMP     #1, D3
    BEQ     _Char1
    CMP     #2, D3
    BEQ     _Char2
    CMP     #3, D3
    BEQ     _Char3
    CMP     #4, D3
    BEQ     _Char4
    CMP     #5, D3
    BEQ     _Char5
    CMP     #6, D3
    BEQ     _Char6
    CMP     #7, D3
    BEQ     _Char7
    CMP     #8, D3
    BEQ     _Char8
    CMP     #9, D3
    BEQ     _Char9
    CMP     #$A, D3
    BEQ     _CharA
    CMP     #$B, D3
    BEQ     _CharB
    CMP     #$C, D3
    BEQ     _CharC
    CMP     #$D, D3
    BEQ     _CharD
    CMP     #$E, D3
    BEQ     _CharE
    CMP     #$F, D3
    BEQ     _CharF    


_Char0
    LEA     CHAR0, A1
    TRAP    #15
    JMP     HexLoop
_Char1
    LEA     CHAR1, A1
    TRAP    #15
    JMP     HexLoop
_Char2
    LEA     CHAR2, A1
    TRAP    #15
    JMP     HexLoop
_Char3
    LEA     CHAR3, A1
    TRAP    #15
    JMP     HexLoop
_Char4
    LEA     CHAR4, A1
    TRAP    #15
    JMP     HexLoop
_Char5
    LEA     CHAR5, A1
    TRAP    #15
    JMP     HexLoop
_Char6
    LEA     CHAR6, A1
    TRAP    #15
    JMP     HexLoop
_Char7
    LEA     CHAR7, A1
    TRAP    #15
    JMP     HexLoop
_Char8
    LEA     CHAR8, A1
    TRAP    #15
    JMP     HexLoop
_Char9
    LEA     CHAR9, A1
    TRAP    #15
    JMP     HexLoop
_CharA
    LEA     CHARA, A1
    TRAP    #15
    JMP     HexLoop
_CharB
    LEA     CHARB, A1
    TRAP    #15
    JMP     HexLoop
_CharC
    LEA     CHARC, A1
    TRAP    #15
    JMP     HexLoop
_CharD
    LEA     CHARD, A1
    TRAP    #15
    JMP     HexLoop
_CharE
    LEA     CHARE, A1
    TRAP    #15
    JMP     HexLoop
_CharF
    LEA     CHARF, A1
    TRAP    #15
    JMP     HexLoop


*__________________________________________________________________________________________*


HexPrinterWord

    NOP                     Assumes hex number to be printed out is in D1, will stop once nothing is in D1
    MOVE.B  #14, D0
    MOVE.W  #4, A4
    JMP     HexStart2        By starting past loop control, ensures at least one character is printed out.
HexLoop2
    SUB.W   #1, A4
    CMP.L   #0, A4
    BEQ     DoneHexLoop

HexStart2    
    MOVE.B  #4, D2
    JSR     SHIFTER
    
    CMP     #0, D3
    BEQ     _Char02
    CMP     #1, D3
    BEQ     _Char12
    CMP     #2, D3
    BEQ     _Char22
    CMP     #3, D3
    BEQ     _Char32
    CMP     #4, D3
    BEQ     _Char42
    CMP     #5, D3
    BEQ     _Char52
    CMP     #6, D3
    BEQ     _Char62
    CMP     #7, D3
    BEQ     _Char72
    CMP     #8, D3
    BEQ     _Char82
    CMP     #9, D3
    BEQ     _Char92
    CMP     #$A, D3
    BEQ     _CharA2
    CMP     #$B, D3
    BEQ     _CharB2
    CMP     #$C, D3
    BEQ     _CharC2
    CMP     #$D, D3
    BEQ     _CharD2
    CMP     #$E, D3
    BEQ     _CharE2
    CMP     #$F, D3
    BEQ     _CharF2   


_Char02
    LEA     CHAR0, A1
    TRAP    #15
    JMP     HexLoop2
_Char12
    LEA     CHAR1, A1
    TRAP    #15
    JMP     HexLoop2
_Char22
    LEA     CHAR2, A1
    TRAP    #15
    JMP     HexLoop2
_Char32
    LEA     CHAR3, A1
    TRAP    #15
    JMP     HexLoop2
_Char42
    LEA     CHAR4, A1
    TRAP    #15
    JMP     HexLoop2
_Char52
    LEA     CHAR5, A1
    TRAP    #15
    JMP     HexLoop2
_Char62
    LEA     CHAR6, A1
    TRAP    #15
    JMP     HexLoop2
_Char72
    LEA     CHAR7, A1
    TRAP    #15
    JMP     HexLoop2
_Char82
    LEA     CHAR8, A1
    TRAP    #15
    JMP     HexLoop2
_Char92
    LEA     CHAR9, A1
    TRAP    #15
    JMP     HexLoop2
_CharA2
    LEA     CHARA, A1
    TRAP    #15
    JMP     HexLoop2
_CharB2
    LEA     CHARB, A1
    TRAP    #15
    JMP     HexLoop2
_CharC2
    LEA     CHARC, A1
    TRAP    #15
    JMP     HexLoop2
_CharD2
    LEA     CHARD, A1
    TRAP    #15
    JMP     HexLoop2
_CharE2
    LEA     CHARE, A1
    TRAP    #15
    JMP     HexLoop2
_CharF2
    LEA     CHARF, A1
    TRAP    #15
    JMP     HexLoop2

WordDisplace

    ADD         #2, A2      Loop will increment by an additional 2 bytes on end
    MOVE.W      (A2), D1
    JSR         HexPrinterWord
    
    RTS
    
LongDisplace 

    ADD         #2, A2      Loop will increment by an additional 2 bytes on end
    MOVE.L      (A2), D1
    JSR         HexPrinterLong
    
    ADD         #2, A2      Long is 4 bytes - increment 2 here, and loop will increment another two
    
    RTS   
    
PrintSet

    MOVE.W  D1, D2
    RTS

PrintUnset
    
    MOVE.W D2, D1
    MOVE.W $0000, D2
    RTS 
    
OISHCase1_EaDn

    ASL.W   #2, D1          get remaining opmode bits out
    
    JSR     TRANSDEST       Assuming this functionally prints register and number
    
    LEA     Comma, A1
    MOVE.B  #14, D0
    TRAP    #15
    LEA     OPMODEDCHAR, A1
    TRAP    #15

    MOVE.W  (A2), D1        Refill and extract data register
    ASL.W   #4, D1
    JSR     DECODER3
    
    MOVE.W  D3, D1
    MOVE.B  #3, D0
    TRAP    #15
    
    RTS                     Done, going back to program loop
    
OISHCase1_DnEa    

    MOVE.B  #14, D0
    LEA     OPMODEDCHAR, A1
    TRAP    #15
    MOVE.W  (A2), D1        Refill and extract data register
    ASL.W   #4, D1
    JSR     DECODER3
    
    MOVE.W  D3, D1
    MOVE.B  #3, D0
    TRAP    #15             Print Data register
    
    LEA     Comma, A1
    MOVE.B  #14, D0
    TRAP    #15             print comma
    
    MOVE.W  (A2), D1        Refill and prep for translate
    
    ASL.W   #8, D1          
    ASL.W   #2, D1          get 10 bits out of the way
    
    JSR     TRANSDEST
    
    RTS                     Done, going back to program loop
    
GeneralEaHandler

    JSR     TRANSDEST       I've modified the translator to have D5 as 3 on enter. This means if the EA translator branch ISN'T followed, there's a state indicating that 
    NOP                     there are no address extentions to the instruction.
    CMP     #3, D5
    BNE     GEH_Ext
    RTS                     Meaning, if there's a 3 in D5, no extension processing is needed and all else has been processed.

    
GEH_Ext

    CMP     #0, D5
    BEQ     GEH_Word
    CMP     #1, D5
    BEQ     GEH_Long
    CMP     #2, D5
    BEQ     GEH_IMBranch
    
    
GEH_IMBranch
    CMP.B   #1, D6
    BEQ     GEH_Word
    CMP.B   #2, D6
    BEQ     GEH_Long
    BRA     GEH_Word    
    
GEH_Word
    
    MOVE.L  A2, A3          Move the address to A3 and increment so that address extention can be extracted
    MOVE.L  A2, A0
    ADD.L   #2, A3          Add two bytes to A3 to get to extention location
    MOVE.W  (A3), D1        
    
    MOVE.B  #3, D0
    TRAP    #15
    
    MOVE.L   A3, A2          Increment the main address pointer so that data isn't read as instruction
    
    RTS 
    
GEH_Long
    
    MOVE.L  A2, A3          Move the address to A3 and increment so that address extention can be extracted
    MOVE.L  A2, A0
    ADD     #2, A3          Add two bytes to A3 to get to extention location
    MOVE.L  (A3), D1        
    
    MOVE.B  #14, D0
    LEA     CHARDOL, A1
    TRAP    #15
    JSR     HexPrinterLong
    CLR     D1              Get persistant long bits out
    
    ADD     #2, A3          Incrementing by 2 bytes only - since program loop will increment by 2 on exit as well
    MOVE    A3, A2          Increment the main address pointer so that data isn't read as instruction
    
    RTS 
    
       
    
     
OpmodeInstSetHandling

    
    MOVE.W  (A2), D1        First, check if this instruction has an address extension or not. This will change the branch of processing. Case 2 = extention, case 1 = all else
    ASL.W   #8, D1
    ASL.W   #2, D1          Go directly to EAmode bits, check for 7
    JSR     DECODER3
    CMP     #7, D3          If it's a 7, it's case 2, otherwise, case 1
    BEQ     OpmodeInstSetHandlingCase2
    
    MOVE.W  (A2), D1        refill and get first opmode bit
    ASL.W   #7, D1
    ASL     #1, D1          test first bit and branch accordingly
    BCC     OISHCase1_EaDn
    BCS     OISHCase1_DnEa

OpmodeInstSetHandlingCase2
    MOVE.W  (A2),D1
    ASL.W   #4, D1      
    JSR     DECODER3       Ensure that binary constants are out before calling this: Will handle processing of ENTIRE instruction that follows const-Dreg-opmode-eamode-eareg
    MOVE.B  D3, D6          Temp store the D-Reg in D6
    ASL.W   #6, D1          Will refill and read later in funct
    JSR     TRANSEA        Transea: 0 for abs word, 1 for long, and 2 for imdata
    CMP     #0, D5          
    BEQ     FoundOPW_EA
    CMP     #1, D5
    BEQ     FoundOPL_EA
    CMP     #2, D5
    BEQ     FoundOPL_EA
        
    
OISHResume

    MOVE.W  (A2), D1            Refill instruction and proceed directly to OPmode section
    ASL.W   #7, D1              Skip 7
    JMP     OpmodePrintOrder    So something fun I learned: the first bit of the opmode is 0 if ea+dn, but 1 if dn+ea. We have the data size-loaded already, so the
    NOP                         other bits aren't needed. You'll see this in the next branch.
    
    
OpmodePrintOrder
    
    ASL     #1, D1              test first bit and branch accordingly
    BCC     OPO_EaDn
    BCS     OPO_DnEa

OPO_EaDn

    MOVE.B  #3, D0          print Ea
    JSR     SetTempHold
    MOVE.L  D5, D1
    TRAP    #15

    
    MOVE.B  #1, D0          print , + Dn
    LEA     Comma, A1
    TRAP    #15
    
    LEA     OPMODEDCHAR, A1
    TRAP    #15
    MOVE.L  #0, D1
    CLR.L   D1
    MOVE.B  D6, D1
    MOVE.B  #3, D0
    TRAP    #15
    
    JSR     ResetTempReg
    
    JSR     ResetTempHold
    
    MOVE    A3, A2              When the loop counter is reached, it will increment by 2 bytes. Need to make sure next instruction is only two bytes from pointer.

    RTS                         From here, printing of instruction is complete, so returning back to program loop

OPO_DnEa
    
    LEA     OPMODEDCHAR, A1     print Dn
    TRAP    #15
    CLR.L     D1
    MOVE.B  D6, D1
    MOVE.B  #3, D0
    TRAP    #15
    
    MOVE.B  #1, D0              print , + Ea
    LEA     Comma, A1
    TRAP    #15
    
    MOVE.B  #3, D0              print Ea
    JSR     SetTempHold
    MOVE.L  D5, D1
    TRAP    #15
    JSR     ResetTempHold
    

    JSR     ResetTempReg
    
    MOVE    A3, A2              When the loop counter is reached, it will increment by 2 bytes. Need to make sure next instruction is only two bytes from pointer.

    RTS                         From here, printing of instruction is complete, so returning back to program loop
    
SetTempHold

    MOVE.W  D1, D2
    RTS

ResetTempHold    
    
    MOVE.W  D2, D1
    MOVE.W  #0, D2              Clean D2
    RTS
    
ResetTempReg

    MOVE.L  #0, D5              Clean the registers
    MOVE.L  #0, D6
    RTS
    
    
    
       
   
***______________MESSAGES______________***






*__________________________SHIFTER: TESTING - REMOVE BEFORE INTEGRATION______________________________________*


    MOVE.B      D1, D1
SHIFTER    
           MOVE.B   D2, D3
           MOVE.L   D3, D2
           
           CLR.W    D4
           MOVE.W   #1,D4
           CLR.W    D3
           BRA      MULT_LOOP

MULT_LOOP
           MULU     #2,D4    ; multiply D2 and D4, store in D4
           SUBQ.W   #1,D2
           CMP.W    #1,D2
           BNE      MULT_LOOP

           
LOOP2
           CMP.W    #0,D4    
           BEQ      CLEAN
           ASL.W    #1,D1
           BCC      ZERO
           BCS      ONE
           
           
ONE
           ADD.W    D4,D3    ;  add the data in D4 into D3
           DIVU     #2,D4
           BRA      LOOP2
           
           
ZERO       
           DIVU     #2,D4
           BRA      LOOP2
           
CLEAN      CLR.W    D4
           RTS
           
           
           
LONGSHIFTER    
           MOVE.B   D2, D3
           MOVE.L   D3, D2
           
           CLR.L    D4                                      NOTE:____________________________________________________________________________________
           MOVE.L   #1,D4                                   The shifter was originally intended for word sized shift and read operations. This works for everything EXCEPT the hexreader, which needs a modified version 
           CLR.L    D3                                      that works on long operations. There aren't any changes besides long size codes on the instructions.
           BRA      MULT_LOOP2

MULT_LOOP2
           MULU     #2,D4    ; multiply D2 and D4, store in D4
           SUBQ.L   #1,D2
           CMP.L   #1,D2
           BNE      MULT_LOOP2

           
LOOP22
           CMP.W    #0,D4    
           BEQ      CLEAN2
           ASL.L    #1,D1
           BCC      ZERO2
           BCS      ONE2
           
           
ONE2
           ADD.L    D4,D3    ;  add the data in D4 into D3
           DIVU     #2,D4
           BRA      LOOP22
           
           
ZERO2       
           DIVU     #2,D4
           BRA      LOOP22
           
CLEAN2     CLR.L    D4
           RTS
           
           
*_____________________TRANSLATER FOR TESTING PURPOSES, REMOVE AT INTEGRATION__*

DECODER3
        MOVE.L  #3,D2
        JSR     SHIFTER
        RTS
        
DECODER2
        MOVE.L  #2,D2
        JSR     SHIFTER
        RTS
********TRANSLATE SIZE********
*-------------------------------------*
TRANSSIZE
        CLR     D6
        JSR     DECODER2
        CMP.L   #1,D3
        BEQ     OUTPUTBYTE
        CMP.L   #3,D3
        BEQ     OUTPUTWORD
        CMP.L   #2,D3
        BEQ     OUTPUTLONG
        RTS
        
OUTPUTBYTE
        LEA     BYTEMSG,A1
        MOVE.L  #14,D0
        TRAP    #15
        RTS
               
OUTPUTWORD
        LEA     WORDMSG,A1
        MOVE.L  #1, D6
        MOVE.L  #14,D0
        TRAP    #15
        RTS
        
OUTPUTLONG
        LEA     LONGMSG,A1
        MOVE.L  #2, D6
        MOVE.L  #14,D0
        TRAP    #15
        RTS
*-------------------------------------*     

********TRANSLATE DESTINATION/SOURCE********
*-------------------------------------*
TRANSDEST
        MOVE.L  #3, D5
        JSR     DECODER3
        CMP.L   #0,D3
        BEQ     TRANSDREG       ;branch to data register
        CMP.L   #1,D3
        BEQ     TRANSAREGDIR    ;branch to address register direct
        CMP.L   #2,D3
        BEQ     TRANSAREGIND    ;branch to address register indirect
        CMP.L   #3,D3
        BEQ     TRANSAREGPOST   ;branch to address register post increment
        CMP.L   #4,D3
        BEQ     TRANSAREGPRE    ;branch to address register pre decrement
        CMP.L   #7,D3
        BEQ     TRANSEA         ;branch to ea
        JMP     INVALID         ;instruction invalid
*-------------------------------------*  

********TRANSLATE DATA REGISTER********
*-------------------------------------*
        MOVE.L  #0,D6

TRANSDREG 
        JSR     DECODER3
        MOVE.L  D3, D6
        JMP     OUTPUTDREG 
        
OUTPUTDREG   
        LEA     DRMSG,A1
        MOVE.L  #14,D0
        TRAP    #15  
        
        MOVE.L  D1,D2   ;temp store D1 to D2
        MOVE.L  D6,D1
        MOVE.L  #3,D0
        TRAP    #15
        MOVE.L  #0,D6   ;always clear D6  
        MOVE.L  D2,D1   ;bring back D1
        RTS   
*-------------------------------------*

********TRANSLATE ADDRESS REGISTER DIRECT********
*-------------------------------------*
TRANSAREGDIR
        JSR     DECODER3
        MOVE.L  D3, D6
        JMP     OUTPUTAREG
   
OUTPUTAREG   
        LEA     ARMSG,A1
        MOVE.L  #14,D0
        TRAP    #15  
        
        MOVE.L  D1,D2   
        MOVE.L  D6,D1
        MOVE.L  #3,D0
        TRAP    #15
        CLR     D6   ;always clear D6  
        MOVE.L D2,D1
        RTS
*-------------------------------------* 

********TRANSLATE ADDRESS REGISTER INDIRECT********
*-------------------------------------*
TRANSAREGIND
        JSR     DECODER3
        MOVE.L  D3, D6
        JMP     OUTPUTAREGIND   

OUTPUTAREGIND
        LEA     ARIMSG1,A1
        MOVE.L  #14,D0
        TRAP    #15
        
        MOVE.L  D1,D2
        MOVE.L  D6,D1
        MOVE.L  #3,D0
        TRAP    #15
        MOVE.L  #0,D6   ;always clear D6 
        MOVE.L  D2,D1 
        
        LEA     CLOSEBRA,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS
*-------------------------------------*   

********TRANSLATE ADDRESS REGISTER POST********
*-------------------------------------*
TRANSAREGPOST
        JSR     DECODER3
        MOVE.B  D3, D6
        JMP     OUTPUTAREGPOST
  
OUTPUTAREGPOST
        LEA     ARIMSG1,A1
        MOVE.B  #14,D0
        TRAP    #15
        
        MOVE.L  D1,D2
        MOVE.L  D6,D1
        MOVE.L  #3,D0
        TRAP    #15
        MOVE.L  #0,D6   ;always clear D6  
        MOVE.L  D2,D1
        
        LEA     CLOSEBRAINC,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS
*-------------------------------------* 

********TRANSLATE ADDRESS REGISTER PRE********
*-------------------------------------*
TRANSAREGPRE
        JSR     DECODER3
        MOVE.B  D3, D6
        JMP     OUTPUTAREGPRE
        
OUTPUTAREGPRE
        LEA     OPENBRAPRE,A1
        MOVE.L  #14,D0
        TRAP    #15
        
        MOVE.L  D1,D2
        MOVE.L  D6,D1
        MOVE.L  #3,D0
        TRAP    #15
        MOVE.L  #0,D6   ;always clear D6  
        MOVE.L  D2,D1
        
        LEA     CLOSEBRA,A1
        MOVE.B  #14,D0
        TRAP    #15
        RTS
*-------------------------------------* 

********TRANSLATE EA********
*-------------------------------------*
TRANSEA
       JSR      DECODER3
       CMP.L    #0,D3   ;assuming D3 holds the value of EA reg
       BEQ      ABSWORD
       CMP.L    #1,D3   
       BEQ      ABSLONG
       CMP.L    #4,D3
       BEQ      IMDATA
       JMP      INVALID ;instruction not found     

ABSWORD
      MOVE.L   #0,D5   ;d5 holds the boolean flag of the ea type (0 for absolute word)
      RTS
      
ABSLONG
      MOVE.L   #1,D5    ;1 for absolute long
      RTS

IMDATA
     MOVE.L   #2,D5    ;2 for immediate data  

     LEA       TAGMSG,A1
     MOVE.B    #14,D0
     TRAP      #15  
     RTS       

*-------------------------------------* 
        
********TRANSLATE OPMODE********
*-------------------------------------*
TRANSOPMODE
    JSR     DECODER3
    CMP.B   #0,D3   
    BEQ     BYTEMODE
    CMP.B   #4,D3
    BEQ     BYTEMODE
    CMP.B   #1,D3
    BEQ     WORDMODE
    CMP.B   #5,D3
    BEQ     WORDMODE
    CMP.B   #2,D3
    BEQ     LONGMODE
    CMP.B   #6,D3
    BEQ     LONGMODE
    JMP     INVALID
    
BYTEMODE
    MOVE.B  #0,D6
    RTS
    
WORDMODE
    MOVE.B  #1,D6
    RTS

LONGMODE
    MOVE.B  #2,D6
    RTS
*-------------------------------------* 

********TRANSLATE DIRECTION********
*-------------------------------------*
TRANSDIR
    MOVE.B  #1,D2
    JSR     SHIFTER
    CMP.B   #0,D3
    BEQ     SHIFTRIGHT
    CMP.B   #1,D3
    BEQ     SHIFTLEFT
    JMP     INVALID
    
SHIFTRIGHT
    MOVE.B  #4,D6   ;value of 4 set to D6 as an indicator that it's a shift right
    RTS
    
SHIFTLEFT
    MOVE.B  #5,D6   ;value of 5 set to D6 as an indicator that it's a shift left
    RTS
    
*-------------------------------------*    

INVALID 
        NOP     ;temp function 
        SIMHALT             ; halt simulator

* Put variables and constants here

DRMSG       DC.B    'D', 0
ARMSG       DC.B    'A', 0
ARIMSG1     DC.B    '(A', 0
OPENBRA     DC.B    '(', 0
CLOSEBRA    DC.B    ')', 0
CLOSEBRAINC DC.B    ')+', 0
OPENBRAPRE  DC.B    '-(A', 0
BYTEMSG     DC.B    '.B', 0
WORDMSG     DC.B    '.W', 0
LONGMSG     DC.B    '.L', 0
LSLMSG      DC.B    'LSL', 0
LSRMSG      DC.B    'LSR', 0
RORMSG      DC.B    'ROR', 0
ROLMSG      DC.B    'ROL', 0
TAGMSG      DC.B    '#', 0
LOOPEND     DC.B    'End address has been reached.',0   Program end message
CONTINUE    DC.B    'Press enter to continue.',0        Continue message
CTRMAX      EQU     29                                  Max number of lines displayed
EMPTY       DC.B    '',0                                Empty message for new line
ADDR        DC.B    '', 0
INSTMOVE    DC.B    '   MOVE', 0
INSTMOVEQ   DC.B    '   MOVEQ  ', 0 
INSTRTS     DC.B    '   RTS',0
INSTMOVEM   DC.B    '   MOVEM  ', 0
INSTMOVEA   DC.B    '   MOVEA', 0
INSTADD     DC.B    '   ADD    ', 0
INSTADDA    DC.B    '   ADDA   ', 0
INSTADDQ    DC.B    '   ADDQ', 0
INSTSUB     DC.B    '   SUB    ', 0
INSTLEA     DC.B    '   LEA    ', 0
INSTAND     DC.B    '   AND    ', 0   
INSTOR      DC.B    '   OR     ', 0
INSTNOT     DC.B    '   NOT', 0
INSTLSL     DC.B    '   LSL', 0
INSTLSR     DC.B    '   LSR', 0
INSTASL     DC.B    '   ASL', 0
INSTJMP     DC.B    '   JMP', 0
INSTASR     DC.B    '   ASR', 0
INSTROL     DC.B    '   ROL', 0
INSTROR     DC.B    '   ROR', 0
INSTBCC     DC.B    '   BCC    ', 0
INSTBLT     DC.B    '   BLT    ', 0
INSTBLE     DC.B    '   BLE    ', 0
INSTBEQ     DC.B    '   BEQ    ', 0
INSTBRA     DC.B    '   BRA    ', 0
INSTJSR     DC.B    '   JSR    ', 0
INSTBGT     DC.B    '   BGT    ', 0
INSTBCS     DC.B    '   BCS    ', 0
INSTNOP     DC.B    '   NOP    ', 0
OPMODEW     DC.B    '.W ', 0
OPMODEL     DC.B    '.L ', 0
OPMODEDCHAR DC.B    'D', 0
Comma       DC.B    ', ', 0
CHAR0       DC.B    '0', 0
CHAR1       DC.B    '1', 0
CHAR2       DC.B    '2', 0
CHAR3       DC.B    '3', 0
CHAR4       DC.B    '4', 0
CHAR5       DC.B    '5', 0
CHAR6       DC.B    '6', 0
CHAR7       DC.B    '7', 0
CHAR8       DC.B    '8', 0
CHAR9       DC.B    '9', 0
CHARA       DC.B    'A', 0
CHARB       DC.B    'B', 0
CHARC       DC.B    'C', 0
CHARD       DC.B    'D', 0
CHARE       DC.B    'E', 0
CHARF       DC.B    'F', 0
CHARIMD     DC.B    '#', 0
CHARTAB     DC.B    '    ', 0
CHARDOL     DC.B    '$', 0
INPUTSTART  DC.B    'Enter 8 digit starting address in hexadecimal: $',0
INPUTEND    DC.B    'Enter 8 digit ending address in hexadecimal: $',0
ENTER       DC.B    '   ', 0
_BADBUFFER   DC.B    'Bad Buffer    ', 0
STARTADDR   EQU $00000000
ENDADDR     EQU $00FFFFFF
BADLENGTH   EQU 0






    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
