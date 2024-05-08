
; Assembler should use basic 6502 instructions
	processor 6502
	
; git dasm rainbow.asm -lrainbow.txt -f3 -v5 -orainbow.bin -Iincludes
; Include files for Atari 2600 constants and handy macro routines
	include "vcs.h"
	include "macro.h"
        org $f000

BGColor equ $81

Start   CLEAN_START ;from macro.h clears TIA and memory

NextFrame
	lda #2
        sta VBLANK
        sta VSYNC
        
        sta WSYNC
        sta WSYNC
        sta WSYNC
        lda #0
        sta VSYNC
        
        ldx #37 ; counts 37 scanlines
LVBlank
	sta WSYNC
        dex
        bne LVBlank
        
        lda #0
        sta VBLANK
        
        ldx #192 ; load into x 192 scanlines
        ldy BGColor ;load into y bgcolor variable from line 10
LVSCAN
	sty COLUBK ;store into y color
        sta WSYNC
        iny ; / increment the bgcolor
        dex ; decrement x (loaded with 192 initially)
        bne LVSCAN ; for loop
        
        ;overscan 30 lines
        lda #2
        sta VBLANK
        ldx #30
LVOVER
	sta WSYNC
        dex
        bne LVOVER
        
        dec BGColor ; change the background color stored in y
        jmp NextFrame ; return to line 14
        
        org $fffc
        .word Start
        .word Start
