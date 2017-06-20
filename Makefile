AS=..\..\cc65\bin\ca65.exe
AS_FLAGS=-I hdr

LD=..\..\cc65\bin\ld65.exe
LD_FLAGS=-C Game.cfg -m Game.map

EMU=..\fceux\fceux.exe

SRC=Game.s BankSwitch.s Controller.s Muse.s RLE.s Bank0.s
NES=SpaceAce.nes

OBJ=$(patsubst src/%.s, obj/%.o, $(addprefix src/, $(SRC)))

all: $(NES)

run: $(NES)
	@$(EMU) $(NES)

$(NES): $(OBJ)
	@echo   Linking      $@
	@$(LD) $(LD_FLAGS) $(OBJ) -o $@

$(OBJ): obj/%.o : src/%.s
	@echo   Assembling   $@
	@$(AS) $(AS_FLAGS) $< -o $@

clean:
	@del obj\*.o	2> nul
	@del $(NES)		2> nul
