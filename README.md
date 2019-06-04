# SEGA Megadrive/Genesis for MiSTer.

This is the port of fpgagen core.

fpgagen - a SEGA Megadrive/Genesis clone in a FPGA.
Copyright (c) 2010-2013 Gregory Estrade (greg@torlus.com)
All rights reserved


## Installing
copy *.rbf to root of SD card. Put some ROMs (*.BIN/*.GEN/*.MD) into Genesis folder


## Hot Keys
* F1 - reset to JP(NTSC) region
* F2 - reset to US(NTSC) region
* F3 - reset to EU(PAL)  region


## Auto Region option
There are 2 versions of region detection:

1) File name extension:

* BIN -> JP
* GEN -> US
* MD  -> EU

2) Header. It may not always work as not all ROMs follow the rule, especially in European region.
Heder may include several regions - the correct one will be selected depending on priority option.


## Additional features

* Multitaps: 4-way, Team player, J-Cart
* SVP chip (Virtua Racing)

