
	processor 6502
	include "vcs.h"
	include "macro.h"

	org  $f000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	
; We're going to mess with the playfield registers, PF0, PF1 and PF2.
; Between them, they represent 20 bits of bitmap information
; which are replicated over 40 wide pixels for each scanline.
; By changing the registers before each scanline, we can draw bitmaps.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Counter	equ $81

Start	CLEAN_START

NextFrame
; This macro efficiently gives us 1 + 3 lines of VSYNC
	VERTICAL_SYNC
	
; 36 lines of VBLANK
	ldx #36
LVBlank	sta WSYNC
	dex
	bne LVBlank
; Disable VBLANK
        stx VBLANK
; Draw the 192 scanlines
	ldx #192
        lda #1          ; ctrlpf mirrors the playfield when
        		; the bit is set to on
        sta CTRLPF
lvscan
	sta WSYNC	; wait for next scanline
        lda #16         ; populate a bit from 16 through 128
	sta PF0		; set the PF0 playfield pattern register
 
 	;TODO
        ;cpx #$C0
  	bne .skip_pf1
        lda #1		; load into the a register the bit that
        		; represents which pixels to populate
	sta PF1		; set the PF1 playfield pattern register
        ;lda #16
	;sta PF2	; set the PF2 playfield pattern register
	;stx COLUBK	; set the background color
.skip_pf1
        ldy #$60	; load a blue as the forground color
        sty COLUPF	; store blue into the pf color register
        clc
	;adc #1		; increment A
	dex
	bne lvscan

; Reenable VBLANK for bottom (and top of next frame)
	lda #2
        sta VBLANK
; 30 lines of overscan
	ldx #30
LVOver	sta WSYNC
	dex
	bne LVOver
	
; Go back and do another frame
	inc Counter
	jmp NextFrame
	
	org $fffc
	.word Start
	.word Start

