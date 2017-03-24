#OBJECTS = build/kernel/loader.o build/kernel/kmain.o
OBJECTS = build/kernel/loader.o
CC      = /usr/local/i386elfgcc/bin/i386-elf-gcc
CFLAGS  = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
          -nostartfiles -nodefaultlibs -Wall -Wextra -Werror -c
LD      = /usr/local/i386elfgcc/bin/i386-elf-ld
#LDFLAGS = -T link.ld -Wl,-melf_i386
LDFLAGS = -T link.ld -melf_i386
AS      = nasm
#ASFLAGS = -f elf
ASFLAGS = -f elf32

BOCHS = ~/opt/bochs/bin/bochs

BUILD_BASE = build
ISO_BASE = $(BUILD_BASE)/iso

KERNEL_ELF_DST = $(ISO_BASE)/boot/kernel.elf
GRUB_SRC = grub/stage2_eltorito
GRUB_DST = boot/grub/stage2_eltorito
ISO_DST  = $(ISO_BASE)
ISO_FILE = c-os.iso
MENU_SRC = menu.lst
MENU_DST = boot/grub/menu.lst

all: pre-build kernel.elf

pre-build:
	mkdir -p build/kernel
	mkdir -p build/iso/boot/grub

kernel.elf: $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $(KERNEL_ELF_DST)

os.iso: kernel.elf
	cp $(GRUB_SRC) $(ISO_BASE)/$(GRUB_DST)
	cp $(MENU_SRC) $(ISO_BASE)/$(MENU_DST)
	mkisofs -R                  \
			-b $(GRUB_DST)      \
			-no-emul-boot       \
			-boot-load-size 4   \
			-A c-os             \
			-input-charset utf8 \
			-quiet              \
			-boot-info-table    \
			-o $(BUILD_BASE)/$(ISO_FILE) \
			$(ISO_DST)

run: os.iso
	$(BOCHS) -f bochsrc.txt -q

#%.o: %.c
#	$(CC) $(CFLAGS)  $< -o $@

$(OBJECTS): build/kernel/%.o : %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -rf build
