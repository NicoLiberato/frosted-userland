# this makefile is to compile apps as a separate bFLT executable
#
#
-include ../kconfig/.config
-include ../config.mk

# PATH CONFIG
FROSTED_PATH=..
PREFIX:=$(PWD)/build

# APPLICATION CONFIG
APPS-y += init_bflt.o fresh.o binutils.o stubs.o

# TOOLCHAIN CONFIG
CROSS_COMPILE?=arm-frosted-eabi-
CC:=$(CROSS_COMPILE)gcc
AS:=$(CROSS_COMPILE)as
AR:=$(CROSS_COMPILE)ar

# COMPILER FLAGS -- Includes
CFLAGS+=-I$(FROSTED_PATH)/include -I$(FROSTED_PATH)/include/libc -I$(FROSTED_PATH)/newlib/build/lib/arm-none-eabi/include
# COMPILER FLAGS -- Target CPU
CFLAGS+=-mthumb -mlittle-endian -mthumb-interwork -ffunction-sections -mcpu=cortex-m3 
CFLAGS+=-DCORE_M3 -D__frosted__
# COMPILER FLAGS -- No gcc libraries
CFLAGS+=-nostartfiles
# COMPILER FLAGS -- GOT/PIC
CFLAGS+=-fPIC -mlong-calls -fno-common -msingle-pic-base -mno-pic-data-is-text-relative
# Debugging
CFLAGS+=-ggdb

# LINKER FLAGS
#LDFLAGS:=-L$(FROSTED_PATH)/build/lib -L$(FROSTED_PATH)/newlib/build/lib/arm-none-eabi/lib -gc-sections
LDFLAGS:=-L$(FROSTED_PATH)/build/lib 
#--specs=nano.specs
LDFLAGS+=-fPIC -mlong-calls -fno-common -Wl,-elf2flt -lgloss -lg -lgloss

all: apps.img
	cp apps.img $(FROSTED_PATH)/


apps.img: init idling
	$(FROSTED_PATH)/tools/xipfstool $@ $^


init: init_bflt.o
	$(CC) -o $@  $^ -Wl,-Map,apps.map -Telf2flt.ld  $(LDFLAGS) $(CFLAGS) $(EXTRA_CFLAGS) -Wl,--build-id=none

fresh: fresh.o
	$(CC) -o $@  $^ -Wl,-Map,apps.map -Telf2flt.ld  $(LDFLAGS) $(CFLAGS) $(EXTRA_CFLAGS) -Wl,--build-id=none

idling: idling.o
	$(CC) -o $@  $^ -Wl,-Map,apps.map -Telf2flt.ld  $(LDFLAGS) $(CFLAGS) $(EXTRA_CFLAGS) -Wl,--build-id=none

clean:
	@rm -f *.img
	@rm -f *.o
	@rm -f *.gdb