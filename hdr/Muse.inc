.ifndef MUSE_H
.define MUSE_H

.scope Muse

.pushseg

.importzp MUSE_ZEROPAGE
.import MUSE_RAM

.segment "CODE"
	.import InitMuse
	.import UpdateMuse
	.import StartMusic
	.import StartSfx
	.import StopSfx
	.import IsSfxPlaying
	.import SetVolume
	.import SetFlags
	.import GetSyncEvent

.popseg

.endscope

.endif
