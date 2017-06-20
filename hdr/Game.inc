.ifndef GAME_H
.define GAME_H

NUM_16K_PRG_BANKS		= 2				; Number of 16K PRG ROM banks (must be even)
NUM_8K_CHR_BANKS		= 1				; Number of 8K CHR ROM banks
MAPPER					= 4				; MMC3
MIRRORING				= 0				; Horizontal mirroring (vertical scrolling)
PRG_RAM					= 1				; Battery saved PRG RAM

PLAYER_LIVES			= 3

; Game States
.enum GameStates
	_TITLE								; Title screen
	_MENU								; Menu screen
	_PLAY								; Game play
	_GAMEOVER							; Gave over
	_HIGHSCORE							; New high score
.endenum

; Player Definition
.struct Player
	_X					.byte			; Player 1 x-coordinate
	_Y					.byte			; Player 1 y-coordinate
	_Frame				.byte			; Player 1 animation frame
	_Lives				.byte			; Player 1 number of lives
	_Score				.byte 4			; Player 1 current score
.endstruct

.globalzp FrameCnt						; Current render frame counter
.globalzp NamTblPtr						; Pointer to current position in name table
.globalzp PPUCtl						; Saved settings in PPU Control register
.globalzp ScrollX						; Horizontal scroll between screens
.globalzp ScrollY						; Vertical scroll between screens
.globalzp GameState						; Current game state
.globalzp P1							; Player 1 data
.globalzp P2							; Player 2 data

.global NamTblWork						; Work memory for decompressing RLE name table

.macro RenderOff
	lda #$00
	sta $2000							; Disable NMI
	sta $2001							; Disable PPU rendering
.endmacro

.macro RenderOn
	lda PPUCtl
	sta $2000							; Enable NMI
	lda #$18							; Render sprites and background
	sta $2001							; Enable PPU rendering
.endmacro

.macro UpdateScrollPos
	lda ScrollX
	sta $2005
	lda ScrollY
	sta $2005
.endmacro

.endif
