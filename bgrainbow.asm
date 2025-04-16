; S01E02 Generating a stable screen

; This example creates the proper VSYNC, and number of scanlines to generate a stable frame on NTSC
; televisions.

; This Episode on Youtube - https://youtu.be/WcRtIpvjKNI

; Become a Patron - https://patreon.com/8blit
; 8blit Merch - https://8blit.myspreadshop.com/
; Subscribe to 8Blit - https://www.youtube.com/8blit?sub_confirmation=1
; Follow on Facebook - https://www.facebook.com/8Blit
; Follow on Instagram - https://www.instagram.com/8blit
; Visit the Website - https://www.8blit.com 

; Email - 8blit0@gmail.com

	processor 6502
	include "includes/vcs.h"
	include "includes/macro.h"
	
BGColor = $9a
BLUE           = $9a         ;              define symbol for TIA color (NTSC)
YELLOW = $1C

	seg Code
	org $f000

reset:
	; clear RAM and all TIA registers
	ldx #0                   ;              load the value 0 into (x)
	lda #0                   ;              load the value 0 into (a)
clear:                       ;              define a label 
	sta 0,x                  ;              store value in (a) at address of 0 with offset (x)
	inx                      ;              inc (x) by 1. it will count to 255 then rollover to 0
	bne clear                ;              branch up to the 'clear' label if (x) != 0

	lda #BLUE                ;              load the value from the symbol 'blue' into (a)
	sta COLUBK               ;              store (a) into the TIA background color register

; the program starts here, or the completion of a frame returns here
startFrame:
	; start of new frame
	; start of vertical blank processing
	; The VBLANK register on the Atari 2600 is used to control the behavior of the system 
	; during the vertical blanking interval (VBI). The VBI occurs when the television's 
	; electron beam finishes drawing the visible screen and moves back to the top to begin 
	; drawing the next frame.

	lda #0                   ;              load the value 0 into (a)
	sta VBLANK               ;              store (a) into the TIA VBLANK register
							 ;              storing 0 into VBLANK says we are ready to draw the frame.
	lda #2                   ;              load the value 2 into (a). 
	sta VSYNC                ;              store (a) into TIA VSYNC register to turn on vsync

	; call the wait for sync register causes the cpu to halt until we reach the right edge of the screen
	; there are 3 scanlines of VERTICLE SYNC (VSYNC) before we reach a stable frame. on the 4th line, 
	; This is defined by the NTSC standard
	sta WSYNC                ;              write any value to TIA WSYNC register to wait for hsync
;---------------------------------------
	sta WSYNC
;---------------------------------------
	sta WSYNC                ;              we need 3 scanlines of VSYNC for a stable frame
;---------------------------------------
	lda #0
	sta VSYNC                ;              store 0 into TIA VSYNC register to turn off vsync

	; now generate 37 scanlines of vertical blank
	; this section is part of the ntsc standard as well. These 37 lines are periods when
	; the bema is to be turned off. This was used to prevent the beam from being visible
	; as it traced from the lower right to the upper left of the screen for the next frame
	ldx #0
verticalBlank:  
	; x starts at zero
	; skip to the end of the line
	; x = x + 1
	; compare x == 37 break, if it is
	sta WSYNC                ;              write any value to TIA WSYNC register to wait for hsync
;---------------------------------------
	inx
	cpx #37                  ;              compare the value in (x) to the immeadiate value of 37
	bne verticalBlank        ;              branch to 'verticalBlank' label if compare not equal

    ; we are now in the visible frame, which is 192 scan lines. 
	; each scan line has 228 color clocks
	; starting with a horizontal blank period of 68 color clocks,
	; followed by 160 color clocks.
	; visible frame starts on the 69th color clock, which starts 160 color clocks

	; generate 192 lines of playfield
	ldx #0

	; load dark green into the y register
	ldy #$C6
playfield:
	sty COLUBK ;set the background color to what is in Y
	; wait for the end of the frame
	; inx x by 1 (now its 38)
	; compare x == 192, break if it is
	sta WSYNC
;--------------------------------------
	inx
	cpx #162
	bne keepgreen
	ldy #$00
	sty COLUBK
keepgreen
	cpx #192                 ;              compare the value in (x) to the immeadiate value of 192
	bne playfield            ;              branch to 'drawField' label if compare not equal

	; end of playfield - turn on vertical blank
	; This loads the binary value 01000010 into the accumulator (A register).
    lda #%01000010

	; Storing this value in VBLANK is temporarily disabling the TV display (via bit 6) during 
	; the vertical blanking interval and possibly enabling certain CPU operations 
	; (via bit 1). This is typically part of a setup routine where the game logic is 
	; calculated or graphical data is prepared while the screen isn't actively being drawn.
    sta VBLANK

	; generate 30 scanlines of overscan
	; another part of the NTSC standard. This is the last part of the 262 scanlines,
	; before the frame resets
	ldx #0
overscan:        
    ; wait for the end of the line
	; we have reset x to 0 above
	; x = x + 1
	; compare x == 30, if it is break
	sta WSYNC
;---------------------------------------
	inx
	cpx #30                  ;              compare value in (x) to immeadiate value of 30
	bne overscan             ;              branch up to 'overscan' label, compare if not equal

	dec BGColor ; decrement the BGColor so that the colors animate down
	; x == 30, jmp to the startFrame label
	jmp startFrame           ;              frame completed, branch up to the 'startFrame' label
;------------------------------------------------

; By using org $fffa, the programmer ensures the interrupt vector table is placed at the correct location
; Even though the Atari 2600's 6507 processor doesn't use IRQ or NMI due to its reduced pin count, the 
; assembler requires the interrupt vectors for compatibility with the standard 6502 architecture.
	org $fffa                ;              set origin to last 6 bytes of 4k rom
	
; Even though the Atari 2600's 6507 processor does not use IRQs or NMIs due to its 
; reduced pin count, the assembler still expects the interrupt vectors to adhere 
; to the standard order for compatibility with the 6502's architecture.
interruptVectors:
	.word reset              ;              Defines where the processor should start execution after a reset (e.g., when the system is powered on or reset). This is often the first line of code in the application.
	.word reset              ;              irq
	.word reset              ;              nmi
	

