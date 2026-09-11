#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BuildSystems.py

Generates the systems table of the launcher from the RetroArch cores that are
actually installed - the role es_systems.cfg plays in Batocera, except that
nobody has to write it by hand and it cannot drift from what is on the drive.

    python BuildSystems.py                    dry run, prints the table
    python BuildSystems.py --write            writes System/systems.lua

--------------------------------------------------------------------------------
WHERE THE DATA COMES FROM
--------------------------------------------------------------------------------
Every core ships a .info file. The fields used here:

    display_name          "Nintendo - SNES / SFC (Snes9x 2002)"
    corename              "Snes9x 2002"
    supported_extensions  "smc|fig|sfc|gd3|gd7|dx2|bsx|swc"
    database              "Nintendo - Super Nintendo Entertainment System|Nintendo - Satellaview|..."
    systemname            "Super Nintendo Entertainment System"

THE PIVOT IS "database", NOT "systemname". systemname is free text and the
same platform is spelled four ways across cores - "Sega 8-bit", "Sega 8-bit
(MS/GG/SG-1000)", "Sega 8/16-bit + 32X (Various)", "MSX/SVI/ColecoVision/
SG-1000". database uses the libretro naming, "Sega - Master System - Mark
III", identical in every core that supports it, so grouping on it puts the
five Game Boy cores under one system instead of two. A core with no database
field - the music players, Pong, Palm, Mac, TI-83, Tamagotchi - is filed under
its systemname.

Counted on the 61 cores present when this was written: 59 systems, 13 of them
with more than one core to choose from.

--------------------------------------------------------------------------------
WHAT COMES OUT
--------------------------------------------------------------------------------
A Lua table, one entry per system, in the shape Batocera uses. A RetroArch
core and a stand-alone emulator are both just a "backend" of a system, so the
launcher handles a Game Boy and a PlayStation 2 through the same code path:

    SYSTEMS["gb"] = {
        name     = "Nintendo - Game Boy",
        folder   = "gb",
        roots    = { { path = "Roms/gb", at = "launcher" } },
        ext      = {".dmg", ".gb", ".sgb", ".zip"},
        backends = {
            { kind = "retroarch", id = "gambatte", name = "Gambatte", ext = {...} },
            { kind = "retroarch", id = "mgba",     name = "mGBA",     ext = {...} },
        },
        default  = "gambatte",
    }

    SYSTEMS["ps2"] = {
        name     = "Sony - PlayStation 2",
        folder   = "ps2",
        roots    = { { path = "DVD", at = "drive" }, { path = "CD", at = "drive" } },
        ext      = {".iso"},
        backends = {
            { kind = "neutrino", id = "neutrino", name = "Neutrino", ext = {".iso"} },
            { kind = "opl",      id = "opl",      name = "OPL",      ext = {".iso"} },
        },
        default  = "neutrino",
    }

"roots" is where to scan, and "at" says what the path is relative to. The PS2
library is not under Roms/ at all: it is the DVD/ and CD/ folders at the root
of the drive, which is what OPL and Neutrino read, so that is where the
launcher reads too. Likewise a .VCD for POPStarter ends up in POPS/ at the
drive root.

"folder" is the Batocera name for the system wherever one exists, because the
library this feeds comes from Batocera and keeping its names means the ROM
folders and the gamelist.xml line up without a translation table. The twelve
folders the launcher already uses keep their names.

The default core is taken from PREFERRED below when the system is listed
there, otherwise the first core alphabetically. Per-system and per-game
overrides belong in systems.cfg / games.cfg, not here - this file describes
what is available, not what the user chose.
"""

import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
LAUNCHER = os.path.join(HERE, "..", "To Transfer on USB or Exfat", "Prism")
LIBRETRO = os.path.join(LAUNCHER, "LibretroPS2Files")
OUT = os.path.join(LAUNCHER, "System", "systems.lua")

CORE_SUFFIX = "_libretro_ps2.elf"

# libretro database name -> Batocera folder name. Anything not here gets a slug
# of the database name. The first twelve are the launcher's existing folders.
FOLDERS = {
    "Sega - Mega Drive - Genesis": "megadrive",
    "Sega - Master System - Mark III": "mastersystem",
    "Sega - Game Gear": "gamegear",
    "Nintendo - Nintendo Entertainment System": "nes",
    "Nintendo - Game Boy": "gb",
    "Nintendo - Game Boy Color": "gbc",
    "Nintendo - Game Boy Advance": "gba",
    "Atari - 2600": "atari2600",
    "Atari - Lynx": "lynx",
    "Sega - SG-1000": "sg1000",
    "SNK - Neo Geo Pocket": "ngp",
    "Nintendo - Super Nintendo Entertainment System": "snes",

    "SNK - Neo Geo Pocket Color": "ngpc",
    "Nintendo - Family Computer Disk System": "fds",
    "Nintendo - Satellaview": "satellaview",
    "Nintendo - Sufami Turbo": "sufami",
    "Sega - 32X": "sega32x",
    "Sega - Mega-CD - Sega CD": "segacd",
    "Sega - PICO": "pico",
    "Bandai - WonderSwan": "wswan",
    "Bandai - WonderSwan Color": "wswanc",
    "Microsoft - MSX": "msx1",
    "Microsoft - MSX2": "msx2",
    "Coleco - ColecoVision": "colecovision",
    "Mattel - Intellivision": "intellivision",
    "Magnavox - Odyssey2": "o2em",
    "Philips - Videopac+": "videopacplus",
    "Fairchild - Channel F": "channelf",
    "Emerson - Arcadia 2001": "arcadia",
    "Interton - VC 4000": "vc4000",
    "Elektor - TV Games Computer": "elektor",
    "Atari - 5200": "atari5200",
    "Atari - 8-bit Family": "atari800",
    "SNK - Neo Geo CD": "neogeocd",
    "Sharp - X1": "x1",
    "NEC - PC-8001 - PC-8801": "pc88",
    "Sinclair - ZX 81": "zx81",
    "Thomson - MOTO": "thomson",
    "Spectravideo - SVI-318 - SVI-328": "spectravideo",
    "Epoch - Cassette Vision": "cassettevision",
    "Arduboy Inc - Arduboy": "arduboy",
    "BK-0010/BK-0011": "bk",
    "CHIP-8": "chip8",
    "PICO-8": "pico8",
    "LowRes NX": "lowresnx",
    "WASM-4": "wasm4",
    "MicroW8": "microw8",
    "Uzebox": "uzebox",
    "VaporSpec": "vaporspec",
    "Lutro": "lutro",
    "J2ME": "j2me",
    "DOOM": "doom",
    "Wolfenstein 3D": "wolf3d",
    "Cave Story": "cavestory",
    "MrBoom": "mrboom",
    "Jump 'n Bump": "jumpnbump",
    "2048": "2048",
    "DICE": "dice",
    "gam4980": "gam4980",
    # systemname fallbacks, for cores without a database field
    "Music": "music",
    "Pong Game Clone": "gong",
    "Anarch": "anarch",
    "Mac68k": "macintosh",
    "Palm OS": "palm",
    "TI83": "ti83",
    "Tamagotchi P1": "tamagotchi",
}

# Systems that are not RetroArch cores. They have backends of their own, and
# their files do not all live under Roms/: the PS2 library is what OPL and
# Neutrino read, the DVD/ and CD/ folders at the ROOT OF THE DRIVE, and a .VCD
# for POPStarter ends up in POPS/ at the drive root as well.
#
# "roots" lists where to scan. "at" says what the path is relative to:
#   "launcher"  the launcher folder, i.e. <drive>:/Prism/<path>
#   "drive"     the drive itself,    i.e. <drive>:/<path>
FIXED_SYSTEMS = {
    # "psx" is the EmulationStation name; Roms/psx holds media/ and titles.txt
    # only. The games are where their emulator reads them.
    "psx": {
        "name": "Sony - PlayStation",
        "roots": [
            {"path": "POPS", "at": "drive"},                # POPStarter: .VCD at the drive root
            {"path": "Ember/games", "at": "launcher"},      # Ember: one folder per game
        ],
        "backends": [
            {"kind": "pops", "id": "pops", "name": "POPStarter", "ext": [".vcd"]},
            {"kind": "ember", "id": "ember", "name": "Ember", "ext": [".cue", ".bin"]},
        ],
        "default": "pops",
    },
    "ps2": {
        "name": "Sony - PlayStation 2",
        "roots": [
            {"path": "DVD", "at": "drive"},
            {"path": "CD", "at": "drive"},
        ],
        "backends": [
            {"kind": "neutrino", "id": "neutrino", "name": "Neutrino", "ext": [".iso"]},
            {"kind": "opl", "id": "opl", "name": "OPL", "ext": [".iso"]},
        ],
        "default": "neutrino",
    },
}

# Default core per system, where it matters. Chosen for accuracy first and
# speed on the PS2 second; the alternatives stay available in the menu.
PREFERRED = {
    "gb": "gambatte",
    "gbc": "gambatte",
    "gba": "mgba",
    "nes": "fceumm",
    "fds": "fceumm",
    "lynx": "handy",
    "atari2600": "stella2014",
    "mastersystem": "gearsystem",
    "gamegear": "gearsystem",
    "sg1000": "gearsystem",
    "colecovision": "gearcoleco",
    "msx1": "fmsx",
    "msx2": "fmsx",
    "arduboy": "ardens",
}


def read_info(path):
    d = {}
    with open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            m = re.match(r'\s*([a-z_]+)\s*=\s*"(.*)"\s*$', line)
            if m:
                d[m.group(1)] = m.group(2)
    return d


def slug(name):
    s = name.lower()
    s = re.sub(r"[^a-z0-9]+", "", s)
    return s or "unknown"


def lua_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main(argv):
    write = "--write" in argv
    cores_dir = os.path.join(LIBRETRO, "cores")
    info_dir = os.path.join(LIBRETRO, "info")
    if not os.path.isdir(cores_dir):
        print("no cores folder at %s" % cores_dir)
        return 1

    cores = sorted(f[:-len(CORE_SUFFIX)] for f in os.listdir(cores_dir)
                   if f.endswith(CORE_SUFFIX))
    systems = {}
    orphans = []
    for c in cores:
        p = os.path.join(info_dir, c + "_libretro.info")
        if not os.path.isfile(p):
            orphans.append(c)
            continue
        d = read_info(p)
        exts = ["." + e.strip().lower() for e in d.get("supported_extensions", "").split("|")
                if e.strip()]
        entry = {"id": c, "name": d.get("corename", c), "ext": exts}
        dbs = [x.strip() for x in d.get("database", "").split("|") if x.strip()]
        if not dbs:
            dbs = [d.get("systemname", c)]
        for db in dbs:
            folder = FOLDERS.get(db, slug(db))
            s = systems.setdefault(folder, {"name": db, "folder": folder, "cores": [], "ext": set()})
            s["cores"].append(entry)
            s["ext"].update(exts)

    for s in systems.values():
        s["cores"].sort(key=lambda e: e["id"])
        ids = [e["id"] for e in s["cores"]]
        want = PREFERRED.get(s["folder"])
        s["default"] = want if want in ids else ids[0]
        # .zip is worth listing for every system: the launcher hands archives
        # to RetroArch, which extracts them itself.
        s["ext"].add(".zip")

    # Every RetroArch system scans Roms/<folder> under the launcher, and its
    # backends are cores. Put in the same shape as the fixed systems so the
    # launcher never has to ask which kind it is looking at.
    table = {}
    for folder, s in systems.items():
        table[folder] = {
            "name": s["name"],
            "roots": [{"path": "Roms/" + folder, "at": "launcher"}],
            "backends": [{"kind": "retroarch", "id": e["id"], "name": e["name"], "ext": e["ext"]}
                         for e in s["cores"]],
            "default": s["default"],
        }
    for folder, s in FIXED_SYSTEMS.items():
        table[folder] = s

    def ext_of(s):
        out = set()
        for b in s["backends"]:
            out.update(b["ext"])
        if any(b["kind"] == "retroarch" for b in s["backends"]):
            out.add(".zip")
        return sorted(out)

    lines = []
    lines.append("-- Generated by HelperScripts/BuildSystems.py from the .info files of the")
    lines.append("-- cores in LibretroPS2Files/cores, plus the fixed PlayStation entries.")
    lines.append("-- Do not edit: re-run the script instead.")
    lines.append("-- %d cores, %d systems." % (len(cores), len(table)))
    lines.append("--")
    lines.append("-- SYSTEMS[folder] = {")
    lines.append("--     name     display name, libretro database spelling")
    lines.append("--     folder   the key, also the Roms/ folder name (Batocera spelling)")
    lines.append("--     roots    where to scan: { path, at = \"launcher\" | \"drive\" }")
    lines.append("--     ext      every extension any backend of the system accepts")
    lines.append("--     backends { kind, id, name, ext }  kind: retroarch|pops|ember|neutrino|opl")
    lines.append("--     default  id of the backend used unless a config override says otherwise")
    lines.append("-- }")
    lines.append("SYSTEMS = {}")
    lines.append("")
    for folder in sorted(table):
        s = table[folder]
        lines.append("SYSTEMS[%s] = {" % lua_str(folder))
        lines.append("\tname     = %s," % lua_str(s["name"]))
        lines.append("\tfolder   = %s," % lua_str(folder))
        lines.append("\troots    = {")
        for r in s["roots"]:
            lines.append("\t\t{ path = %s, at = %s }," % (lua_str(r["path"]), lua_str(r["at"])))
        lines.append("\t},")
        lines.append("\text      = {%s}," % ", ".join(lua_str(e) for e in ext_of(s)))
        lines.append("\tbackends = {")
        for b in s["backends"]:
            lines.append("\t\t{ kind = %s, id = %s, name = %s, ext = {%s} },"
                         % (lua_str(b["kind"]), lua_str(b["id"]), lua_str(b["name"]),
                            ", ".join(lua_str(x) for x in b["ext"])))
        lines.append("\t},")
        lines.append("\tdefault  = %s," % lua_str(s["default"]))
        lines.append("}")
        lines.append("")
    lines.append("--- The system a folder name belongs to, or nil. ---------------------------------")
    lines.append("function system_of_folder(folder)")
    lines.append("\tif folder == nil then return nil end")
    lines.append("\treturn SYSTEMS[string.lower(folder)]")
    lines.append("end")
    lines.append("")
    lines.append("--- The backends able to open a file of a system, the default first. ------------")
    lines.append("--- A .zip is accepted by every RetroArch core: RetroArch extracts it itself.")
    lines.append("function backends_for(folder, filename)")
    lines.append("\tlocal s = SYSTEMS[folder]")
    lines.append("\tif s == nil then return {} end")
    lines.append("\tlocal ext = string.lower(string.match(filename or \"\", \"%.[^%.]+$\") or \"\")")
    lines.append("\tlocal out = {}")
    lines.append("\tfor i = 1, #s.backends do")
    lines.append("\t\tlocal b = s.backends[i]")
    lines.append("\t\tlocal ok = (ext == \".zip\" and b.kind == \"retroarch\")")
    lines.append("\t\tfor j = 1, #b.ext do if b.ext[j] == ext then ok = true end end")
    lines.append("\t\tif ok then")
    lines.append("\t\t\tif b.id == s.default then table.insert(out, 1, b) else out[#out + 1] = b end")
    lines.append("\t\tend")
    lines.append("\tend")
    lines.append("\treturn out")
    lines.append("end")
    lines.append("")
    lines.append("--- The absolute folders to scan for a system on one drive. -----------------------")
    lines.append("--- launcher_dir is e.g. \"mass1:/Prism\"; the drive is taken from it.")
    lines.append("function scan_roots(folder, launcher_dir)")
    lines.append("\tlocal s = SYSTEMS[folder]")
    lines.append("\tif s == nil or launcher_dir == nil then return {} end")
    lines.append("\tlocal drive = string.match(launcher_dir, \"^[^:]+:\") or launcher_dir")
    lines.append("\tlocal out = {}")
    lines.append("\tfor i = 1, #s.roots do")
    lines.append("\t\tlocal r = s.roots[i]")
    lines.append("\t\tif r.at == \"drive\" then out[#out + 1] = drive ..\"/\".. r.path")
    lines.append("\t\telse out[#out + 1] = launcher_dir ..\"/\".. r.path end")
    lines.append("\tend")
    lines.append("\treturn out")
    lines.append("end")
    text = "\n".join(lines) + "\n"

    multi = sorted((f, [e["id"] for e in s["cores"]], s["default"])
                   for f, s in systems.items() if len(s["cores"]) > 1)
    print("%d cores, %d systems, %d with a choice of core" % (len(cores), len(systems), len(multi)))
    if orphans:
        print("no .info for: %s" % ", ".join(orphans))
    print()
    for folder, ids, default in multi:
        print("  %-16s %s   -> %s" % (folder, ", ".join(ids), default))
    print()
    singles = sorted(f for f, s in systems.items() if len(s["cores"]) == 1)
    print("one core only: " + ", ".join(singles))

    if write:
        with open(OUT, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
        print("\nwritten: %s  (%d lines)" % (OUT, text.count("\n")))
        make_rom_folders(systems)
    else:
        print("\nadd --write to produce System/systems.lua")
    return 0


def make_rom_folders(systems):
    """One Roms/<system>/ per installed core, ready to drop games into.

    This belongs HERE and not in the launcher, and not checked into the repository
    either. Not in the launcher: creating sixty-eight directories on an exFAT stick at
    every boot is slow, and writing to somebody's drive uninvited to fix a problem they
    do not have is rude. Not in the repository: git cannot store an empty directory, so
    each one would need a placeholder file, and the set depends on which cores YOU
    installed - shipping all sixty-eight would be sixty-eight folders most people never
    open.

    Here it is exactly right: this script already knows which cores are present, it runs
    on the PC, and it runs when the answer changes - when you add or remove a core.

    PlayStation 1 and 2 are skipped: their games live in POPS/, Ember/games/, DVD/ and
    CD/ at the root of the drive, where their emulators read them. Only their artwork
    goes under Roms/, and BatoceraGamelistandBatoceraGamelistandMediaCopier.py makes those folders itself."""
    roms = os.path.join(LAUNCHER, "Roms")
    if not os.path.isdir(roms):
        print("\nno Roms/ next to the launcher, folders not created")
        return

    made, existed = 0, 0
    for folder in sorted(systems):
        if folder in ("psx", "ps2"):
            continue
        base = os.path.join(roms, folder)
        if os.path.isdir(base):
            existed += 1
        else:
            made += 1
        for sub in ("", "media/covers", "media/screenshots", "media/cartridges"):
            os.makedirs(os.path.join(base, sub), exist_ok=True)

        info = os.path.join(base, ".INFO - %s.txt" % folder)
        if not os.path.isfile(info):
            s = systems[folder]
            names = ", ".join(e["name"] for e in s["cores"]) or "no core"
            exts = " ".join(sorted(s["ext"])) or "any"
            with open(info, "w", encoding="utf-8", newline="\n") as f:
                f.write(
                    "%s\n%s\n\n"
                    "Put the games here. Prism reads this folder because a core that\n"
                    "plays this system is installed in LibretroPS2Files/cores.\n\n"
                    "    accepted here   %s\n"
                    "    played by       %s\n\n"
                    "    media/covers/<rom name>.png         box art\n"
                    "    media/screenshots/<rom name>.png    a shot of the game\n"
                    "    media/cartridges/<rom name>.png     the cartridge or disc\n"
                    "    gamelist.xml                        names and descriptions\n\n"
                    "The picture is named after the ROM without its extension, so\n"
                    "\"Sonic (World).zip\" wants \"Sonic (World).png\". HelperScripts/\n"
                    "BatoceraGamelistandBatoceraGamelistandMediaCopier.py fills all of it from a Batocera library.\n\n"
                    "Deleting this folder is safe: it comes back the next time\n"
                    "BuildSystems.py runs, as long as the core is still installed.\n"
                    % (folder, "=" * len(folder), exts, names))

    print("\nRoms/: %d folder(s) created, %d already there" % (made, existed))
    print("each with media/covers, media/screenshots, media/cartridges and a .INFO")


if __name__ == "__main__":
    sys.exit(main(sys.argv))
