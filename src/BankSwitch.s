.export SwitchPrgBank16, SwitchChrBank8

; -- CODE ---------------------------------------------------------------------
.segment "CODE"
	; A = 18K Bank number ($8000 = A, $A000 = A + 1)
	; Obliterates X register
	.proc SwitchPrgBank16
		asl								; Each 16K bank contains 2 * 8K chunks (bank = A << 1)
		tax								; Save bank number

		lda #$06
		sta $8000						; Select PRG bank $8000
		stx $8001						; Load bank number

		lda #$07
		sta $8000						; Select PRG bank $A000
		inx
		stx $8001						; Load bank number + 1

		rts
	.endproc

	; A = bank number (A << 3, $0000 = A, $0400 = A + 1, ... $1C00 = A + 7)
	; Obliterates X and Y registers
	.proc SwitchChrBank8
		asl								; Each 8K bank contains 8 * 1K chunks
		asl
		asl
		tay								; Save bank number

		ldx #$00
	 :	lda ChrSelArr, x				; Get CHR bank address from array
		sta $8000						; Select CHR bank

		tya								; Restore bank number
		clc
		adc ChrDatArr, x				; Add bank number to CHR chunk from array
		sta $8001

		inx								; Increase array index
		cpx #$06						; Loop until all banks are loaded
		bcc :-

		rts
	.endproc

; -- RODATA -------------------------------------------------------------------
.segment "RODATA"
	; CHR bank select arrays (MMC3 select and data registers)
	ChrSelArr:			.byte $00, $01, $02, $03, $04, $05
	ChrDatArr:			.byte $00, $02, $04, $05, $06, $07
