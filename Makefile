# SPDX-License-Identifier: LGPL-3.0-or-later
# Copyright (C) 2022 Eric Herman <eric@freesa.org>

# https://www.gnu.org/software/make/manual/html_node/index.html
# Makefile cheat-sheet:
#
# $@ : target label
# $< : the first prerequisite after the colon
# $^ : all of the prerequisite files

# over-ride these with "make FOO=bar all" style syntax
TOOLCHAIN_BASEDIR ?= /usr
OPENOCD_SCRIPTS_DIR ?= /usr/share/openocd/scripts
OPENOCD ?= sudo openocd
FLASH_WRITE ?= st-flash write
FLASH_ERASE ?= st-flash erase
PROBE ?= st-info --probe

TARGET=blink

CC = $(TOOLCHAIN_BASEDIR)/bin/arm-none-eabi-gcc
AS = $(TOOLCHAIN_BASEDIR)/bin/arm-none-eabi-as
LD = $(TOOLCHAIN_BASEDIR)/bin/arm-none-eabi-ld
OBJCOPY = $(TOOLCHAIN_BASEDIR)/bin/arm-none-eabi-objcopy
OBJDUMP = $(TOOLCHAIN_BASEDIR)/bin/arm-none-eabi-objdump
SIZE = $(TOOLCHAIN_BASEDIR)/bin/arm-none-eabi-size
GDB = $(TOOLCHAIN_BASEDIR)/bin/arm-none-eabi-gdb
READELF = $(TOOLCHAIN_BASEDIR)/bin/arm-none-eabi-readelf

BLUEPILL_CFLAGS = -ffreestanding -nostartfiles \
		  -fno-common -ffunction-sections -fdata-sections \
		  -mthumb -mcpu=cortex-m3
NOISY_CFLAGS = -Wall -Wextra -Wimplicit-function-declaration -Wundef -Wshadow \
	       -Wredundant-decls -Wmissing-prototypes -Wstrict-prototypes
OUR_CFLAGS = -g -Os $(NOISY_CFLAGS) $(BLUEPILL_CFLAGS) $(CFLAGS)

# extracted from https://github.com/torvalds/linux/blob/master/scripts/Lindent
LINDENT=indent -npro -kr -i8 -ts8 -sob -l80 -ss -ncs -cp1 -il0
C_HEADERS=
C_SOURCES=$(TARGET).c

# targets
.PHONY: all
all: $(TARGET).bin

crt.o: crt.s
	$(AS) -o $@ $^

$(TARGET).o: $(C_HEADERS) $(C_SOURCES)
	$(CC) $(OUR_CFLAGS) -c -o $@ $^

$(TARGET).elf: linker.ld crt.o $(TARGET).o
	$(LD) -nostdlib -o $@ -T $^

$(TARGET).bin: $(TARGET).elf
	@echo
	$(SIZE) $<
	@echo
	$(OBJCOPY) -O binary $< $@

.PHONY:tidy
tidy: $(C_SOURCES)
	$(LINDENT) \
		-T size_t -T ssize_t \
		-T uint8_t -T int8_t \
		-T uint16_t -T int16_t \
		-T uint32_t -T int32_t \
		-T uint64_t -T int64_t \
		$(C_HEADERS) $(C_SOURCES)

.PHONY: dump
dump: $(TARGET).elf
	$(OBJDUMP) --full-contents $<

.PHONY: flash
flash: $(TARGET).bin
	$(FLASH_WRITE) $< 0x8000000

.PHONY: probe
probe:
	$(PROBE)

.PHONY: erase
erase:
	$(FLASH_ERASE)

.PHONY: ocd
ocd:
	$(OPENOCD) \
		-f $(OPENOCD_SCRIPTS_DIR)/interface/stlink-v2.cfg \
		-f $(OPENOCD_SCRIPTS_DIR)/target/stm32f1x.cfg

.PHONY: gdb
gdb: $(TARGET).elf
	@echo
	@echo "==================================================="
	@echo "assuming OpenOCD reported:"
	@echo "  Info : Listening on port 3333 for gdb connections"
	@echo "then, in gdb type:"
	@echo "==================================================="
	@echo "(gdb) target extended-remote :3333"
	@echo "==================================================="
	@echo
	$(GDB) $(TARGET).elf target extended-remote :4242

.PHONY: readelf
readelf: $(TARGET).elf
	$(READELF) --all $<

.PHONY: clean
clean:
	rm -fv *.o *.elf *.bin *.hex *~
