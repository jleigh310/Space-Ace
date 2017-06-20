.include "BankSwitch.inc"
.include "Controller.inc"
.include "Game.inc"
.include "Muse.inc"
.include "RLE.inc"

.import snd_data
.export MainLoop

.segment "BSS"
	CurSong:				.res 1

; -- CODE ---------------------------------------------------------------------
.segment "CODE00"
	.proc MainLoop
		RenderOff						; Turn off PPU rendering

		LoadPalette:
			lda #$3F					; Point to first palette table
			sta $2006					; Load high byte first
			lda #$00
			sta $2006					; Then low byte
			
			ldx #$00
		 :	lda DefaultPal, x			; Load default background and sprite palettes
			sta $2007
			inx							; Point to the next color in the array
			cpx #$20					; Have we reached 32 colors?
			bcc :-						; Loop if we haven't reached 32 colors yet

		LoadNameTable:
			lda #$20					; Point to first name table
			sta $2006					; Load high byte first
			lda #$00
			sta $2006					; Then low byte

			lda #<TitleNamTbl			; Load Name Table data address into pointer
			sta RLE::RLEReadPtr
			lda #>TitleNamTbl
			sta RLE::RLEReadPtr+1

			jsr RLE::UnpackToPPU		; Decompress name table and write directly to PPU

		UpdateScrollPos					; Fix scroll position
		RenderOn						; Turn on PPU rendering

		lda #<snd_data
		ldx #>snd_data
		jsr Muse::InitMuse				; Initialize MUSE audio engine

		lda #$38						; NTSC, global volume doesn't apply to sfx
		jsr Muse::SetFlags				; Set initial MUSE flags

		lda #$00
		sta CurSong
		jsr Muse::StartMusic			; Play song 0
		
		@Loop:
			lda FrameCnt				; Wait for vertical blank
		 :	cmp FrameCnt
			beq :-						; Loop if frame counter has not changed
			
			; We are just testing the controller inputs. This will be replaced with procedures
			; that move the player sprites.
			
			jsr Ctrls::SafeRead

			lda Ctrls::CtrlBtns1		; Check is Player 1 presses UP
			and #Ctrls::Btns::_UP
			beq :+
			lda #$00					; We want to check is sound #0 is active when we check it
			ldx #$00					; We want to play sound #0 if it is not active
			jmp @CheckIsPlaying

		 :	lda Ctrls::CtrlBtns1		; Check is Player 1 presses RIGHT
			and #Ctrls::Btns::_RIGHT
			beq :+
			lda #$01
			ldx #$01
			jmp @CheckIsPlaying

		 :	lda Ctrls::CtrlBtns1		; Check is Player 1 presses DOWN
			and #Ctrls::Btns::_DOWN
			beq :+
			lda #$02
			ldx #$02
			jmp @CheckIsPlaying

		 :	lda Ctrls::CtrlBtns1		; Check is Player 1 presses LEFT
			and #Ctrls::Btns::_LEFT
			beq :+
			lda #$03
			ldx #$03
			jmp @CheckIsPlaying

		 :	lda Ctrls::CtrlBtns1
			and #Ctrls::Btns::_SELECT	; Check is Player 1 presses SELECT
			beq @UpdateAudio

			and Ctrls::CtrlBtns1Last	; Select cannot be held down
			bne @UpdateAudio

			inc CurSong					; Move to next song
			lda CurSong
			cmp #$04					; Loop back to 0 as there are only 4 songs
			bne :+
			lda #$00
			sta CurSong

		 :	jsr Muse::StartMusic		; Start music if it has not already started
			jmp @UpdateAudio

			@CheckIsPlaying:
				jsr Muse::IsSfxPlaying	; Check is sound stored in A is active
				bne @UpdateAudio		; If it is, do not start it again
				txa						; If it is not then move the sound to play from X to A
		 	 	jsr Muse::StartSfx		; Play sound stored in A

		 	@UpdateAudio:
				jsr Muse::UpdateMuse	; Keep playing current music and sound effects
			
			jmp @Loop
	.endproc

	; We use a little more memory storing each digit as a byte but it's faster
	; and uses less code than converting
	.proc IncP1Score
		ldx #$03						; Start with last digit (byte) of score
	 :	lda #$0A						; Each digit must be less than 10
		inc P1+Player::_Score, x		; Add 1 to current digit referenced by x
		cmp P1+Player::_Score, x		; Check if current digit has reach 10
		bne :+							; Return if it has not reached 10

		eor P1+Player::_Score, x		; Clear current digit
		sta P1+Player::_Score, x
		dex								; Move one digit to the right
		jmp :-							; Loop to carry the 1

	 :	rts
	.endproc


; -- RODATA -------------------------------------------------------------------
.segment "RODATA00"
	DefaultPal:			.incbin "gfx\DefaultBkg.pal"
						.incbin "gfx\DefaultSpr.pal"
	TitleNamTbl:		.incbin "gfx\Title.rle"
	Star1NamTbl:		.incbin "gfx\Star_1.rle"
	Star2NamTbl:		.incbin "gfx\Star_2.rle"
