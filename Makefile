# Paths
BUILD_BASE = build
SRC_BASE   = src
SRC_BOOT   = $(SRC_BASE)/boot
SRC_KERN   = $(SRC_BASE)/kernel
BUILD_BOOT = $(BUILD_BASE)/boot
BUILD_KERN = $(BUILD_BASE)/kernel
ISO_BASE   = $(BUILD_BOOT)
ISO_FILE   = c-os.iso
FLP_FILE   = c-os.flp

# Build targets
OBJECTS_BOOT = $(BUILD_BOOT)/bootsect.bin
OBJECTS_KERN_ASM = $(BUILD_KERN)/kernel-entry.o
OBJECTS_KERN_C   = $(BUILD_KERN)/kernel.o

# Compilation
CC      = /usr/local/i386elfgcc/bin/i386-elf-gcc
#CFLAGS  = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
#          -nostartfiles -nodefaultlibs -Wall -Wextra -Werror -c
CFLAGS  = -ffreestanding
LD      = /usr/local/i386elfgcc/bin/i386-elf-ld
LDFLAGS = -T link.ld -melf_i386
AS      = nasm
ASFLAGS_BOOT = -f bin
ASFLAGS_KERN = -f elf

# Emulators
BOCHS = ~/opt/bochs/bin/bochs
QEMU  = /usr/local/bin/qemu-system-x86_64

all: clean pre-build build-boot build-kern

dist: os.flp os.iso

build-boot: $(OBJECTS_BOOT)

build-kern: $(BUILD_KERN)/kernel.bin

pre-build:
	mkdir -p $(BUILD_KERN)
	mkdir -p $(BUILD_BOOT)

$(OBJECTS_BOOT): $(BUILD_BOOT)/%.bin : $(SRC_BOOT)/%.s
	$(AS) $(ASFLAGS_BOOT) $< -o $@

$(OBJECTS_KERN_ASM): $(BUILD_KERN)/%.o : $(SRC_KERN)/%.s
	$(AS) $(ASFLAGS_KERN) $< -o $@

$(OBJECTS_KERN_C): $(BUILD_KERN)/%.o : $(SRC_KERN)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

# WARNING! Order of dependencies is important
$(BUILD_KERN)/kernel.bin: $(OBJECTS_KERN_ASM) $(OBJECTS_KERN_C)
	$(LD) -o $@ -Ttext 0x1000 $^ --oformat binary

# WARNING! Order of dependencies is important
os.flp: $(OBJECTS_BOOT) $(BUILD_KERN)/kernel.bin
	cat $^ > $(BUILD_BASE)/$(FLP_FILE)
#	dd conv=notrunc if=$(BUILD_BOOT)/bootsect.bin of=$(BUILD_BASE)/$(FLP_FILE)

os.iso: build-boot build-kern
	mkisofs                              \
			-R                           \
			-b bootsect.bin              \
			-no-emul-boot                \
			-o $(BUILD_BASE)/$(ISO_FILE) \
			$(ISO_BASE)/
#			-A c-os                      \
#			-boot-load-size 4            \
#			-boot-info-table             \
#			-input-charset utf8          \
#			-quiet                       \

run-bochs: os.iso
	$(BOCHS) -f bochsrc.txt -q

run-qemu: os.flp
#	$(QEMU) -drive format=raw,file=$(BUILD_BASE)/$(FLP_FILE),index=0,if=floppy
	$(QEMU) -fda $(BUILD_BASE)/$(FLP_FILE)

clean:
	rm -rf build