## Bochs
I tried `brew install bochs` but there were no display drivers included
in the build. I found that I had to compile myself
* Download source from https://sourceforge.net/projects/bochs/files/bochs/
* Extract
* configure
```commandline
./configure --enable-ne2000 \
            --enable-all-optimizations \
            --enable-cpu-level=6 \
            --enable-x86-64 \
            --enable-vmx=2 \
            --enable-pci \
            --enable-usb \
            --enable-usb-ohci \
            --enable-e1000 \
            --enable-debugger \
            --enable-disasm \
            --disable-debugger-gui \
            --with-sdl \
            --prefix=$HOME/opt/bochs
```
* Make
```commandline
make
```
* Install
```commandline
make install
```