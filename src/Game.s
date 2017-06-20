.include "BankSwitch.inc"
.include "Game.inc"
.include "Muse.inc"

.import MainLoop
.export snd_data

; -- HEADER -------------------------------------------------------------------
.segment "HEADER"
	.byte "NES", $1A
	.byte NUM_16K_PRG_BANKS
	.byte NUM_8K_CHR_BANKS
	.byte (MAPPER & $0F) << 4 | PRG_RAM << 1 | MIRRORING

; -- ZEROPAGE -----------------------------------------------------------------
.segment "ZEROPAGE"
	FrameCnt:			.res 1			; NMI counter
	NamTblPtr:			.res 2

	PPUCtl:				.res 1			; Current PPU control flags for rendering on
	ScrollX:			.res 1			; Current scroll x-position
	ScrollY:			.res 1			; Current scroll y-position

	GameState:			.res 1			; Current game state
	PlayerWon:			.res 1			; Player who won

	P1:					.tag Player		; Player 1 struct
	P2:					.tag Player		; Player 2 struct

; -- BSS ----------------------------------------------------------------------
.segment "BSS"

; -- DATA ---------------------------------------------------------------------
.segment "DATA"
	HighScore:			.res 4			; Saved high score
	Initials:			.res 3			; Saved high score initials
	NamTblWork:			.res 1024		; Temp storage for decompressed name table

.segment "CODE"
	.proc Reset
		RenderOff
		
	 :	bit $2002						; Wait for vertical blank
		bpl :-							; Loop if bit 7 is on

		ClearMem:
			ldx #$00
		 :	lda #$00					; Store the value zero
			sta $0000, x				; into base + offset of x
			sta $0100, x
			sta $0300, x
			sta $0400, x
			sta $0500, x
			sta $0600, x
			sta $0700, x
			lda #$FE					; Move all sprites off screen to prevent garbage
			sta $0200, x				; OAM (Object attribute memory)
			inx
			bne :-						; Loop 256 times ($00 - $FF)

		InitMapper:
			lda #$00
			sta $A000					; Vertical mapping
			lda #$80
			sta $A001					; Enable PRG RAM

			lda #$00
			jsr SwitchPrgBank16			; Set program bank to #0

			lda #$00
			jsr SwitchChrBank8			; Set character bank to #0

		InitAPU:
			lda #$00
			ldx #$00					; Clear APU registers
		 :	sta $4000, x
			inx
			cpx #$14
			bne :-						; Loop while x < 20
			
			lda #$00
			sta $4015					; Disable APU DMC
			lda #$40
			sta $4017					; Disable APU Frame Counter IRQ

		 :	bit $2002					; Wait for vertical blank
			bpl :-						; Loop if bit 7 is on

		InitPPU:
			lda #$00
			sta ScrollX
			sta ScrollY

			lda #$A0					; SprChr=$1000, BkgChr=$0000, NamTbl=$2000
			sta PPUCtl

		InitVariables:
			lda #$00
			sta GameState				; Initial game state
			
			sta P1+Player::_Frame		
			sta P1+Player::_Score
			sta P2+Player::_Frame
			sta P2+Player::_Score

			lda #PLAYER_LIVES
			sta P1+Player::_Lives
			sta P2+Player::_Lives

			lda #$7F					; Players start centered horizontally
			sta P1+Player::_X
			sta P2+Player::_X

			lda #$E0
			sta P1+Player::_Y			; Player 1 on the bottom

			lda #$10
			sta P2+Player::_Y			; Player 2 on the top
			
		cli								; Enable interrupts (for MMC3 IRQs)
		jmp MainLoop
	.endproc

	.proc NMI
		pha								; Save A, X, Y, and flags
		txa
		pha
		tya
		pha
		php

		inc FrameCnt

		plp								; Restore flags, Y, X, and A
		pla
		tay
		pla
		tax
		pla
		rti
	.endproc

	.proc IRQ
		rti
	.endproc

; -- RODATA -------------------------------------------------------------------
.segment "RODATA"
	; ASCII to CHR tile mapping
	; ASCII value indexes the array while each value in the array indexes the CHR map
	; Subtract the ASCII offset of $20 from the index before referencing this array
	ChrTxtMap:			.byte $00, $34, $00, $39, $38, $3A, $00, $00, $00, $00, $3E, $3B, $37, $3C, $36, $3D
						; ' ', '!', '"', '#', '$', '%', '&', ''', '(', ')', '*', '+', ',', '-', '.', '/'
						.byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $00, $00, $00, $3F, $00, $35
						; '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?'
						.byte $00, $1A, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $27, $28
						; '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'
						.byte $29, $2A, $2B, $2C, $2D, $2E, $2F, $30, $31, $32, $33
						; 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'

	MUSESndData:		.include "snd/snd-data.s"
	MUSESndMusic:		.include "snd/snd-data-jabadaa.s"
						.include "snd/snd-data-ripulimiehenkosto.s"
						.include "snd/snd-data-cheetah.s"
						.include "snd/snd-data-cursedjungle.s"
	MUSESndSfx:			.include "snd/snd-data-sfx-ding.s"
						.include "snd/snd-data-sfx-metal.s"
						.include "snd/snd-data-sfx-tri.s"
						.include "snd/snd-data-sfx-paskasireeni.s"

; -- DPCM ---------------------------------------------------------------------
.segment "DPCM"
	.include "snd/snd-data-dpcm.s"

; -- STUB ---------------------------------------------------------------------
.segment "STUB"
	; The reset stub needs to be in the last bank just in case the mapper isn't set up properly at reset
	.proc ResetStub
		sei								; Disable interrupts
		cld								; Disable decimal mode
	
		ldx #$FF
		txs								; Set stack pointer to $01FF
	
		lda #$00						; Set up mapper before jumping out of last bank
		sta $8000						; $C000 fixed as second to last bank
	
		jmp Reset
	.endproc
	
; -- VECTORS ------------------------------------------------------------------
.segment "VECTORS"
	.addr NMI, ResetStub, IRQ

; -- TILES --------------------------------------------------------------------
.segment "TILE00"
	.incbin "gfx\Default.chr"
