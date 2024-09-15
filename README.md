- Spaghetticode / LC - Mendoza - Argentina / 2024 - RETROLauncher -

--------------------------------------------------------------------------
What is RETROLauncher?

RETROLauncher is a launcher with a graphical environment for retro games, 
created entirely in Lua under the Enceladus development environment, in 
conjunction with Retroarch, POPStarter and Neutrino for the execution of 
the games.

The main objective of creating this program is to provide a friendly, 
attractive and customizable graphical environment to manage ROMS libraries 
on the PS2. In addition to being able to have all those libraries in one 
place and with easy access.

RETROLauncher seeks to avoid complex configurations, so the configurations 
are reduced to the minimum possible, just place the ROM and play, however, 
all the configurations are completely editable if an advanced user wishes 
to modify them, they are still there.

--------------------------------------------------------------------------
What do I need to run RETROLauncher?

Requirements for correct execution of RETROLauncher: 
+ Place the “RETROLauncher” folder in the root of the USB, it works in 
other directories, but it is recommended that it be in the root because 
Retroarch will continue saving in the root, if you place RETROLauncher in 
another folder delete all Retroarch configurations under the name of 
“retroarch.cfg” and “retroarch-salamander.cfg”. 

+ If you are going to run RETROLauncher on a USB flash drive with “exFAT” 
format, make sure you have the corresponding drivers on the PS2 Memory Card.

+ For POPStarter (PS1) you must have the POPS folder in the root of the USB, 
as well as the binaries necessary for it to run ("IOPRP252.IMG" and 
"POPS_IOX.PAK" respect name and capitalization), the binaries are not 
included with RETROLauncher for legal reasons. POPStarter is only found in 
the RETROLauncher files. 

+ It is mandatory that when running RETROLauncher there are not two USB 
sticks connected simultaneously to the PS2 USB ports. If RETROLauncher 
detects the existence of multiple memories in the USB ports, the program 
will not start and will force it to restart, as well as if the USB memory is 
in the second USB port. This is to avoid known issues in RETROLauncher when 
executing and manipulating directories. 

+ To run DVD from the reader it is necessary that the disc be placed before 
running RETROLauncher or it can be placed after, in the latter case update 
the list so that the DVD is listed in the APPS section (once listed it is 
necessary to restart to be able to load another DVD).

Warning: RETROLauncher manipulates directories, reads, writes and deletes 
RETROLauncher's own data (files), and although tests have been carried out, 
it is recommended that it not be used together with important data. It is 
also very important that you verify the source from which RETROLauncher 
downloads since being open source, the code can be manipulated to make it 
malicious. 
THE RESPONSIBILITY FOR THE USE OF RETROLauncher IS AT YOUR OWN COUNT, TRY 
TO BACK UP YOUR DATA BEFORE USING RETROLauncher AND DOWNLOAD THE PROGRAM 
FROM RELIABLE SOURCES.

--------------------------------------------------------------------------
What games can I launch with RETROLauncher?

RETROLauncher uses different versions of Retroarch, as well as POPStarter 
and Neutrino. Therefore, the games and compatibility are limited to the 
different cores and emulators used, RETROLauncher is not an emulator but a 
launcher, it does not improve compatibility with the games, it only launches 
them.

List of Emulators/Cores included in RETROLauncher:
+ Atari 2600 (Not compatible with “exFAT”) 
Core Retroarch: “stella2014_libretro_ps2.elf” 
Version: Retroarch - Version 1.9.14

+ Neo Geo Pocket 
Core Retroarch: “race_libretro_ps2.elf” 
Version: Retroarch - Version 1.14.0

+ Nintendo Famicom 
Core Retroarch: “fceumm_libretro_ps2.elf” 
Version: Retroarch - Version 1.14.0

+ Nintendo Game Boy 
Core Retroarch: “gambatte_libretro_ps2.elf” 
Version: Retroarch - Version 1.15.0

+ Nintendo Game Boy Color 
Core Retroarch: “gambatte_libretro_ps2.elf” 
Version: Retroarch - Version 1.15.0

+ Nintendo Game Boy Advance (High loading times) 
Core Retroarch: “gpsp_libretro_ps2.elf” 
Version: Retroarch - Version 1.15.0 
Important Note: For better compatibility with games place the GBA BIOS in 
the following directory, Retroarch will find it automatically. 
Directory: 
“USB:/RETROLauncher/System/RetroarchPS2/Nintendo Game Boy Advance/retroarch/system/” 
BIOS name: “gba_bios.bin” 
It should look like this:
“USB:/RETROLauncher/System/RetroarchPS2/Nintendo Game Boy Advance/retroarch/system/gba_bios.bin”

+ Nintendo Super Famicom (Not compatible with “exFAT”) 
Core Retroarch: “snes9x2002_libretro_ps2.elf” 
Version: Retroarch - Version 1.10.0

+ PlayStation 1 (Requires drivers for exFAT) 
POPStarter: “POPSTARTER.ELF” 
Version: POPSTARTER - Version 13

+ PlayStation 2 
Neutrino: “Neutrino.elf” 
Version: Neutrino – Version 1.3.1

+ Sega Game Gear 
Core Retroarch: “picodrive_libretro_ps2.elf” 
Version: Retroarch - Version 1.19.0

+ Sega Master System 
Core Retroarch: “picodrive_libretro_ps2.elf” 
Version: Retroarch - Version 1.19.0

+ Sega Megadrive 
Core Retroarch: “picodrive_libretro_ps2.elf” 
Version: Retroarch - Version 1.19.0

+ Sega SG-1000 
Core Retroarch: “picodrive_libretro_ps2.elf” 
Version: Retroarch - Version 1.19.0

+ Applications ELF 
Enceladus: “Enceladus.elf” 
Version: Enceladus - Released 10/02/2024

--------------------------------------------------------------------------
Credits

Enceladus: Enceladus is an enhanced Lua environment for creating homebrew 
software for the PS2. 
Created by Daniel Santos. 
DanielSant0s X: https://x.com/danadsees 
Youtube: https://www.youtube.com/channel/UCIDx5TuDp-1IRTRr5l5JSdw 
Project Link: https://github.com/DanielSant0s/Enceladus 
License: Distributed under GNU GPL-3.0 License. 

Retroarch PS2 Port: RetroArch is a frontend for emulators, game engines 
and media players. 
Created by RetroArch contributor fjtrujy (Francisco J. Trujillo). 
fjtrujy X: https://x.com/fjtrujy 
Retroarch Link: https://www.retroarch.com 
Licenses: There is software behind RetroArch that is protected by 
Non-Commercial licenses. It is important to respect the wishes of the 
developers and people behind the respective projects. 
https://docs.libretro.com/development/licenses/ 

POPStarter: POPStarter is a launcher which lets you play your PS1 games 
in combination with PS1 emulator for PS2. 
Created by developer krHACKen. 
POPStarter Link: https://www.psx-place.com/threads/popstarter.19139/ 

Neutrino: Neutrino is a small, fast and modular PS2 device emulator that 
maximizes compatibility and performance. 
Created by developer Maximus32 (Rick Gaiser). 
Neutrino Link: https://github.com/rickgaiser/neutrino 
License: Academic Free License "AFL" v. 3.0 

Original background: 
https://www.artapixel.com/escp-art-midnight-sun-city-night-retrowave-cyberpunk.html
Created by < e s c p > Art 
License: This Image is licensed under the Creative Commons Zero v1.0 Universal. 
Free images by https://www.artapixel.com 

Public Pixel: Retro video game style text font. Designed by GGBotNet. 
GGBotNet X: https://twitter.com/ggbotnet 
Youtube: https://www.youtube.com/channel/UCndkEEd767CI7wTlNJYKrTg 
Public Pixel Link: https://www.ggbot.net/fonts/ 
License: This Font Software is licensed under the Creative Commons Zero v1.0 
Universal. 

Spaghetticode: I created RETROLauncher with the sole purpose of having 
a simple and editable graphical environment to have collections of retro 
games on PS2, I made it for myself and I wasn't planning to publish it, 
but I thought it would be good to share it in case someone somewhere 
was looking for the same thing as me, something retro-focused on our 
beloved PS2. At no time did I want to offend or disrespect the developers 
behind the different applications used in this program, if I have done 
so I apologize. I tried to compile as much information as possible to 
give the credits correctly. I hope I haven't made a mistake, or that I've 
overlooked something. If so, I apologize. 
RETROLauncher we all do it.
 
Thank you for using RETROLauncher.								Boon Tobias

--------------------------------------------------------------------------
