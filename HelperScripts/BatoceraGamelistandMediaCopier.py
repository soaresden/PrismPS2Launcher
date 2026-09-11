"""
BatoceraGamelistandMediaCopier - fill a Prism install with the artwork and the names
you already have.

You have a Batocera (or Recalbox, or EmulationStation, or Retrobat) library on this PC,
scraped over the years. You have a USB stick or a drive with Prism on it. This copies
the second from the first: the screenshot, the box art, the cartridge picture, and every
scrap of text a scraper found - developer, publisher, year, players, genre, rating,
description - into the layout Prism reads.

    Prism side                              Batocera side
    Roms/<system>/media/screenshots/*.png   <image>       in gamelist.xml
    Roms/<system>/media/covers/*.png        <thumbnail>   (or <boxart>)
    Roms/<system>/media/cartridges/*.png    <cartridge>
    Roms/<system>/gamelist.xml              everything else, in the same format
    Bios/                                   bios/, the few files a PS2 core reads

It COMPLETES, and it never throws away work. Before writing, it reads the gamelist.xml
already on the Prism side and starts from it, so a description you scraped with ARRM,
or a name you corrected by hand, survives a run where Batocera has nothing to say about
that game. Batocera fills the gaps; it does not overwrite what is already there unless
you ask for --force. A picture already on the stick is left alone on the same terms.

So the routine is: add roms, run this, and only the new games cost anything.

PlayStation 1 and 2 are not only in Roms/: the games live in POPS/, Ember/games/ and
DVD/, CD/ at the root of the drive, where their emulators read them - and, since Prism
learned to find loose discs, in Roms/psx and Roms/ps2 as well. All of them are looked
at. Their artwork goes to Roms/psx/media/ and Roms/ps2/media/, because that is where
Prism looks for it. The script knows this; you do not have to.


THE BIOS

Batocera keeps its BIOS in bios/, beside roms/ rather than inside it, so the
folder is offered separately and guessed from the roms path. Only the handful
of names a PlayStation 2 core can actually read are taken - a Batocera bios/
folder holds gigabytes of Saturn, Dreamcast and PS2 files that would sit on
your stick forever without being opened once. A dump is copied under the name
Batocera filed it under, matched without regard to case. At the end it says
what an installed core wants and Batocera did not have.


TIDYING UP

A picture whose game is no longer on the stick is dead weight on a device with 4 MB of
video memory and a slow bus. Any file in media/ that no game claims is MOVED (not
deleted - they are your files) to Roms/<system>/media/_unused/, where you can look at
it, restore it, or empty it. --keep-unused leaves everything where it is.


WHY THE PICTURES ARE RESIZED

A PlayStation 2 has 32 MB of main memory and 4 MB of video memory. A 1200x1600 box scan
is 7 MB decoded, and Prism holds a dozen at a time. Everything is fitted inside 320x240
and written as a non-interlaced RGBA PNG - interlaced is what makes the console print
"libpng warning: Interlace handling should be turned on" on every single load.


USAGE

    python BatoceraGamelistandMediaCopier.py               ask, then do it
    python BatoceraGamelistandMediaCopier.py --force       redo what is already there
    python BatoceraGamelistandMediaCopier.py --keep-unused leave orphaned pictures alone
    python BatoceraGamelistandMediaCopier.py --dry-run     say what it would do

It asks for three folders: where Prism is, where the Batocera roms are, and
where the Batocera BIOS are. Answer the third with a blank line to skip it.

At every question, Enter alone takes the value in brackets.

Needs Pillow for the resizing:  pip install pillow
"""

import os
import re
import sys
import shutil
import xml.etree.ElementTree as ET

try:
    from PIL import Image
    HAVE_PIL = True
except ImportError:
    HAVE_PIL = False

MAX_W, MAX_H = 320, 240

# What we take, where it goes, and the tag Prism reads it back from. The first source
# tag that exists wins, so a library scraped with one tool works as well as one scraped
# with another: ARRM, Skraper and Batocera's own scraper do not agree on which tag holds
# the box. Wheels are not here on purpose - Prism has nowhere to show one.
MEDIA = [
    ("screenshots", ["image", "titleshot", "mix", "screenshot"], "image"),
    ("covers",      ["thumbnail", "boxart", "box2dfront", "cover"], "thumbnail"),
    ("cartridges",  ["cartridge", "support", "disc"], "cartridge"),
]

MEDIA_TAGS = [row[2] for row in MEDIA]

# Text carried over, in the order EmulationStation writes it.
TEXT_TAGS = ["name", "desc", "developer", "publisher", "genre", "players",
             "rating", "releasedate"]

# Folder names other front-ends use for the same machine.
ALIASES = {
    "psx":          ["psx", "playstation", "ps1"],
    "ps2":          ["ps2", "playstation2"],
    "megadrive":    ["megadrive", "genesis", "md"],
    "mastersystem": ["mastersystem", "sms"],
    "gamegear":     ["gamegear", "gg"],
    "nes":          ["nes", "famicom"],
    "snes":         ["snes", "sfc", "supernintendo"],
    "gb":           ["gb", "gameboy"],
    "gbc":          ["gbc", "gameboycolor"],
    "gba":          ["gba", "gameboyadvance"],
    "lynx":         ["lynx", "atarilynx"],
    "sg1000":       ["sg1000", "sg-1000"],
    "ngp":          ["ngp", "neogeopocket"],
    "ngpc":         ["ngpc", "neogeopocketcolor"],
}

ROM_EXT = {".zip", ".7z", ".nes", ".fds", ".sfc", ".smc", ".gb", ".gbc", ".gba",
           ".md", ".gen", ".smd", ".bin", ".sms", ".gg", ".a26", ".lnx", ".lyx",
           ".sg", ".ngp", ".ngc", ".npc", ".pce", ".ws", ".wsc", ".col", ".int",
           ".vcd", ".iso", ".cue", ".chd"}

# A loose PlayStation disc in Roms/psx. The .bin of a .cue is not a second game.
PSX_LOOSE = {".cue", ".bin", ".img", ".iso", ".chd", ".pbp"}

# The BIOS the installed cores can ask for, and what each one is. Batocera keeps its
# own in <batocera>/bios/ under exactly these names, so they can be picked up in the
# same pass. Nothing else is touched: a Batocera bios/ folder holds several gigabytes
# of Saturn, Dreamcast and PS2 files that no PlayStation 2 core will ever read.
#
# The Lua side that consumes these is PS1_BIOS_NAMES in System/emu/ember.lua and
# BIOS_LIBRETRO_LISTA in System/emu/retroarch.lua. Keep the three lists in step.
BIOS_WANTED = [
    ("gba_bios.bin",     "Game Boy Advance, for gpSP",            True),
    ("gb_bios.bin",      "Game Boy boot ROM",                     False),
    ("gbc_bios.bin",     "Game Boy Color boot ROM",               False),
    ("sgb_bios.bin",     "Super Game Boy boot ROM",               False),
    ("lynxboot.img",     "Atari Lynx",                            True),
    ("exec.bin",         "Intellivision executive ROM",           True),
    ("grom.bin",         "Intellivision graphics ROM",            True),
    ("colecovision.rom", "ColecoVision",                          True),
    ("coleco.rom",       "ColecoVision, other name",              False),
    ("bios.col",         "ColecoVision, other name again",        False),
    ("o2rom.bin",        "Magnavox Odyssey 2 / Videopac",         True),
    ("c52.bin",          "Odyssey 2, French machine",             False),
    ("g7400.bin",        "Videopac+ G7400",                       False),
    ("jopac.bin",        "Jopac, the French G7400",               False),
    ("disksys.rom",      "Famicom Disk System, for .fds",         False),
    ("bios.sms",         "Master System boot ROM",                False),
    ("bios.gg",          "Game Gear boot ROM",                    False),
    ("bios_CD_E.bin",    "Sega Mega CD, Europe",                  False),
    ("bios_CD_U.bin",    "Sega CD, US",                           False),
    ("bios_CD_J.bin",    "Sega Mega CD, Japan",                   False),
    ("neocd.bin",        "Neo Geo CD",                            True),
    ("ng-lo.rom",        "Neo Geo CD, zoom table",                True),
]

# PlayStation 1, for Ember. Any one of these is enough; all that are there are taken,
# and Prism picks the first of them it finds at launch.
BIOS_PS1 = [
    "bios.bin",
    "scph1000.bin", "scph1001.bin", "scph1002.bin", "scph101.bin",
    "scph5500.bin", "scph5501.bin", "scph5502.bin", "scph5552.bin",
    "scph7001.bin", "scph7002.bin", "scph7502.bin",
    "scph9001.bin", "scph9002.bin", "scph102a.bin", "scph102b.bin",
]

# Cores that want a whole tree rather than one dump. Copied only if Batocera has one.
BIOS_FOLDERS = ["bluemsx", "fmsx", "quasi88", "atari800"]


# --- small helpers ----------------------------------------------------------------

def ask(question, default=""):
    if default:
        print(f"    [{default}]")
    answer = input(f"  {question}: ").strip().strip('"').strip("'")
    return answer or default


def yes_no(question, default=False):
    d = "Y/n" if default else "y/N"
    answer = input(f"  {question} [{d}]: ").strip().lower()
    if not answer:
        return default
    return answer.startswith(("y", "o"))


def looks_like_ext(name):
    """Is what follows the last dot an extension, or part of the name?

    PlayStation names carry their disc ID: "Anna Kournikova [SCES_018.33]". An
    Ember game is a FOLDER with that name and no extension at all, and splitext
    happily reports ".33]" as its extension - which renamed the game to
    "...[SCES_018", stopped it matching its own artwork, and had the tidy-up
    sweep three perfectly good pictures into _unused. An extension is a short
    run of letters or digits and nothing else."""
    ext = os.path.splitext(os.path.basename(name.rstrip("/\\")))[1]
    return bool(ext) and re.fullmatch(r"\.[A-Za-z0-9]{1,4}", ext) is not None


def stem(name):
    """'Sonic (World).zip' -> 'Sonic (World)', and a dotted name left whole."""
    base = os.path.basename(name.rstrip("/\\"))
    if looks_like_ext(base):
        return os.path.splitext(base)[0]
    return base


def norm(name):
    """A key that survives the difference between two copies of the same game.

    'Gran Turismo (Europe).chd' and 'Gran Turismo.VCD' are one game. Regions,
    revisions, languages and punctuation are what differ between a Batocera set and
    what ends up on a PlayStation 2 stick, so all of it goes."""
    n = stem(name).lower()
    n = re.sub(r"\([^)]*\)", "", n)
    n = re.sub(r"\[[^\]]*\]", "", n)
    n = re.sub(r"[^a-z0-9]", "", n)
    return n


def text_of(game, tag):
    node = game.find(tag)
    if node is None or node.text is None:
        return None
    value = node.text.strip()
    return value or None


def first_media(game, tags, gamelist_dir):
    """The first of these tags that names a file that actually exists."""
    for tag in tags:
        rel = text_of(game, tag)
        if not rel:
            continue
        path = rel.replace("\\", "/")
        if not os.path.isabs(path):
            path = os.path.join(gamelist_dir, path.lstrip("./"))
        if os.path.isfile(path):
            return os.path.normpath(path)
    return None


# --- pictures ---------------------------------------------------------------------

def copy_picture(source, target, force, dry):
    """Fit inside 320x240, RGBA, not interlaced. Returns True if it wrote something."""
    if os.path.isfile(target) and not force:
        return False
    if dry:
        return True
    os.makedirs(os.path.dirname(target), exist_ok=True)

    if not HAVE_PIL:
        # Without Pillow the file is copied as it is. It may be too big for the
        # console to hold, and it will keep printing the interlace warning.
        shutil.copy2(source, target)
        return True

    try:
        with Image.open(source) as im:
            im = im.convert("RGBA")
            im.thumbnail((MAX_W, MAX_H), Image.LANCZOS)
            im.save(target, "PNG", optimize=True, interlace=False)
        return True
    except Exception as exc:
        print(f"      ! {os.path.basename(source)}: {exc}")
        return False


def tidy_media(media_dir, keep_stems, dry):
    """Move pictures no game claims into media/_unused/<kind>/. Returns how many."""
    moved = 0
    for kind, _tags, _out in MEDIA:
        directory = os.path.join(media_dir, kind)
        if not os.path.isdir(directory):
            continue
        for entry in sorted(os.listdir(directory)):
            full = os.path.join(directory, entry)
            if not os.path.isfile(full) or entry.startswith("."):
                continue
            if os.path.splitext(entry)[1].lower() not in (".png", ".jpg", ".jpeg"):
                continue
            if stem(entry) in keep_stems:
                continue
            moved += 1
            if dry:
                continue
            attic = os.path.join(media_dir, "_unused", kind)
            os.makedirs(attic, exist_ok=True)
            target = os.path.join(attic, entry)
            if os.path.exists(target):
                os.remove(target)
            shutil.move(full, target)
    return moved


# --- where the games are ------------------------------------------------------------

def prism_games(prism_root, folder):
    """Every game of one system on the Prism side, as {norm_key: display_file_name}.

    Roms/<folder>/ for cartridges. PlayStation 1 and 2 are where their emulators
    force them to be - POPS/, Ember/games/, DVD/, CD/ at the root of the drive - and
    also, since Prism learned to find loose discs, under Roms/ like everything else."""
    drive = os.path.dirname(prism_root.rstrip("/\\")) or prism_root
    found = {}

    def add_files(directory, exts=None, as_dirs=False, skip_cued_bins=False):
        if not os.path.isdir(directory):
            return
        names = sorted(os.listdir(directory))
        cued = set()
        if skip_cued_bins:
            cued = {stem(n) for n in names if n.lower().endswith(".cue")}
        for entry in names:
            full = os.path.join(directory, entry)
            if entry.startswith("."):
                continue
            if as_dirs:
                if os.path.isdir(full):
                    found.setdefault(norm(entry), entry)
            elif os.path.isfile(full):
                ext = os.path.splitext(entry)[1].lower()
                if exts is not None and ext not in exts:
                    continue
                # One disc, one entry: the .bin a .cue names is not a game of its own.
                if ext == ".bin" and stem(entry) in cued:
                    continue
                found.setdefault(norm(entry), entry)

    if folder == "psx":
        add_files(os.path.join(drive, "POPS"), {".vcd"})
        add_files(os.path.join(prism_root, "POPS"), {".vcd"})
        add_files(os.path.join(prism_root, "Ember", "games"), as_dirs=True)
        add_files(os.path.join(prism_root, "Roms", "psx"), PSX_LOOSE, skip_cued_bins=True)
    elif folder == "ps2":
        for sub in ("DVD", "CD"):
            add_files(os.path.join(drive, sub), {".iso"})
        add_files(os.path.join(prism_root, "Roms", "ps2"), {".iso", ".chd"})
    else:
        add_files(os.path.join(prism_root, "Roms", folder), ROM_EXT)
    return found


def batocera_gamelist(batocera_root, folder):
    """The gamelist.xml of the matching system on the Batocera side, and its folder."""
    for name in ALIASES.get(folder, [folder]):
        directory = os.path.join(batocera_root, name)
        path = os.path.join(directory, "gamelist.xml")
        if os.path.isfile(path):
            return path, directory
    return None, None


def read_existing(path):
    """The gamelist already on the Prism side, as {norm_key: {tag: text}}.

    This is what makes the script safe to re-run: whatever a scraper or a human put
    in there is the starting point, not something to be flattened."""
    out = {}
    if not os.path.isfile(path):
        return out
    try:
        root = ET.parse(path).getroot()
    except Exception as exc:
        print(f"      ! existing gamelist unreadable, ignoring it: {exc}")
        return out
    for game in root.findall("game"):
        node = game.find("path")
        if node is None or not node.text:
            continue
        entry = {}
        for tag in TEXT_TAGS + MEDIA_TAGS:
            value = text_of(game, tag)
            if value:
                entry[tag] = value
        out[norm(node.text)] = entry
    return out


# --- writing the Prism-side gamelist ------------------------------------------------

def esc(text):
    return (str(text).replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace('"', "&quot;"))


def write_gamelist(path, entries, dry):
    """entries: list of dicts with 'path', the text tags, and the media we copied."""
    lines = ['<?xml version="1.0"?>', "<gameList>"]
    for e in entries:
        lines.append("\t<game>")
        lines.append(f"\t\t<path>{esc(e['path'])}</path>")
        for tag in TEXT_TAGS:
            if e.get(tag):
                lines.append(f"\t\t<{tag}>{esc(e[tag])}</{tag}>")
        for tag in MEDIA_TAGS:
            if e.get(tag):
                lines.append(f"\t\t<{tag}>{esc(e[tag])}</{tag}>")
        lines.append("\t</game>")
    lines.append("</gameList>")
    text = "\n".join(lines) + "\n"
    if dry:
        return
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(text)


# --- the work -----------------------------------------------------------------------

def do_system(folder, prism_root, batocera_root, wanted, force, dry, tidy):
    games = prism_games(prism_root, folder)
    if not games:
        return None

    list_path = os.path.join(prism_root, "Roms", folder, "gamelist.xml")
    existing = read_existing(list_path)
    media_dir = os.path.join(prism_root, "Roms", folder, "media")

    source, source_dir = {}, None
    bato_path, source_dir = batocera_gamelist(batocera_root, folder)
    if bato_path is not None:
        try:
            root = ET.parse(bato_path).getroot()
            for game in root.findall("game"):
                node = game.find("path")
                if node is not None and node.text:
                    source.setdefault(norm(node.text), game)
        except Exception as exc:
            print(f"  {folder:<14} cannot read {bato_path}: {exc}")

    entries, copied, matched = [], 0, 0

    for key in sorted(games):
        name = games[key]
        # Start from what the Prism gamelist already says about this game.
        entry = dict(existing.get(key, {}))
        entry["path"] = "./" + name
        if folder == "psx" and not looks_like_ext(name):
            entry["path"] = "./" + name + "/"      # an Ember folder, not a file
        entry.setdefault("name", stem(name))

        game = source.get(key)
        if game is not None:
            matched += 1
            for tag in TEXT_TAGS:
                value = text_of(game, tag)
                # Batocera fills the gaps; --force lets it have the last word.
                if value and (force or not entry.get(tag)):
                    entry[tag] = value

            for kind, tags, out_tag in MEDIA:
                if kind not in wanted:
                    continue
                src = first_media(game, tags, source_dir)
                if src is None:
                    continue
                target = os.path.join(media_dir, kind, stem(name) + ".png")
                if copy_picture(src, target, force, dry):
                    copied += 1
                if os.path.isfile(target) or dry:
                    entry[out_tag] = f"./media/{kind}/{stem(name)}.png"

        # A picture that is on the stick but was never in the gamelist still counts.
        for kind, _tags, out_tag in MEDIA:
            if entry.get(out_tag):
                continue
            if os.path.isfile(os.path.join(media_dir, kind, stem(name) + ".png")):
                entry[out_tag] = f"./media/{kind}/{stem(name)}.png"

        entries.append(entry)

    write_gamelist(list_path, entries, dry)

    unused = 0
    if tidy:
        unused = tidy_media(media_dir, {stem(n) for n in games.values()}, dry)

    note = "" if bato_path else "   (nothing on the Batocera side)"
    tail = f"   {unused:>3} unused moved aside" if unused else ""
    print(f"  {folder:<14} {len(games):>4} games   {matched:>4} matched   "
          f"{copied:>4} pictures written{tail}{note}")
    return len(games)


def do_bios(prism_root, bios_root, force, dry):
    """Pick the BIOS the PS2 cores need out of a Batocera bios/ folder.

    Only the names Prism knows about, and only if they are not already there. The
    file name is what a core looks for, so a dump is copied under the name Batocera
    filed it under - matched without regard to case, since the same dump travels as
    scph1001.bin and as SCPH1001.BIN depending on who wrote it out."""
    if not os.path.isdir(bios_root):
        print(f"  Not a folder: {bios_root}")
        return

    # One case-insensitive index of what Batocera has, built once.
    have = {}
    for entry in os.listdir(bios_root):
        if os.path.isfile(os.path.join(bios_root, entry)):
            have.setdefault(entry.lower(), entry)

    dest_dir = os.path.join(prism_root, "Bios")
    if not dry:
        os.makedirs(dest_dir, exist_ok=True)

    copied, already, missing = 0, 0, []
    ps1_found = []

    def take(name, what, required):
        nonlocal copied, already
        real = have.get(name.lower())
        if real is None:
            if required:
                missing.append((name, what))
            return False
        target = os.path.join(dest_dir, real)
        if os.path.isfile(target) and not force:
            already += 1
            return True
        if not dry:
            shutil.copy2(os.path.join(bios_root, real), target)
        size = os.path.getsize(os.path.join(bios_root, real))
        print(f"    {real:<20} {size:>8}  {what}")
        copied += 1
        return True

    for name, what, required in BIOS_WANTED:
        take(name, what, required)

    for name in BIOS_PS1:
        if take(name, "PlayStation 1, for Ember", False):
            ps1_found.append(name)

    # The folder-based ones, copied whole.
    for name in BIOS_FOLDERS:
        source = os.path.join(bios_root, name)
        if not os.path.isdir(source):
            continue
        target = os.path.join(dest_dir, name)
        if os.path.isdir(target) and not force:
            already += 1
            continue
        if not dry:
            shutil.copytree(source, target, dirs_exist_ok=True)
        print(f"    {name + '/':<20} {'':>8}  whole folder")
        copied += 1

    print(f"\n  {copied} copied, {already} already there.")
    if not ps1_found:
        print("  No PlayStation 1 BIOS found: Ember will not start. Look for")
        print("  scph1001.bin or any other SCPH dump and put it in Prism's Bios/.")
    if missing:
        print("  Wanted by an installed core, not in the Batocera folder:")
        for name, what in missing:
            print(f"    {name:<20} {what}")
    print("  Bios/.INFO - Bios.txt lists every name, size and checksum.")


def find_prism():
    """A drive with a Prism folder on it, so the usual case needs no typing."""
    for letter in "DEFGHIJKLMNOPQRSTUVWXYZ":
        for name in ("Prism", "PRISM"):
            candidate = f"{letter}:\\{name}"
            if os.path.isdir(os.path.join(candidate, "Roms")):
                return candidate
    return ""


def main():
    force = "--force" in sys.argv
    dry = "--dry-run" in sys.argv or "--dry" in sys.argv
    tidy = "--keep-unused" not in sys.argv

    print(__doc__.split("THE BIOS")[0].strip())
    print()
    if not HAVE_PIL:
        print("  Pillow is not installed: pictures will be copied at their original")
        print("  size, which the console may not be able to hold. pip install pillow")
        print()
    print("  Press Enter to keep the value in brackets, or type another path.")
    print()

    prism_root = ask("Prism folder (the one holding Roms/)", find_prism())
    if not os.path.isdir(os.path.join(prism_root, "Roms")):
        print(f"  No Roms/ in {prism_root}. Nothing to do.")
        return
    batocera_root = ask("Batocera roms folder", r"D:\batocera\roms")
    if not os.path.isdir(batocera_root):
        print(f"  Not a folder: {batocera_root}")
        return

    print("\n  What to copy:")
    wanted = set()
    for kind, tags, _out in MEDIA:
        if yes_no(f"    {kind:<12} (from <{tags[0]}>)", True):
            wanted.add(kind)
    if not wanted:
        print("  Nothing selected; only the names and descriptions will be written.")

    # Batocera keeps its BIOS beside its roms, not inside them.
    bios_root = ""
    if yes_no("    BIOS too       (from Batocera's bios/ folder)", True):
        guess = os.path.join(os.path.dirname(batocera_root.rstrip("/\\")), "bios")
        bios_root = ask("Batocera bios folder", guess if os.path.isdir(guess) else "")

    # Every system folder Prism knows about: the ones under Roms/, plus the two whose
    # games can also live elsewhere.
    folders = set()
    roms = os.path.join(prism_root, "Roms")
    for entry in sorted(os.listdir(roms)):
        if os.path.isdir(os.path.join(roms, entry)) and not entry.startswith("!"):
            folders.add(entry)
    folders.add("psx")
    folders.add("ps2")

    print(f"\n  {prism_root}  <-  {batocera_root}")
    if dry:
        print("  (dry run: nothing will be written)")
    if not tidy:
        print("  (--keep-unused: orphaned pictures left where they are)")
    print()

    total = 0
    for folder in sorted(folders):
        count = do_system(folder, prism_root, batocera_root, wanted, force, dry, tidy)
        if count:
            total += count

    if bios_root:
        print("\n  BIOS:")
        do_bios(prism_root, bios_root, force, dry)

    print(f"\n  Done. {total} games looked at.")
    print("  Prism reads Roms/<system>/gamelist.xml and media/ at the next boot;")
    print("  press START, then Rescan games, to see it without restarting.")


if __name__ == "__main__":
    main()
