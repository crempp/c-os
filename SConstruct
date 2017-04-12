import os

OWROOT       = '~/opt/open-watcom-v2'
OWBINDIR     = '%s/build/bin' % OWROOT
OWSRCDIR     = '%s/bld' % OWROOT

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

cppbld = Builder(action ='$CC $CCFLAGS $SOURCES -fo=$TARGET')

lnkbld = Builder(action ='$LINK @linkerscript.lnk')

env_kernel = Environment(
    CC        = '%s/bwcc' % OWBINDIR,
    CCFLAGS   = '-0 -zl -s -od -zfp -zgp -wx -wo -ms',
    ASFLAGS   = '-f obj',
    LINK      = '%s/bwlink' % OWBINDIR,
    tools     = ['default', 'nasm'],
    BUILDERS  = {
        'Flp'   : flpbld,
        'Wcc'   : cppbld,
        'Wlink' : lnkbld
    }
)

env_boot_asm = Environment(
    ASFLAGS = '-f bin',
    tools   =['default', 'nasm']
)

# Build the bootloader objects
env_boot_asm.Object(BOOTSECT_BIN, BOOTSECT_SRC)

# Build the kernel objects
KERN_SOURCES = env_kernel.Glob('%s/*.[s]' % SRC_KERN)
kernel_s_objs = [
    env_kernel.Object(
        '%s/%s.o' % (BUILD_KERN, os.path.splitext(os.path.split(str(src))[1])[0]),
        src
    ) for src in KERN_SOURCES]
KERN_SOURCES = env_kernel.Glob('%s/*.[c]' % SRC_KERN)
kernel_c_objs = [
    env_kernel.Wcc(
        '%s/%s.o' % (BUILD_KERN, os.path.splitext(os.path.split(str(src))[1])[0]),
        src
    ) for src in KERN_SOURCES]

# Link the object files
env_kernel.Wlink(KERN_BIN, kernel_s_objs + kernel_c_objs)

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