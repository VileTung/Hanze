
; ********* updated version 31-3-2011 *********
    list p=16f870
    #include "p16f870.inc"
    
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _HS_OSC & _WRT_ENABLE_ON & _LVP_OFF & _CPD_OFF

; ********** definitie van variabelen  **********
x0			EQU 0x20
x1			EQU 0x21
x2			EQU 0x22
x3			EQU 0x23
x4			EQU 0x24
x5			EQU 0x25
t0			EQU 0x26
t1			EQU 0x27
t2			EQU 0x28
t3			EQU 0x29
t4			EQU 0x2A
t5			EQU 0x2B
t6			EQU 0x2C
t7			EQU 0x2D
t8			EQU 0x2E
y			EQU 0x2F
new_time	EQU 0x30
teller		EQU 0x31
max_value	EQU 0x32
temp1		EQU 0x33
temp2		EQU 0x34
puls1H		EQU 0x35
puls1L		EQU 0x36
puls2H		EQU 0x37
puls2L		EQU 0x38
eerstekeer	EQU 0x39
slagtime	EQU 0x3A
ThartslagL  EQU 0x3B
ThartslagH  EQU 0x3C
DelenH      EQU 0x3D
DelenL		EQU 0x3E
TBPMH 		EQU 0x3F
TBPML		EQU 0x40
DH			EQU 0x41
DL  		EQU 0x42
H			EQu 0x43
L			EQU 0x44
I			EQU 0x45
RESH		EQU 0x46
RESL   		EQU 0x47
negative	EQU 0x48
BPM			EQU 0x49
BCD100		EQU	0X4A
BCD10		EQU	0x4B
BCD1		EQU	0x4C

AH	EQU 0x4D
AL	EQU 0x4E

BH	EQU 0x4F
BL	EQU 0x50

RL	EQU 0x51
RH	EQU 0x52

RLTemp	EQU 0x53

backup_W	EQU 0x74
backup_S	EQU 0x71


	org 0x00
    GOTO configureer

; **********  interruptroutine_timer1  **********	
  	org 0x04			; interrupt-vector is adres 0x04
    MOVWF backup_W		; sla inhoud W-register op
    SWAPF STATUS, 0		; een ingewikkelde manier om het status-registerW te krijgen
    MOVWF backup_S		; (zie ook blz. 100 uit de data-sheets).
    BCF STATUS, RP0		; selecteer bank 0
    MOVLW d'120'		; stand timer=15.536+5=15.541 (er zijn 5 extra cycli toegevoegd
    MOVWF TMR1L			; omdat het 5 cycli duurt voordat timer nieuwe waarde krijgt)
    MOVLW d'236'			; 15.541=60*256+181  dus TMR1H=60 en TMR1L=181
    MOVWF TMR1H			
    ;DECFSZ y, 1			; y = y - 1

    ;GOTO end_of_interrupt
    INCF new_time, 1	; new_time = 1
    ;MOVLW d'100'
    ;MOVWF y				; y = 100
    
    ; ************   tijdberekening   ********
som1ms:
   ;BCF STATUS,2
   INCF puls2L,1
   BTFSS STATUS,2
   GOTO end_of_interrupt
   INCF puls2H,1
    
end_of_interrupt:
    BCF PIR1, TMR1IF	; interrupt-flag op 0 (zie blz. 99 bijlage I)
    SWAPF backup_S, 0
    MOVWF STATUS		; herstel inhoud status-register
    MOVF backup_W, 0	; herstel inhoud W-register
    RETFIE				; terug naar het hoofprogramma

; **********  hoofdprogramma  **********	
configureer:
    CALL config_experimenteerset
    CALL config_timer1
    MOVLW 0x20
    MOVWF FSR			; FSR wijst naar adres 0x20 (x0)
    MOVLW d'13'
    MOVWF teller		; teller = 13
loop_clear:
    CLRF INDF			; geheugen-adres waar FSR wordt op 0 gezet
    INCF FSR, 1			; FSR wijst naar volgend adres
    DECFSZ teller, 1	; deze loop wordt 13 maal uitgevoerd,
    GOTO loop_clear		; dus adres 0x20 t/m 0x2C wordt op 0 gezet
    ;CALL display_AANTAL
    CALL display_TIJD
sensorloop1:			; loop eindigt als sensorsignaal = 1
    BTFSC new_time, 0	; als new_time=1 dan moet de tijd verhoogd worden
    CALL increase_time
    BTFSS PORTA, 1
    GOTO sensorloop1
    CALL mainloop
sensorloop2:			; loop eindigt als sensorsignaal = 0
    MOVF new_time, 1	; hiermee wordt het Zero-bit gezet (zie blz. 110 bijlage I)
    BTFSC new_time, 0	; als new_time=1 dan moet de tijd verhoogd worden
    CALL increase_time
    BTFSC PORTA, 1
    GOTO sensorloop2
    GOTO sensorloop1
    
mainloop:


   
   ;movlw 0x03
   ;movwf puls1H
   
   ;movlw 0xE8
   ;movwf puls1L

   ;BTFSC PORTA, 1
   call setPulse
   
   ;Als RA1 hoog is
   ;Schrijf puls aantal weg
   ;Reset Puls2
   
   call slagtimer
   call PulsReset
   
   clrf	RL
   clrf	RH

;Afblijven is 30.000!
   movlw 0x75
   movwf AH

   movlw 0x30 
   movwf AL

;Waardes van slagtimer
   movfw TBPMH
   movwf BH

   movfw TBPML
   movwf BL
   
   ;movlw 0x03
   ;movwf BH

   ;movlw 0xE8 
   ;movwf BL
   
;Deling begint
   call deling
   
   ; **********  BPM doorsturen naar pc  **********
   MOVFW BPM
   MOVWF PORTC
   
 ;Vergeet niet te clearen anders krijg je spookwaarden!  
   clrf BCD1
   clrf BCD10
   clrf BCD100
     
   call hartslag100
   
   call hartslag10
   
   call hartslag1
   
   call DisplayBCD

   ;goto mainloop
   return


; ********** configureren van de experimenteerset   **********	
config_experimenteerset:; zorgt ervoor dat de LCD-module geinitieerd wordt
    BSF STATUS, RP0		; registerbank 1 geselecteerd
    MOVLW 06h
    MOVWF ADCON1		; port A als digital IO-port (zie blz. 80 bijlage II)
    MOVLW b'00000010'	; alleen pin RA0 in read-mode (zie blz. 31 bijlage II)
    MOVWF TRISA
    CLRF TRISB			; port B staat in write-mode (zie blz. 29 bijlage II)
    MOVLW b'00000000'	; alleen pin RC0 in read-mode (zie blz. 31 bijlage II)
    MOVWF TRISC
    BCF STATUS, RP0		; registerbank 0 geselecteerd
    ;BSF PORTC, 3		; Disable input-buffer van keypad (zie keypad-module bijlage VI)
    BSF PORTA, 5		; Clock LCD-module op 1 zetten (zie  LCD-module bijlage VI)
    CALL init_display
    RETURN

; ********** LCD-module subroutines   **********	
init_display:
    CALL delay_15millis	; 15ms delay (noodzakelijk voor LCD-module)
    MOVLW b'00111011'	; function_set 1         (zie bijlage VII)
    CALL send_instruction
    MOVLW b'00111011'	; function_set 2         (zie bijlage VII)
    CALL send_instruction
    MOVLW b'00000110'	; display_mode_set       (zie bijlage VII)
    CALL send_instruction
    MOVLW b'00001100'	; display_cursor_control (zie bijlage VII)
    CALL send_instruction
    MOVLW b'00010111'	; display_cursor_shift   (zie bijlage VII)
    CALL send_instruction
    RETURN
delay_50micros:			; zorgt voor een vertraging van 249 cycli (50 microseconde)
    MOVLW d'81'
    MOVWF temp1			; temp1 = 81
loopmicros:				; deze loop wordt 81 maal aangeroepen (3 * 81 cycli)
    DECFSZ temp1, 1
    GOTO loopmicros
    RETURN

delay_15millis:			; zorgt voor een vertraging van circa 15 milliseconde
    MOVLW d'150'
    MOVWF temp2			; temp2 = 150
loopmillis:				; deze loop wordt 150 maal aangeroepen 
    CALL delay_50micros
    CALL delay_50micros
    DECFSZ temp2, 1
    GOTO loopmillis
    RETURN

send_number:			; tel 0x30 bij inhoud W-register op en stuur dit naar display
    ADDLW 0x30
send_character:			; inhoud W-register komt als karakter op display
    BSF PORTA, 3
    GOTO load_data
send_instruction:		; inhoud W-register gaat als instructie naar LCD-module
    BCF PORTA, 3
load_data:
    MOVWF  PORTB
    BCF PORTA, 5		; dit geeft een negatieve flank op E-bit van LCD-module
    CALL delay_50micros	; opdracht-verwerking door de LCD-module duurt max. 50micros
    BSF PORTA, 5
    RETURN

display_AANTAL:
    MOVLW 0x80			; eerste karakter op bovenste regel
    CALL send_instruction
    MOVLW 0x41			; de letter 'A'
    CALL send_character
    MOVLW 0x41			; de letter 'A'
    CALL send_character
    MOVLW 0x4E			; de letter 'N'
    CALL send_character
    MOVLW 0x54			; de letter 'T'
    CALL send_character
    MOVLW 0x41			; de letter 'A'
    CALL send_character
    MOVLW 0x4C			; de letter 'L'
    CALL send_character
    MOVLW 0x3D			; de letter '='
    CALL send_character
    GOTO display_x

display_TIJD:
    MOVLW 0xC0			; eerste karakter op onderste regel
    CALL send_instruction
    MOVLW 0x54			; de letter 'T'
    CALL send_character
    MOVLW 0x49			; de letter 'I'
    CALL send_character
    MOVLW 0x4A			; de letter 'J'
    CALL send_character
    MOVLW 0x44			; de letter 'D'
    CALL send_character
    MOVLW 0x3D			; de letter '='
    CALL send_character
    GOTO display_time

; ********** configureren van timer 1  **********	
config_timer1:
    MOVLW d'100'
    MOVWF y			; y = 100
    BSF T1CON, TMR1ON		; activeer timer 1	    (zie blz. 52 bijlage I)
    BSF INTCON, GIE			; enable globale interrupt  (zie blz. 99 bijlage I)
    BSF INTCON, PEIE		; enable interruptbit PEIE  (zie blz. 99 bijlage I)
    BSF STATUS, RP0			; geheugenbank 1 selecteren
    BSF PIE1, TMR1IE		; enable interrupt timer1 (zie blz. 99 bijlage I)
    BCF STATUS, RP0			; geheugenbank 0 selecteren
    RETURN

; ********** Verhogen van x  **********	
increase_x:
    MOVLW 0x0A
    MOVWF teller			; er zijn 6 xi-variabelen
    MOVLW 0x20
    MOVWF FSR				; indirecte adressering: FSR is gericht op adres 0x20 (x0)
loop_increasex:
    INCF INDF, 1			; de inhoud van xi wordt verhoogd  
    MOVF INDF, 0
    SUBLW d'9'				; controleren of xi > 9
    BTFSC STATUS, C
    GOTO display_x
    CLRF INDF				; xi = 0;
    INCF FSR, 1				; FSR is gericht op volgend geheugen-adres
    DECFSZ teller, 1
    GOTO loop_increasex
display_x:					; nu wordt de nieuwe x op display gezet
    MOVLW 0x87				; tiende karakter op bovenste regel
    CALL send_instruction
    MOVLW 0x25				; W = 0x25
    MOVWF FSR				; FSR wijst naar adres 0x25 (x5)
    MOVLW 0x06
    MOVWF teller			; teller = 6
loop_displayx:
    MOVF INDF, 0			; W is inhoud van adres waar FSR naar wijst
    CALL send_number		; W wordt als getal op display getoond
    DECF FSR, 1				; FSR wijst naar vorig adres
    DECFSZ teller, 1
    GOTO loop_displayx
    RETURN

; ********** Verhogen van tijd  **********	
increase_time:
    MOVLW 0x0A
    MOVWF teller			; er zijn 7 ti-variabelen
    MOVLW 0x26
    MOVWF FSR				; indirecte adressering: FSR is gericht op adres 0x26 (t0)
loop_increaset:
    INCF INDF, 1			; de inhoud van *FSR wordt verhoogd
    MOVLW 0x09				; max_value=9 (max_value is de max. waarde voor ti)
    MOVWF max_value			; deze wordt in eerste instantie op 9 gezet
    BTFSC teller, 0			; als teller=4 of teller=6 dan moet gelden: max_value=5
    GOTO test_maxvalue
    BTFSS teller, 2
    GOTO test_maxvalue
    MOVLW 0x05				; hier komt het programma alleen als teller=4 of teller=6
    MOVWF max_value			; max_value wordt op 5 gezet
test_maxvalue:
    MOVF INDF, 0
    SUBWF max_value, 0		; controleren of *FSR > max_value
    BTFSC STATUS, C
    GOTO display_time
    CLRF INDF				; *FSR = 0;
    INCF FSR, 1				; FSR is gericht op volgend geheugen-adres
    DECFSZ teller, 1
    GOTO loop_increaset
display_time:				; nu wordt de nieuwe tijd op display gezet
    MOVLW 0xC5				; zesde karakter op onderste regel
    CALL send_instruction
    MOVF t6, 0
    CALL send_number
    MOVF t5, 0
    CALL send_number
    MOVF t4, 0
    CALL send_number
    MOVLW 0x3A				; dubbele punt
    CALL send_character
    MOVF t3, 0
    CALL send_number
    MOVF t2, 0
    CALL send_number
    MOVLW 0x3A				; dubbele punt
    CALL send_character
    MOVF t1, 0
    CALL send_number
    MOVF t0, 0
    CALL send_number
    CLRF new_time			; new_time = 0
    RETURN
    
slagtimer:
   BCF STATUS,0
   RRF puls1H,1
   RRF puls1L,1
   MOVFW puls1L
   MOVWF TBPML
   MOVFW puls1H
   MOVWF TBPMH
return

PulsReset:
   MOVLW 0x00
   MOVWF puls2H
   MOVLW 0x02
   MOVWF puls2L
return

; **********  Deling  **********
deling:
	movf	BL,W
	subwf	AL,F		;AL-BL (STATUS,C=!BORROW)
	movf	BH,W
	btfss	STATUS,C	;skip if borrow=0 (C=1)
	addlw	01
	subwf	AH,F		;AH-BH	STATUS,C=!BRW

	btfsc STATUS,C
	goto skip1
	btfss STATUS,Z
	goto einde

skip1:

	movlw 0x01
	addwf RL,1

	btfsc STATUS,0
	incf	RH

skip2:

	btfsc	STATUS,Z	;skip if MSbyte<>zero
	movf	AL,F		;else, check LSbyte for zero.

	goto deling

einde:
	MOVFW RL
	MOVWF BPM
return

; **********  BCD berekening  **********
hartslag100:
	INCF BCD100,1
	MOVLW d'100'
	SUBWF BPM,1
	BTFSC STATUS,0
	GOTO hartslag100
	DECF BCD100,1
	MOVLW d'100'
	ADDWF BPM,1
return

hartslag10:
	INCF BCD10,1
	MOVLW d'10'
	SUBWF BPM,1
	BTFSC STATUS,0
	GOTO hartslag10
	DECF BCD10,1
	MOVLW d'10'
	ADDWF BPM,1
return

hartslag1:
	MOVFW BPM
	MOVWF BCD1
return
	
; **********  BCD weergeven  **********
DisplayBCD:
    MOVLW 0x85				; zesde karakter op onderste regel
    CALL send_instruction
    MOVF BCD100, 0			;honderdtal
    CALL send_number
    MOVF BCD10, 0			;tiental
    CALL send_number
    MOVF BCD1, 0			;enkeltal
    CALL send_number

Return	

setPulse:

   movfw puls2H
   movwf puls1H
   
   movfw puls2L
   movwf puls1L

return

    END

