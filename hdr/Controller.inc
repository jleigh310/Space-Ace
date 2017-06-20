.ifndef CONTROLLER_H
.define CONTROLLER_H

.scope Ctrls

.enum Btns
	_A				= $01
	_B				= $02
	_SELECT			= $04
	_START			= $08
	_UP				= $10
	_DOWN			= $20
	_LEFT			= $40
	_RIGHT			= $80
.endenum

.importzp CtrlBtns1						; Current player 1 button state
.importzp CtrlBtns1Last					; Previous player 1 button state
.importzp CtrlBtns2						; Current player 2 button state
.importzp CtrlBtns2Last					; Previous player 2 button state
.import FastRead						; Less accurate pull of button states
.import SafeRead						; Slower, accurate pull of button states

.endscope

.endif
