;**************************************************************
;* This stationery serves as the framework for a              *
;* user application. For a more comprehensive program that    *
;* demonstrates the more advanced functionality of this       *
;* processor, please see the demonstration applications       *
;* located in the examples subdirectory of the                *
;* Freescale CodeWarrior for the HC12 Program directory       *
;**************************************************************
; Include derivative-specific definitions
            INCLUDE 'derivative.inc'

; export symbols
            XDEF Entry, _Startup, main
            ; we use export 'Entry' as symbol. This allows us to
            ; reference 'Entry' either in the linker .prm file
            ; or from C/C++ later on

            XREF __SEG_END_SSTACK      ; symbol defined by the linker for the end of the stack




; variable/data section
MY_EXTENDED_RAM: SECTION
; Insert here your data definition.
            ORG $1100
            
segments:   dc.b $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F, $77, $FF, $39, $3F, $79, $71

            ORG $1300
            
display:    ds.b 4

; code section
MyCode:     SECTION
main:
_Startup:
Entry:
            LDS  #__SEG_END_SSTACK     ; initialize the stack pointer
            CLI                     ; enable interrupts

            ; remap the RAM &amp; EEPROM here. See EB386.pdf
 ifdef _HCS12_SERIALMON
            ; set registers at $0000
            CLR   $11                  ; INITRG= $0
            ; set ram to end at $3fff
            LDAB  #$39
            STAB  $10                  ; INITRM= $39

            ; set eeprom to end at $0fff
            LDAA  #$9
            STAA  $12                  ; INITEE= $9
 endif

; Set up PORTB and PORTP for 7-segment display

            MOVB #$FF,DDRB            ; Anodes enabled
            MOVB #$0F,DDRP            ; Cathodes enabled
            ; Set up PTH for pushbuttons/toggle switches
            MOVB #$00,DDRH
            ; Set up PORTA for keypad
            MOVB #$0F,DDRA


EndlessLoop:
            LDY #segments
            LDX #display            
            ; Sample inputs
            LDAA PTH
            JSR GetNibbles            
            ; Visualize inputs
            MOVB A,Y,0,X
            MOVB B,Y,1,X            
            ; Push numerals to stack
            PSHA
            PSHB            
            ; Compute result conditionally
            JSR GetKeypad
            ; Check which opcode was entered, go to corresponding op
            CMPA #$00
            LBEQ Operation0
            CMPA #$01
            LBEQ Operation1
            CMPA #$02
            LBEQ Operation2
            CMPA #$03
            LBEQ Operation3
            CMPA #$04
            LBEQ Operation4
            CMPA #$05
            LBEQ Operation5
            CMPA #$06
            LBEQ Operation6
            CMPA #$07
            LBEQ Operation7
            CMPA #$08
            LBEQ Operation8
            CMPA #$09
            LBEQ Operation9
            CMPA #$0A
            LBEQ OperationA
            CMPA #$0B
            LBEQ OperationB
            CMPA #$0C
            LBEQ OperationC
            CMPA #$0D
            LBEQ OperationD
            CMPA #$0E
            LBEQ OperationE
            CMPA #$0F
            LBEQ OperationF
			
	; Show current display memory
	Display:
            JSR Drive7Seg            
            ; Undo pushes
            PULA
            PULB            
            ; Close loop
            JMP EndlessLoop

	; OperationCode $0: B + A
	Operation0:
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP            
            ; Compute 8-bit result, A + B
            ABA            
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display

	; OperationCode $1: B - A
	Operation1:
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP            
            ; Compute 8-bit result, (-A) + B
            NEGA
            ABA            
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
            
	; OperationCode $2: B * A
	Operation2:        
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP            
            ; Compute 8-bit result, multiply A * B
            MUL
            TBA            
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display

	; OperationCode $3: B AND A
	Operation3:
            ; Grab current display memory
            LDAA 1,SP            
            ; Compute 8-bit result, B AND A
            ANDA 0,SP            
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display            

	; OperationCode $4: B OR A
	Operation4:
            ; Grab current display memory
            LDAA 1,SP            
            ; Compute 8-bit result, B OR A
            ORAA 0,SP            
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
			
	; OperationCode $5: B XOR A
	Operation5:
            ; Grab current display memory
            LDAA 1,SP            
            ; Compute 8-bit result, B XOR A
            EORA 0,SP            
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
			
	; OperationCode $6: NOT B
	Operation6:
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP            
            ; Compute 8-bit result, NOT B
            TBA
            COMA           
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
            
	; OperationCode $7: SWAP(B,A)
	Operation7:
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP            
            ; Compute 8-bit result, swap B and A            
            MOVB B,Y,2,X
            MOVB A,Y,3,X
            JMP Display
            
	; OperationCode $8: B + 1
	Operation8:
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP            
            ; Compute 8-bit result, B + 1
            TBA
            ADDA #1            
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
            
	; OperationCode $9: B - 1
	Operation9:
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP            
            ; Compute 8-bit result, B - 1
            TBA
            SUBA #1            
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
            
	; OperationCode $A: LSR B
	OperationA:
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP            
            ; Compute 8-bit result, LSR B
            TBA
            LSRA            
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
            
	; OperationCode $B: LSL B
	OperationB:
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP            
            ; Compute 8-bit result, LSL B
            TBA
            LSLA            
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
            
	; OperationCode $C: ASR B
	OperationC:
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP            
            ; Compute 8-bit result, ASR B
            TBA
            ASRA
            NEGA                      ; Compute two's comp after ASR
            EORA #$F0                 ; Toggle the leading bits            
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
            
	; OperationCode $D: B > A
	OperationD:
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP            
            ; Compute 8-bit result, B > A
            CBA
            BLT GreaterThan           ; if B > A, return $1                
            LDAA #$00                 ; else, return $0            
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
		GreaterThan:
			LDAA #$01
            JSR GetNibbles            
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
            
	; OperationCode $E: B < A
	OperationE:
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP
            ; Compute 8-bit result, B < A
            CBA
            BGT LessThan              ; if B < A, return $1                
            LDAA #$00                 ; else, return $0
            JSR GetNibbles
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
		LessThan:
			LDAA #$01
            JSR GetNibbles
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
            
	; OperationCode $F: B = A
	OperationF:
            ; Grab current display memory
            LDAA 1,SP
            LDAB 0,SP
            ; Compute 8-bit result, B = A
            CBA
            BEQ Equal                 ; if B = A, return $1                
            LDAA #$00                 ; else, return $0
            JSR GetNibbles
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
		Equal:
			LDAA #$01
            JSR GetNibbles
            MOVB A,Y,2,X
            MOVB B,Y,3,X
            JMP Display
	; Get nibbles after each operation
	GetNibbles:
            TAB
            ANDA #$F0
            LSRA
            LSRA
            LSRA
            LSRA
            ANDB #$0F
            RTS
    
	; Drive 7-segment display
	Drive7Seg:
            MOVB #%00001110,PTP
            LDAA 0,X                  ; Place the Upper Nibble in A
            STAA PORTB
            LDAA #1
            JSR msDelay
            MOVB #%00001101,PTP
            LDAA 1,X                  ; Place the Lower Nibble in A
            STAA PORTB
            LDAA #1
            JSR msDelay
            MOVB #%00001011,PTP
            LDAA 2,X                  ; Place the Operation:H in A
            STAA PORTB
            LDAA #1
            JSR msDelay
            MOVB #%00000111,PTP       ; Place the Operation:L in A
            LDAA 3,X
            STAA PORTB
            LDAA #1
            JSR msDelay
            RTS

	; Generate delays (in milliseconds)
	msDelay:
		delay1:
			LDY #6000                 ; 6000 * 4 = 24000 cycles = <1ms @ 25MHz clock
		delay:
			DEY                       ; 1 cycle
            BNE delay                 ; 3 cycles
            DECA                      ; ~1ms passed, decrement ms counter
            BNE delay1                ; Delay again
            RTS
    
	; Get results from keypad input
	GetKeypad:
		Col3:
			MOVB #$08,PORTA           ; Enable rightmost column
            LDAA PORTA                ; Grab row data
            MOVB #$00,PORTA           ; Turn off column when unused
		checkK3:
			BITA #$10                 ; Was the first row active?
            BEQ checkK7               ; Skip if not active
            LDAA #3
            RTS
		checkK7:
			BITA #$20                 ; Was the second row active?
            BEQ checkK11
            LDAA #7
            RTS
		checkK11:
			BITA #$40                 ; Was the third row active?
            BEQ checkK15
            LDAA #11
            RTS
		checkK15:
			BITA #$80                 ; Was the fourth row active?
            BEQ Col2
            LDAA #15
            RTS
		Col2:
			MOVB #$04,PORTA           ; Enable second from right column
            LDAA PORTA                ; Grab row data
            MOVB #$00,PORTA           ; Turn off column when unused
		checkK2:
			BITA #$10                 ; Was the first row active?
            BEQ checkK6
            LDAA #2
            RTS
		checkK6:
			BITA #$20                 ; Was the second row active?
            BEQ checkK10
            LDAA #6
            RTS
		checkK10:
			BITA #$40                 ; Was the third row active?
            BEQ checkK14
            LDAA #10
            RTS
		checkK14:
			BITA #$80                 ; Was the fourth row active?
            BEQ Col1
            LDAA #14
            RTS
		Col1:
			MOVB #$02,PORTA           ; Enable second from left column
            LDAA PORTA                ; Grab row data
            MOVB #$00,PORTA           ; Turn off column when unused
		checkK1:
			BITA #$10                 ; Was the first row active?
            BEQ checkK5
            LDAA #1
            RTS
		checkK5:
			BITA #$20                 ; Was the second row active?
            BEQ checkK9
            LDAA #5
            RTS
		checkK9:
			BITA #$40                 ; Was the third row active?
            BEQ checkK13
            LDAA #9
            RTS        
		checkK13:
			BITA #$80                 ; Was the fourth row active?
            BEQ Col0
            LDAA #13
            RTS
		Col0:
			MOVB #$01,PORTA           ; Enable leftmost column
            LDAA PORTA                ; Grab row data
            MOVB #$00,PORTA           ; Turn off column when unused
		checkK0:
			BITA #$10                 ; Was the first row active?
            BEQ checkK4
            LDAA #0
            RTS
		checkK4:
			BITA #$20                 ; Was the second row active?
            BEQ checkK8
            LDAA #4
            RTS
		checkK8:
			BITA #$40                 ; Was the third row active?
            BEQ checkK12
            LDAA #8
            RTS
		checkK12:
			BITA #$80                 ; Was the fourth row active?
            BEQ default
            LDAA #12
            RTS
		default:
			LDAA #16                  ; Blank
            RTS 
