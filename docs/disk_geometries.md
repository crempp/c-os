# Disk Geometries

The following is a (complete?) table of floppy disk geometries. This is copied and adapted from [https://www.syslinux.org/wiki/index.php?title=MEMDISK](https://www.syslinux.org/wiki/index.php?title=MEMDISK).

```
+-------+-----------------+----+---+----+--------+-----------------+
| Disk  |  Disk size in   | C  | H | S  |  Phys  |
| Size  |      bytes      |    |   |    |  Size  |
+-------+-----------------+----+---+----+--------+-----------------+
| 160K  |  163,840 bytes  | 40 | 1 | 8  |  5.25" | SSSD            |
| 180K  |  184,320 bytes  | 40 | 1 | 9  |  5.25" | SSSD            |
| 320K  |  327,680 bytes  | 40 | 2 | 8  |  5.25" | DSDD            |
| 360K  |  368,640 bytes  | 40 | 2 | 9  |  5.25" | DSDD            |
| 640K  |  655,360 bytes  | 80 | 2 | 8  |  3.5"  | DSDD            |
| 720K  |  737,280 bytes  | 80 | 2 | 9  |  3.5"  | DSDD            |
| 1200K | 1,222,800 bytes | 80 | 2 | 15 |  5.25" | DSHD            |
| 1440K | 1,474,560 bytes | 80 | 2 | 18 |  3.5"  | DSHD            |
| 1600K | 1,638,400 bytes | 80 | 2 | 20 |  3.5"  | DSHD (extended) |
| 1680K | 1,720,320 bytes | 80 | 2 | 21 |  3.5"  | DSHD (extended) |
| 1722K | 1,763,328 bytes | 82 | 2 | 21 |  3.5"  | DSHD (extended) |
| 1743K | 1,784,832 bytes | 83 | 2 | 21 |  3.5"  | DSHD (extended) |
| 1760K | 1,802,240 bytes | 80 | 2 | 22 |  3.5"  | DSHD (extended) |
| 1840K | 1,884,160 bytes | 80 | 2 | 23 |  3.5"  | DSHD (extended) |
| 1920K | 1,966,080 bytes | 80 | 2 | 24 |  3.5"  | DSHD (extended) |
| 2880K | 2,949,120 bytes | 80 | 2 | 36 |  3.5"  | DSED            |
| 3120K | 3,194,880 bytes | 80 | 2 | 39 |  3.5"  | DSED (extended) |
| 3200K | 3,276,800 bytes | 80 | 2 | 40 |  3.5"  | DSED (extended) |
| 3520K | 3,604,480 bytes | 80 | 2 | 44 |  3.5"  | DSED (extended) |
| 3840K | 3,932,160 bytes | 80 | 2 | 48 |  3.5"  | DSED (extended) |
```
SSSD = Single Sided Single Density
DSDD = Double Sided Double Density
DSHD = Double Sided High Density
DSED = Double Sided Extra-high Density
