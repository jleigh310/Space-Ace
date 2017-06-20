.scope RLE

.exportzp RLEReadPtr, RLEWritePtr
.export Unpack, UnpackToPPU

; -- ZEROPAGE -----------------------------------------------------------------
.segment "ZEROPAGE"
	RLEReadPtr:			.res 2
	RLEWritePtr:		.res 2
	RLETag:				.res 1
	RLEByte:			.res 1

; -- CODE ---------------------------------------------------------------------
.segment "CODE"
	.proc Unpack
		ldy #$00
		jsr ReadByte
		sta RLETag

		@1:	jsr ReadByte
	 		cmp RLETag
	 		beq @2
	 		jsr WriteByte
	 		sta RLEByte
	 		bne @1

	 	@2:	jsr ReadByte
	 		cmp #$00
	 		beq @4
	 		tax
	 		lda RLEByte

	 	@3:	jsr WriteByte
	 		dex
	 		bne @3
	 		beq @1

	 	@4:	rts
	.endproc

	.proc UnpackToPPU
		ldy #$00
		jsr ReadByte
		sta RLETag

		@1:	jsr ReadByte
	 		cmp RLETag
	 		beq @2
	 		sta $2007
	 		sta RLEByte
	 		bne @1

	 	@2:	jsr ReadByte
	 		cmp #$00
	 		beq @4
	 		tax
	 		lda RLEByte

	 	@3:	sta $2007
	 		dex
	 		bne @3
	 		beq @1

	 	@4:	rts
	.endproc

	.proc ReadByte
		lda (RLEReadPtr), y
		inc RLEReadPtr
		bne :+
		inc RLEReadPtr + 1
	 :	rts
	.endproc

	.proc WriteByte
		sta (RLEWritePtr), y
		inc RLEWritePtr
		bne :+
		inc RLEWritePtr + 1
	 :	rts
	.endproc

.endscope
