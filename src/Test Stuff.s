.proc CalcNamTblPos
	lda #08						; Repeat 5 times
	sta Pos + 1
	
	cpy #30						; Y-coordinate must be 0-29
	bcc :+						; Check if y is less than 30
	ldy #27						; If not then set to 29
:	sty Pos						; Put y-coordinate into low byte
:	asl Pos						; Mutiply by 2
	rol Pos + 1					; Put carry into high byte
	bcc :-

	txa
	and #$1F					; X-coordinate can only be 0-31
	clc
	adc Pos						; Add current low byte to x-coordinate
	sta Pos						; Put sum into low byte
	rts
.endproc

.proc CalcNamTblPos2
	cpy #30						; Y-coordinate must be 0-29
	bcc :+						; Check if y is less than 30
	ldy #27						; If not then set to 29

:	sty Pos + 1					; Put y-coordinate into high byte
	.repeat 3
	lsr Pos + 1					; Shift high byte right by 1
	ror Pos						; Carry bit into low byte
	.endrepeat
	txa
	and #$1F					; X-coordinate can only be 0-31
	clc
	adc Pos						; Add current low byte to x-coordinate
	sta Pos						; Put sum into low byte	
	rts
.endproc

.proc Test
	lda Pos + 1
	clc
	adc #$20					; Name table 1 starts at $2000
	sta $2006					; Load high byte first
	lda Pos
	sta $2006					; Then low byte
	
	ldx #$00					; String index
	ldy #$00					; CHR to Text map index
:	lda StartText, x
	cmp #$00
	beq :+						; Quit at end of string

	inx
	sec
	sbc #$20					; Remove offset of ASCII so space starts at 0 instead of 32
	
	tay
	lda ChrTxtMap, y
	sta $2007
	jmp :-
	
:	rts
.endproc

LoadPalette:
	lda #<Palette				; Load Palette data address into pointer
	sta PalPtr
	lda #>Palette
	sta PalPtr + 1
	
	ldx #$3F					; Point to first palette table
	stx $2006					; Load high byte first
	ldx #$00
	stx $2006					; Then low byte
	
	ldy #$00
:	lda (PalPtr), y				; Load color into current palette table
	sta $2007
	iny							; Point to the next color in the array
	cpy #$20					; Have we reached 32 colors?
	bne :-						; Loop if we haven't reached 32 colors yet

LoadNameTable:	
	lda #<NameTable				; Load Name Table data address into pointer
	sta NamTblPtr
	lda #>NameTable
	sta NamTblPtr + 1
	
	ldx #$20					; Point to first name table
	stx $2006					; Load high byte first
	ldx #$00
	stx $2006					; Then low byte
	
	ldx #$04					; 4 iterations will give us 1024 bytes
	ldy #$00
:	lda (NamTblPtr), y
	sta $2007
	iny
	bne :-						; Iterate through $00-$FF in low byte
	inc NamTblPtr + 1
	dex
	bne :-						; Loop 4 times