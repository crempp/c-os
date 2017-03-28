import os

BUILD_BASE   = 'build'
SRC_BASE     = 'src'
SRC_BOOT     = '%s/boot'   % SRC_BASE
SRC_KERN     = '%s/kernel' % SRC_BASE
BUILD_BOOT   = '%s/boot'   % BUILD_BASE
BUILD_KERN   = '%s/kernel' % BUILD_BASE
BOOTSECT_SRC = '%s/bootsect.s'   % SRC_BOOT
BOOTSECT_BIN = '%s/bootsect.bin' % BUILD_BOOT
KERN_BIN     = '%s/kernel.bin' % BUILD_KERN
ISO_FILE     = 'c-os.iso'
FLP_FILE     = 'c-os.flp'

# Emulators
BOCHS = '~/opt/bochs/bin/bochs'
QEMU  = '/usr/local/bin/qemu-system-x86_64'

# Pre-build
# TODO
# mkdir -p $(BUILD_KERN)
# mkdir -p $(BUILD_BOOT)

flpbld = Builder(action     ='cat $SOURCES > $TARGET',
                 suffix     = '.flp',
                 src_suffix = '.bin')

env_kernel = Environment(
    CC        = '/usr/local/i386elfgcc/bin/i386-elf-gcc',
    CCFLAGS   = '-ffreestanding',
    ASFLAGS   = '-f elf',
    LINK      = '/usr/local/i386elfgcc/bin/i386-elf-ld',
    LIBPREFIX = '',
    LIBSUFFIX = '.bin',
    LINKFLAGS = '-Ttext 0x1000 --oformat binary',
    tools     = ['default', 'gcc', 'nasm'],
    BUILDERS  = {'Flp' : flpbld}
)

env_boot_asm = Environment(
    ASFLAGS = '-f bin',
    tools   =['default', 'nasm']
)

# Build the bootloader objects
env_boot_asm.Object(BOOTSECT_BIN, BOOTSECT_SRC)

# Build the kernel objects
KERN_SOURCES = env_kernel.Glob('%s/*.[cs]' % SRC_KERN)
kernel_objs = [
    env_kernel.Object(
        '%s/%s.o' % (BUILD_KERN, os.path.splitext(os.path.split(str(src))[1])[0]),
        src
    ) for src in KERN_SOURCES]

# Link the object files
env_kernel.Program(KERN_BIN, kernel_objs)

# Build floppy disk image
env_kernel.Flp('%s/%s' % (BUILD_BASE, FLP_FILE),
               [BOOTSECT_BIN, KERN_BIN])

# Build ISO image
# TODO
#         mkisofs        \
#                 -R     \
#                 -b bootsect.bin \
#                 -no-emul-boot \
#                 -o $(BUILD_BASE)/$(ISO_FILE) \
#                 $(ISO_BASE)/
#                 # -A c-os                      \
#                 # -boot-load-size 4            \
#                 # -boot-info-table             \
#                 # -input-charset utf8          \
#                 # -quiet                       \


# Run qemu
# Command([], [], "%s -f bochsrc.txt -q" % BOCHS)

# Run bochs
# TODO
# $(QEMU) -fda $(BUILD_BASE)/$(FLP_FILE)
# ~/opt/bochs/bin/bochs -f bochsrc.txt -q