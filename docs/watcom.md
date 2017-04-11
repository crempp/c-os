# Setting up the Watcom Toolchain on Mac

Open Watcom v2 does not play nice with MacOS. These instructions get to two important tools to build (along with most other tools).

**NOTE:** I wrote this from memory, I may have missed something.

* Clone the source
`https://github.com/open-watcom/open-watcom-v2.git`
* Add the following variable to `setvars.sh`
```
export OWNOBUILD="restest ddespy whepwlk wspy drwatcom wzoom fmedit wr wresedit wre wde wimgedit aui vi
```
* Build the packages `.\build.sh`
* Move the entire `open-watcom-v2` directory to ~/opt
* setup path
```
export PATH="~/opt/open-watcom-v2/build/bin/:~/build/:$PATH"
```