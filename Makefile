# Paths
BUILD_BASE = build
SRC_BASE   = src
SRC_BOOT   = $(SRC_BASE)/boot
BUILD_BOOT = $(BUILD_BASE)/boot
BUILD_KERN = $(BUILD_BASE)/kernel
ISO_FILE   = c-os.iso
FLP_FILE   = c-os.flp

# Build targets
OBJECTS_BOOT = $(BUILD_BOOT)/bootsect.bin
OBJECTS_KERN = $(BUILD_KERN)/foo.o

# Compilation
CC      = /usr/local/i386elfgcc/bin/i386-elf-gcc
CFLAGS  = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
          -nostartfiles -nodefaultlibs -Wall -Wextra -Werror -c
LD      = /usr/local/i386elfgcc/bin/i386-elf-ld
LDFLAGS = -T link.ld -melf_i386
AS      = nasm
ASFLAGS = -f bin

# Emulators
BOCHS = ~/opt/bochs/bin/bochs
QEMU  = /usr/local/bin/qemu-system-x86_64

all: pre-build build-boot build-kern

dist: clean pre-build os.flp os.iso

build-boot: $(OBJECTS_BOOT)

#build-kern: $(OBJECTS_KERN)

pre-build:
	mkdir -p $(BUILD_KERN)
	mkdir -p $(BUILD_BOOT)

$(OBJECTS_BOOT): $(BUILD_BOOT)/%.bin : $(SRC_BOOT)/%.s
	$(AS) $(ASFLAGS) $< -o $@

os.flp: build-boot
	dd conv=notrunc if=$(BUILD_BOOT)/bootsect.bin of=$(BUILD_BASE)/$(FLP_FILE)

os.iso: build-boot
	mkisofs                              \
			-R                           \
			-A c-os                      \
			-b c-os.flp                  \
			-no-emul-boot                \
			-boot-load-size 4            \
			-boot-info-table             \
			-o $(BUILD_BASE)/$(ISO_FILE) \
			$(BUILD_BASE)/
#			-input-charset utf8          \
#			-quiet                       \

run-bochs: os.iso
	$(BOCHS) -f bochsrc.txt -q

run-qemu: os.flp
	$(QEMU) -drive format=raw,file=$(BUILD_BASE)/$(FLP_FILE),index=0,if=floppy

clean:
	rm -rf build
