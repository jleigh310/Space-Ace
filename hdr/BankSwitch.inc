.ifndef BANKSWITCH_H
.define BANKSWITCH_H

.import SwitchPrgBank16, SwitchChrBank8

.macro SwitchPrgBank BankNum, EntryPnt
	lda #>(EntryPnt - 1)
	pha
	lda #<(EntryPnt - 1)
	pha
	lda BankNum
	jmp SwitchPrgBank16
.endmacro

.endif
