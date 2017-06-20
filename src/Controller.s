.scope Ctrls

.exportzp CtrlBtns1, CtrlBtns1Last, CtrlBtns2, CtrlBtns1Last
.export FastRead, SafeRead

; -- ZEROPAGE -----------------------------------------------------------------
.segment "ZEROPAGE"
	CtrlBtns1:			.res 1
	CtrlBtns1Last:		.res 1
	CtrlBtns2:			.res 1
	CtrlBtns2Last:		.res 1

; -- CODE ---------------------------------------------------------------------
.segment "CODE"
	; Reads controllers once which could result in corrupt reads
	; Obliterates Accumulator
	.proc FastRead
		lda #$01						; Start reading controller states
		sta $4016
		lda #$00						; Stop reading controller states
		sta $4016
		
		lda #$80						; We want to read all 8 buttons
		sta CtrlBtns2
	 :	lda $4016						; Read next button state of controller 1
		and #$03
		cmp #$01						; Merge bits 0 and 1 into carry
		ror CtrlBtns1					; Shift carry bit into variable
		
		lda $4017						; Read next button state of controller 2
		and #$03
		cmp #$01						; Merge bits 0 and 1 into carry
		ror CtrlBtns2					; Shift carry bit into variable
		
		bcc :-							; Loop if we haven't ready all 8 buttons
		rts
	.endproc

	; Reads controllers twice and uses last known good reads if a corruption is detected
	; Obliterates Accumulator, X and Y registers
	.proc SafeRead
		lda CtrlBtns1
		sta CtrlBtns1Last
		lda CtrlBtns2
		sta CtrlBtns2Last
		
		jsr FastRead
		ldx CtrlBtns1
		ldy CtrlBtns2
		
		jsr FastRead
		cpx CtrlBtns1
		bne :+
		cpy CtrlBtns2
		bne :+
		rts

	 :	lda CtrlBtns1Last
		sta CtrlBtns1
		lda CtrlBtns2Last
		sta CtrlBtns2
		rts
	.endproc

.endscope
