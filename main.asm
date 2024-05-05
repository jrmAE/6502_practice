; Assembler should use basic 6502 instructions
	processor 6502
	
; Include files for Atari 2600 constants and handy macro routines
	include "vcs.h"
	include "macro.h"
	
        seg Code
        org $f000
        
Start   sei
        cld
        ldx #$ff
        txs
              
        lda #0
        ldx #$ff
ZeroZP  sta $0,X
        dex
        bne ZeroZP
        
        lda #$29
        sta COLUBK
        
        jmp Start
        
        org $fffc
        .word Start
        .word Start
