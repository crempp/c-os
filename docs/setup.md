# Setup for C-OS Development

These instructions are specific for a Mac host environment but should be easily adapted to Windows or Linux with a little Googling.

* Setup the [Watcom toolchain](watcom.md)
* Install [Bochs from source](bochs.md)
* Install SCons `brew install scons`
* Clone this project
* Build `$ scons`
* Run in Bochs `~/opt/bochs/bin/bochs -f bochsrc.txt -q`