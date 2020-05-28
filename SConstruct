import os

OWBINDIR     = '~/opt/bin'

BUILD_BASE   = 'build'
SRC_BASE     = 'src'
SRC_BOOT     = '%s/boot'    % SRC_BASE
SRC_KERNEL   = '%s/kernel'  % SRC_BASE
SRC_DRIVER   = '%s/drivers' % SRC_BASE
BUILD_BOOT   = '%s/boot'    % BUILD_BASE
BUILD_KERN   = '%s/kernel'  % BUILD_BASE
BOOTSECT_SRC = '%s/bootsect.s'   % SRC_BOOT
BOOTSECT_BIN = '%s/bootsect.bin' % BUILD_BOOT
KERN_BIN     = '%s/kernel.bin'   % BUILD_KERN
DISKDUMP_PATH = '/usr/local/opt/pcjs/modules/diskdump/bin/diskdump'
PCJS_PATH    = 'pcjs'
ISO_FILE     = 'c-os.iso'
FLP_INT_FILE = 'c-os.intermediate.flp'
FLP_FILE     = 'c-os.flp'
JSON_FILE    = "c-os.json"
DISK_SIZE    = 163839 # 163840 - 1

# Emulators
BOCHS = '~/opt/bochs/bin/bochs'
QEMU  = '/usr/local/bin/qemu-system-x86_64'

lnkbld = Builder(
    action = '$LINK @linkerscript.lnk')

flpbld = Builder(
    action     ='cat $SOURCES > $TARGET',
    suffix     = '.intermediate.flp',
    src_suffix = '.bin')

flppad = Builder(
    action     = 'cp $SOURCE $TARGET && dd if=/dev/zero of=$TARGET bs=1 count=1 seek=%s' % DISK_SIZE,
    suffix     = '.flp',
    src_suffix = '.intermediate.flp')

flpjson = Builder(
    action     = 'node $DISKDUMP_PATH --debug --disk=$SOURCES --format=json --output=$TARGET',
    suffix     = '.json',
    src_suffix = '.flp'
)

isopack = Builder(action='$MKISOFS $ISOFLAGS -b bootsect.bin -o $(BUILD_BASE)/$(ISO_FILE) $(ISO_BASE)/')

env_kernel = Environment(
    ENV       = os.environ,
    ASFLAGS   = '-f obj -i./src/lib/',
    LINK      = 'bwlink',
    MKISOFS   = 'mkisofs',
    DISKDUMP_PATH = DISKDUMP_PATH,
    ISOFLAGS  = '-R -no-emul-boot',
                # '-A c-os -boot-load-size 4 -boot-info-table -input-charset utf8 -quiet'
    tools     = ['default', 'nasm'],
    BUILDERS  = {
        'Flp'     : flpbld,
        'Wlink'   : lnkbld,
        'FlpPad'  : flppad,
        'FlpJSON' : flpjson,
        'ISOPack' : isopack
    }
)

env_boot_asm = Environment(
    ENV     = os.environ,
    ASFLAGS = '-f bin -i./src/lib/',
    tools   =['default', 'nasm']
)

# Build the bootloader objects
env_boot_asm.Object(BOOTSECT_BIN, BOOTSECT_SRC)

# Build the kernel objects
KERN_SOURCES = env_kernel.Glob('%s/*.[s]' % SRC_KERNEL) + \
               env_kernel.Glob('%s/*.[s]' % SRC_DRIVER)
kernel_s_objs = [
    env_kernel.Object(
        '%s/%s.o' % (BUILD_KERN, os.path.splitext(os.path.split(str(src))[1])[0]),
        src
    ) for src in KERN_SOURCES]

# Link the object files
env_kernel.Wlink(
    target=KERN_BIN,
    source=kernel_s_objs)

# Build floppy disk image
env_kernel.Flp(
    target='%s/%s' % (BUILD_BASE, FLP_INT_FILE), # Target
    source=[BOOTSECT_BIN, KERN_BIN])             # Source

# Pad floppy image
env_kernel.FlpPad(
    target='%s/%s' % (BUILD_BASE, FLP_FILE),
    source='%s/%s' % (BUILD_BASE, FLP_INT_FILE))

# Build floppy package
env_kernel.FlpJSON(
    target='%s/%s' % (PCJS_PATH, JSON_FILE),      # Target
    source='%s/%s' % (BUILD_BASE, FLP_FILE))     # Source

# Run qemu
# Command([], [], "%s -f bochsrc.txt -q" % BOCHS)

# Run bochs
# TODO
# $(QEMU) -fda $(BUILD_BASE)/$(FLP_FILE)
# ~/opt/bochs/bin/bochs -f bochsrc.txt -q
