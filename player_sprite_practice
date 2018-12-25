
	processor 6502
	include "vcs.h"
	include "macro.h"

	org  $f000
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Sprites are a tricky beast on the 2600.
; You only have two of them.
; They are 8 bits wide and 1 bit high.
; There's no way to position the X or Y coordinate directly.
; To position X, you have to wait until the TIA clock hits a
; given X position and then write to a register to lock it in.
; To position Y, you simply wait until the desired scanline and
; set the bits of your sprite to a non-zero value.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Counter	equ $81
SpriteHeight equ 17
YPos    .byte

Start	CLEAN_START

NextFrame
; This macro efficiently gives us 1 + 3 lines of VSYNC
	VERTICAL_SYNC
	
        
        
; 36 lines of VBLANK
	ldx #36
LVBlank	sta WSYNC
	dex
	bne LVBlank


; number of scanlines remaining
	ldx #192
	lda #5
        sta YPos
        ldy #$11
	sty COLUBK	; set the background color
        ldy #0
        
ScanLoop
	sta WSYNC	; wait for next scanline- might need to move this?        
	txa
        sec
        sbc YPos
        cmp #SpriteHeight
        bcc InSprite
        lda #0 
InSprite
	tay
        lda Frame0,y ;loadfrom the bitmap
        sta GRP0
        
        lda ColorFrame0,y
        sta COLUP0
        
	;lda #0	
	dex
	bne ScanLoop
	
; Clear the background color and sprites before overscan
; (We don't need to use VBLANK neccessarily...)
	stx COLUBK

; 30 lines of overscan
	ldx #30
        

LVOver	sta WSYNC
	dex
	bne LVOver
	

	jmp NextFrame
	
Frame0
	.byte #0
        .byte #%00111100;--
        .byte #%01000010;--
        .byte #%11100111;--
        .byte #%11111111;--
        .byte #%10011001;--
        .byte #%01111110;--
        .byte #%11000011;--
        .byte #%10000001;--
;---End Graphics Data---


;---Color Data from https://alienbill.com/2600/playerpalnext.html--

ColorFrame0
	.byte #0;
        .byte #$AE;
        .byte #$AC;
        .byte #$A8;
        .byte #$AC;
        .byte #$8E;
        .byte #$8E;
        .byte #$98;
        .byte #$94;
;---End Color Data---
        
        
	org $fffc
	.word Start
	.word Start


