"""
POPSVCDtoBinCue.py - the same PlayStation library, for Ember instead of POPStarter.

You converted your games to .VCD for POPStarter and put them on the internal exFAT
disk. POPStarter cannot read that disk - its replacement drivers are usbd.irx and
usbhdfsd.irx, USB and nothing else, and on an internal drive it wants an APA partition
called __.POPS instead. Ember has no such limit: Prism starts it without resetting the
IOP, so it inherits the drive stack that is already up, ata_bd included.

Ember reads .cue/.bin, not .VCD. This makes that pair for every game you have, NAMED
AFTER THE .VCD, which is the whole point - see below.

Two sources, and the first is much the better one:

  the .VCD      is converted straight back to BIN+CUE, here, by this script. No tool to
                download and nothing to compile: the POPS2CUE logic (krHACKen, rebuilt
                by bucanero at github.com/bucanero/pops2cue) is ported into this file.
                Nothing from Batocera is needed, so the translations and hacks that
                exist nowhere else convert like any other game - and no game can be
                paired with the wrong regional dump, because the source IS the game.

  chdman        for anything with no .VCD: the matching .chd in your Batocera library,
                found by name.


WHY THE NAME MATTERS MORE THAN IT LOOKS

Artwork is looked up by the game's name. Your pictures are already filed as

    Roms/psx/media/covers/V-Ball - Beach Volley Heroes Europe [SLES_008.46].png

because that is what the .VCD is called. Extract the same game from Batocera under its
own name - "V-Ball - Beach Volley Heroes (Europe)" - and every one of those pictures
stops matching. So the .VCD name wins, and the collection stays whole.


WHERE THE FILES GO

    --layout=ember   (default)   Ember/games/<Game>/<Game>.cue + .bin
    --layout=roms                Roms/psx/<Game>.cue + .bin

The first is Ember's own layout: nothing is moved, every game is ready at once. The
second is the loose-disc layout - Prism finds those too, but it can only put ONE of them
in Ember/games at a time, moving it there at launch and back when you start another.
That is fine for a handful of games and pointless for a hundred.


SIZE

A .bin is the whole disc, uncompressed: 300-700 MB each, where the .chd was perhaps
half that and the .VCD about the same as the .bin. Converting a hundred games needs
tens of gigabytes. The list is printed with its total before anything is written, and
--limit stops after N games so you can try it on three.


USAGE

    python POPSVCDtoBinCue.py                 ask, then convert
    python POPSVCDtoBinCue.py --dry           list what it would do, write nothing
    python POPSVCDtoBinCue.py --limit 3       the first three only
    python POPSVCDtoBinCue.py --match "wild arms"     one title, by part of its name
    python POPSVCDtoBinCue.py --layout=roms   loose discs in Roms/psx instead
    python POPSVCDtoBinCue.py --force         redo games already extracted
    python POPSVCDtoBinCue.py --data-only     skip games whose music is CD audio,
                                              which Ember Beta 1 does not play yet

At every question, Enter alone takes the value in brackets.
"""

import os
import re
import subprocess
import sys

VCD_DIRS = [r"F:\POPS", r"E:\POPS"]
BATOCERA_PSX = r"D:\batocera\roms\psx"
PRISM = r"E:\Prism"
CHDMAN_DIR = r"D:\DOCS\Documents\a-Emulation\Batocera\Windows Tools\CHDMAN (RetroPie User-Friendly)"
POPS2CUE = r"D:\DOCS\Documents\a-Emulation\EmuWindows\Sony-PS2\!PS2 Physique\POPS-VCD-Manager\Common\pops2cue.exe"

DISC_EXT = {".chd", ".cue", ".bin", ".iso", ".img"}


def ask(label, default):
    if default:
        print("    [%s]" % default)
    try:
        got = input("  %s: " % label).strip().strip('"').strip("'")
    except EOFError:
        print()
        return default
    return got or default


def stem(name):
    return os.path.splitext(os.path.basename(name.rstrip("/\\")))[0]


def norm(name):
    """The key that makes a .VCD and a .chd of the same game look the same.

    The disc number is taken out FIRST and put back at the end, and that is not a
    detail: POPS names carry it in the open, "Final Fantasy IX France Disc 1", while
    Batocera keeps it in brackets, "Final Fantasy IX (France) (Disc 1)". Strip what is
    inside brackets and one side keeps the disc number while the other loses it - thirty
    multi-disc games failed to match on exactly that.

    Everything else goes: regions, languages, version tags, and the words the two
    converters disagree about keeping."""
    n = stem(name).lower()
    m = re.search(r"\b(?:disc|disk|cd)\s*([0-9]+)", n)
    disc = m.group(1) if m else ""
    n = re.sub(r"\([^)]*\)", " ", n)
    n = re.sub(r"\[[^\]]*\]", " ", n)
    n = re.sub(r"\b(?:disc|disk|cd)\s*[0-9]+", " ", n)
    n = re.sub(r"\bv\d+(?:\.\d+)*[a-z]?\b", " ", n)
    n = re.sub(r"\bno\s*edc\b", " ", n)
    n = re.sub(r"\b(europe|usa|japan|france|germany|italy|spain|netherlands|sweden"
               r"|korea|australia|asia|world|pal|ntsc|unl|proto|beta|demo|rev)\b", " ", n)
    n = re.sub(r"[^a-z0-9]", "", n)
    if disc:
        n = n + "disc" + disc
    return n


# --- VCD -> BIN + CUE, done here ------------------------------------------------------
#
# Ported from POPS2CUE v1.0 by krHACKen, reconstructed by bucanero from a disassembly:
# github.com/bucanero/pops2cue. No .exe to find, nothing to compile, and it works on
# every .VCD including the translations and hacks that exist nowhere else.
#
# The format, once read:
#   0x000000  a 1 MiB header. Byte 0x11 is the track count in BCD; the track table
#             starts at 0x1e with ten bytes per track; 'kHn' at 0x400 is the signature
#             CUE2POPS leaves behind.
#   0x100000  the disc image itself, raw MODE2/2352 - the .bin, byte for byte.
#
# The timestamps in the table are absolute, counted from the lead-in, so every one of
# them is two seconds ahead of what a cuesheet wants. Hence the "revert" below, which
# subtracts two seconds in BCD and borrows from the minutes when it has to.

VCD_IMAGE_AT = 0x100000
VCD_MIN_SIZE = 0x10a560

# BCD seconds whose low digit is 0 or 1: subtracting 2 needs a borrow, and taking 8 off
# the byte does it (0x10 - 8 = 0x08, which is BCD eight).
_BORROW_SEC = {0x10, 0x11, 0x20, 0x21, 0x30, 0x31, 0x40, 0x41, 0x50, 0x51}
# And when the seconds are 00 or 01, the borrow goes all the way into the minutes.
_BORROW_MIN = {0x10: 0x09, 0x20: 0x19, 0x30: 0x29, 0x40: 0x39, 0x50: 0x49,
               0x60: 0x59, 0x70: 0x69, 0x80: 0x79, 0x90: 0x89}


# "(Disc 2)" and "[CD 3]" are how Redump and Batocera write it; POPStarter names have
# had the brackets stripped out of them long before they get here, so a bare "Disc 2"
# sitting in the middle of the title has to be recognised too.
DISC_BRACKET = re.compile(r"\s*[\(\[]\s*(?:disc|disk|cd)\s*([0-9]+)[^\)\]]*[\)\]]", re.I)
DISC_BARE = re.compile(r"\s+(?:disc|disk|cd)\s*([0-9]+)\b", re.I)

# SLES_029.66, SCES_015.66 - and the disc number is hidden in the FIRST digit of the
# three: disc 1 is 029, disc 2 is 129, disc 3 is 229. Sony numbered them that way, so
# zeroing that digit is what makes the four discs of a game answer to one name.
SERIAL = re.compile(r"\[([A-Za-z]{4})[_\-]?([0-9]{3})\.([0-9]{2})\]")


def disc_of(name):
    """Which disc of a set this is, or None for a one-disc game."""
    m = DISC_BRACKET.search(name) or DISC_BARE.search(name)
    return int(m.group(1)) if m else None


def set_name(name):
    """The title with its disc marker taken out - what the shared folder is called."""
    out = DISC_BARE.sub(" ", DISC_BRACKET.sub(" ", name))
    return re.sub(r"\s{2,}", " ", out).strip()


def set_key(name):
    """What two discs of the same game have in common.

    The serial when there is one, because it survives translations, revisions and
    the small differences in wording between one disc's label and the next
    ("Disc 1 Evolution Disc" against "Europe Disc 2 Arcade Disc" is the same game).
    The cleaned title otherwise.
    """
    base = set_name(name)
    m = SERIAL.search(base)
    if m is not None:
        return (m.group(1) + "0" + m.group(2)[1:] + m.group(3)).lower()
    # No standard serial. Some sets number the discs inside the code instead -
    # [PE_DISK.01] and [PE_DISK.02] - so the bracketed tail has to come off before
    # the title can be compared.
    base = re.sub(r"\s*[\(\[][^\)\]]*[\)\]]\s*$", "", base)
    return re.sub(r"[^a-z0-9]", "", base.lower())


def _bcd(b):
    return (b >> 4) * 10 + (b & 0x0F)


def _revert(h, sec, mins, first):
    v = h[sec]
    if first or v not in _BORROW_SEC:
        if first or v not in (0x00, 0x01):
            if not first:
                h[sec] = (v - 2) & 0xFF
        else:
            h[sec] = 0x58 if v == 0x00 else 0x59
            m = h[mins]
            h[mins] = _BORROW_MIN.get(m, (m - 1) & 0xFF)
    else:
        h[sec] = (v - 8) & 0xFF


def vcd_tracks(path):
    """How many tracks the disc has, read straight from the header, or None.

    One track means the whole disc is data: everything the game plays is inside its
    own files, and Ember will sound exactly like the real console. More than one
    means CD audio - the music is on the disc as AUDIO tracks - and Ember Beta 1
    does not play those yet. Worth knowing which games you are converting.
    """
    try:
        with open(path, "rb") as fh:
            h = fh.read(0x20)
        if len(h) < 0x20 or h[0] != ord("A"):
            return None
        return _bcd(h[0x11])
    except OSError:
        return None


def vcd_cue(path, bin_name, noindex=False):
    """Read a POPS VCD and return its cuesheet, or raise ValueError saying why not."""
    size = os.path.getsize(path)
    if size < VCD_MIN_SIZE:
        raise ValueError("too small to be a POPS VCD")
    with open(path, "rb") as fh:
        h = bytearray(fh.read(0x410))
    if len(h) < 0x410:
        raise ValueError("truncated header")
    if h[0x408:0x40c] != h[0x40c:0x410]:
        raise ValueError("malformed sector count")
    if h[2] != 0xA0 or h[0x0C] != 0xA1 or h[0x16] != 0xA2:
        raise ValueError("the disc arrays are not where CUE2POPS puts them")
    if h[0] != ord("A"):
        raise ValueError("the first track is not a DATA track")
    if h[8] != 0x20:
        raise ValueError("the disc type is not CD-XA001")
    if h[7] != 0x01:
        raise ValueError("the first track is not TRACK 01")
    if bytes(h[0x400:0x403]) != b"kHn":
        raise ValueError("not converted by CUE2POPS")
    if h[0x403] < 0x20:
        raise ValueError("made by CUE2POPS v1.x, which this cannot read")

    tracks = _bcd(h[0x11])
    pos = 0x1E
    for i in range(tracks):
        if not noindex:
            _revert(h, pos + 4, pos + 3, i == 0)
        _revert(h, pos + 8, pos + 7, i == 0)
        pos += 10

    out = ['FILE "%s" BINARY\n   TRACK 01 MODE2/2352\n   INDEX 01 00:00:00\n' % bin_name]
    pos = 0x28
    for i in range(1, tracks):
        out.append("   TRACK %02X " % h[pos + 2])
        out.append("MODE2/2352" if h[pos] == ord("A") else "AUDIO")
        if not noindex and h[pos + 4] != h[pos + 8]:
            out.append("\n   INDEX 00 %02X:%02X:%02X" % (h[pos + 3], h[pos + 4], h[pos + 5]))
        out.append("\n   INDEX 01 %02X:%02X:%02X" % (h[pos + 7], h[pos + 8], h[pos + 9]))
        if i != tracks - 1:
            out.append("\n")
        pos += 10
    return "".join(out), tracks


def vcd_extract(path, out_dir, name):
    """Write <name>.cue, <name>.bin and <name>.vcdtoc from a .VCD.

    The .vcdtoc is the first 0x410 bytes of the VCD: its track table, 1040 bytes. It is
    kept because it is the ONE part of the original that the .bin does not contain, and
    because the cuesheet is built from it. If a cuesheet turns out wrong for a game with
    audio tracks - the only part of this that is not a plain copy of bytes - it can be
    rebuilt from this file long after the .VCD has gone. A kilobyte against having to
    convert a game twice is not a trade worth thinking about."""
    cue_text, _tracks = vcd_cue(path, name + ".bin")
    with open(path, "rb") as src:
        toc = src.read(0x410)
    with open(os.path.join(out_dir, name + ".vcdtoc"), "wb") as fh:
        fh.write(toc)

    # The .bin FIRST, and the .cue only once it is whole. Written the other way round,
    # a run stopped in the middle - Ctrl-C, a full disk, a cable pulled - leaves a
    # perfectly valid .cue beside a half-written .bin, and the next run sees the .cue,
    # decides the game is done, and skips it for ever. The .cue is the finish line here,
    # not the starting gun.
    binf = os.path.join(out_dir, name + ".bin")
    written = 0
    with open(path, "rb") as src, open(binf, "wb") as dst:
        src.seek(VCD_IMAGE_AT)
        while True:
            chunk = src.read(8 * 1024 * 1024)
            if not chunk:
                break
            dst.write(chunk)
            written += len(chunk)

    with open(os.path.join(out_dir, name + ".cue"), "w",
              encoding="ascii", errors="replace", newline="\n") as fh:
        fh.write(cue_text)
    return written


def find_chdman(folder):
    for name in ("chdman.exe", "a-chdman.exe"):
        for root, _dirs, files in os.walk(folder):
            for f in files:
                if f.lower() == name:
                    return os.path.join(root, f)
    return None


def human(n):
    if n >= 1024 ** 3:
        return "%.1f GB" % (n / 1024.0 ** 3)
    return "%d MB" % (n / 1024 / 1024)


def free_space(path):
    """Bytes free on the drive holding this path, or None."""
    try:
        import ctypes
        free = ctypes.c_ulonglong(0)
        drive = os.path.splitdrive(os.path.abspath(path))[0] + "\\"
        ok = ctypes.windll.kernel32.GetDiskFreeSpaceExW(
            ctypes.c_wchar_p(drive), None, None, ctypes.pointer(free))
        return free.value if ok else None
    except Exception:
        return None


CARD_SIZE = 128 * 1024
# POPStarter keeps a game's two cards in a folder named after the .VCD; Ember wants
# them beside the disc image under its own names. Same raw 128 KiB PS1 card either
# way, so the move is a copy and a rename, nothing more.
CARD_PAIRS = (("SLOT0.VMC", "MC1.vmc"), ("SLOT1.VMC", "MC2.vmc"))


def card_looks_real(path):
    """A raw PS1 card: 128 KiB, starting with the 'MC' signature."""
    try:
        if os.path.getsize(path) != CARD_SIZE:
            return False
        with open(path, "rb") as fh:
            return fh.read(2) == b"MC"
    except OSError:
        return False


def copy_cards(vcd_dir, name, out_dir):
    """Bring a game's POPS memory cards over to its Ember folder.

    Copies, never moves: until you have played the Ember version and seen your
    saves, the POPS originals are the only copy that has ever worked. An existing
    card in the destination is left alone - it may hold newer play than the POPS
    one, and silently overwriting a save is not a thing to do on a guess.
    """
    src_dir = os.path.join(vcd_dir, name)
    if not os.path.isdir(src_dir):
        return 0, False
    # A POPS folder is not the same thing as a save. PS1toPOPS makes one for every
    # multi-disc game just to hold DISCS.TXT, and POPStarter only writes a SLOT0.VMC
    # the first time you actually save. So the question is whether a CARD is there,
    # not whether the folder is.
    moved, seen = 0, 0
    for pops_name, ember_name in CARD_PAIRS:
        src = os.path.join(src_dir, pops_name)
        if not os.path.isfile(src):
            src = os.path.join(src_dir, pops_name.lower())
            if not os.path.isfile(src):
                continue
        seen += 1
        dst = os.path.join(out_dir, ember_name)
        if os.path.isfile(dst):
            print("      %s already there, left as it is" % ember_name)
            continue
        if not card_looks_real(src):
            print("      ! %s is not a 128 KiB PS1 card, not copied" % pops_name)
            continue
        try:
            import shutil
            shutil.copy2(src, dst)
            moved += 1
        except OSError as exc:
            print("      ! could not copy %s: %s" % (pops_name, exc))
    if moved:
        print("      %d memory card(s) copied in as MC1/MC2.vmc" % moved)
    return moved, seen > 0


def find_beside_prism(relative):
    """The same file under PRISM\\ on any other drive, or None.

    Ember and its BIOS are usually already sitting on the USB stick from an earlier
    setup. Rather than making you hunt for them, look where they would be.
    """
    import string
    for letter in string.ascii_uppercase:
        candidate = os.path.join(letter + ":\\", "PRISM", relative)
        try:
            if os.path.isfile(candidate):
                return candidate
        except OSError:
            continue
    return None


def ember_runtime(prism, dry):
    """Make sure ember.elf and a bios.bin sit beside the games folder.

    A library of .cue/.bin with no emulator next to it is an afternoon spent for
    nothing: Ember resolves games relative to its OWN folder, so a perfect
    Ember/games/ under a PRISM that has no ember.elf plays exactly no games. Better
    to find that out before converting a hundred discs than after.

    Returns True when Ember can run, False when it cannot.
    """
    root = os.path.join(prism, "Ember")
    ok = True
    for want, sources in (
            ("ember.elf", ("Ember/ember.elf",)),
            # Ember wants the BIOS under one fixed name. A PS1 BIOS dump is 512 KiB
            # whatever it is called, so scph1001.bin from the Bios folder is the same
            # file wearing a different name - copied, not renamed, because Prism and
            # POPStarter still look for it under its real name.
            ("bios.bin", ("Ember/bios.bin", "Bios/scph1001.bin", "Bios/SCPH1001.BIN"))):
        target = os.path.join(root, want)
        if os.path.isfile(target) and os.path.getsize(target) > 0:
            continue
        donor = None
        for rel in sources:
            local = os.path.join(prism, rel.replace("/", os.sep))
            if os.path.isfile(local):
                donor = local
                break
        if donor is None:
            for rel in sources:
                donor = find_beside_prism(rel.replace("/", os.sep))
                if donor is not None:
                    break
        if donor is None:
            print("  ! %s is missing and I could not find one to copy." % want)
            if want == "bios.bin":
                print("    Put your own PS1 BIOS dump there - 512 KiB, from your own")
                print("    console. It is the one file nobody can supply for you.")
            ok = False
            continue
        if dry:
            print("  %s would be copied from %s" % (want, donor))
            continue
        try:
            os.makedirs(root, exist_ok=True)
            import shutil
            shutil.copy2(donor, target)
            print("  %s copied from %s" % (want, donor))
        except OSError as exc:
            print("  ! could not copy %s: %s" % (want, exc))
            ok = False
    return ok


def yes_no(question, default=False):
    d = "Y/n" if default else "y/N"
    try:
        answer = input("  %s [%s]: " % (question, d)).strip().lower()
    except EOFError:
        return default
    if not answer:
        return default
    return answer.startswith(("y", "o"))


def main():
    dry = "--dry" in sys.argv or "--dry-run" in sys.argv
    force = "--force" in sys.argv
    data_only = "--data-only" in sys.argv
    layout = "ember"
    limit = None
    # Pick games by name, so one particular title can be tried before a hundred are
    # converted on the strength of it. Case does not matter and part of the name is
    # enough: --match "wild arms".
    match = None
    for a in sys.argv[1:]:
        if a.startswith("--match="):
            match = a.split("=", 1)[1].strip().lower()
    if "--match" in sys.argv:
        i = sys.argv.index("--match")
        if i + 1 < len(sys.argv):
            match = sys.argv[i + 1].strip().lower()
    for a in sys.argv[1:]:
        if a.startswith("--layout="):
            layout = a.split("=", 1)[1].strip().lower()
        if a.startswith("--limit="):
            limit = int(a.split("=", 1)[1])
    if "--limit" in sys.argv:
        i = sys.argv.index("--limit")
        if i + 1 < len(sys.argv):
            try:
                limit = int(sys.argv[i + 1])
            except ValueError:
                pass

    print(__doc__.strip().splitlines()[0])
    if dry:
        print("Dry run: nothing will be written.")
    print("Press Enter to keep the value in brackets, or type another path.\n")

    vcd_dir = ask("Folder holding your .VCD files", next(
        (d for d in VCD_DIRS if os.path.isdir(d)), VCD_DIRS[0]))
    if not os.path.isdir(vcd_dir):
        print("  Not a folder: %s" % vcd_dir)
        return 1
    src_dir = ask("Batocera PlayStation 1 roms", BATOCERA_PSX)
    if not os.path.isdir(src_dir):
        print("  Not a folder: %s" % src_dir)
        return 1
    # Where the .cue/.bin land. Offered on the SAME drive as the .VCD by default, and
    # that is the important part: deleting a .VCD on one drive frees nothing on another.
    # If the drive that is short of room is the one holding the .VCD files, the output
    # has to go there too or the trade does not happen.
    vcd_drive = os.path.splitdrive(os.path.abspath(vcd_dir))[0]
    same_drive_prism = os.path.join(vcd_drive + "\\", "PRISM")
    prism = ask("Prism folder to write into",
                same_drive_prism if os.path.isdir(same_drive_prism) else PRISM)
    chdman_dir = ask("chdman folder (only for games with no .VCD)", CHDMAN_DIR)
    chdman = find_chdman(chdman_dir) if os.path.isdir(chdman_dir) else None

    out_drive = os.path.splitdrive(os.path.abspath(prism))[0]
    free = free_space(prism)
    print()
    if free is not None:
        print("  %s has %s free." % (out_drive, human(free)))
    if out_drive.lower() != vcd_drive.lower():
        print("  NOTE: the .VCD are on %s and this writes to %s. Deleting a .VCD"
              % (vcd_drive, out_drive))
        print("        will free space on %s, not on %s." % (vcd_drive, out_drive))

    # Before anything is converted: can Ember actually run here?
    if layout == "ember":
        if not ember_runtime(prism, dry):
            print("\n  Stopping: Ember cannot run from %s yet." % prism)
            print("  Converting the library first would only fill the disk with games")
            print("  nothing on that drive can start.")
            return 1
        print()

    # One game at a time, and its .VCD goes as soon as its replacement is on the disk.
    # With a gigabyte free that is the only way through: convert, verify, delete, next.
    # The .VCD is only removed once the .cue and a .bin of believable size exist.
    #
    # Asked with the numbers in it, and defaulting to yes when the disk plainly cannot
    # hold both copies. A question whose honest answer is forced by arithmetic should
    # not be phrased so that pressing Enter picks the impossible one.
    vcd_total = 0
    for entry in os.listdir(vcd_dir):
        if entry.lower().endswith(".vcd"):
            try:
                vcd_total += os.path.getsize(os.path.join(vcd_dir, entry))
            except OSError:
                pass
    tight = free is not None and vcd_total > 0 and free < vcd_total
    if tight:
        print("  Converting these needs about %s, and %s has %s."
              % (human(vcd_total), out_drive, human(free)))
        print("  So each .VCD has to go as its .cue/.bin lands, or the run stops on the")
        print("  first game. The swap costs 1 MiB per game, so the space pays its own way.")
        print("  Nothing is unrecoverable: your .chd library in")
        print("  %s is untouched." % src_dir)
        print()
    delete_vcd = yes_no("Delete each .VCD once its .cue/.bin is written", tight)
    if delete_vcd:
        print("  Deleting as it goes. Memory cards in POPS/<game>/ are NOT touched:")
        print("  those are saves, and they are copied into the Ember folder instead.")
    else:
        print("  Keeping every .VCD.%s"
              % ("  The run will stop when the disk fills." if tight else ""))
    print()

    # What Ember will be asked to play, by the name the artwork already uses.
    wanted = {}
    for entry in sorted(os.listdir(vcd_dir)):
        if entry.lower().endswith(".vcd"):
            wanted.setdefault(norm(entry), stem(entry))
    print("  %d .VCD in %s" % (len(wanted), vcd_dir))

    # What Batocera can give us for them.
    sources = {}
    for root, _dirs, files in os.walk(src_dir):
        for f in sorted(files):
            if os.path.splitext(f)[1].lower() in DISC_EXT:
                sources.setdefault(norm(f), os.path.join(root, f))
    print("  %d disc image(s) in %s" % (len(sources), src_dir))

    # And the .VCD itself, which is the better source when the tool is at hand.
    #
    # pops2cue is the exact inverse of the cue2pops that made these files
    # (github.com/bucanero/pops2cue). Converting from the .VCD needs nothing from
    # Batocera, so the translations and hacks that exist nowhere else convert like any
    # other game - and there is no risk of pairing a game with the wrong regional dump,
    # because the source IS the game.
    used_vcd = 0
    for key, name in wanted.items():
        for ext in (".VCD", ".vcd"):
            p = os.path.join(vcd_dir, name + ext)
            if os.path.isfile(p):
                sources[key] = p
                used_vcd += 1
                break
    print("  %d will be converted from the .VCD itself" % used_vcd)

    if layout == "ember":
        base = os.path.join(prism, "Ember", "games")
    else:
        base = os.path.join(prism, "Roms", "psx")
    print("  Writing to %s\n" % base)

    # Every disc of a set goes in ONE folder. Ember has no disc swapping of its own -
    # it is an open feature request, Gageformer/Ember issue 20 - so the swap has to be
    # Prism's: the discs sit together and Prism hands ember.elf the exact .cue you
    # picked. One folder is also one pair of memory cards for the whole story, which is
    # the real point: a save made on disc 1 has to still be there on disc 2.
    sets, folder_of = {}, {}
    if layout == "ember":
        by_key = {}
        for _key, name in wanted.items():
            by_key.setdefault(set_key(name), []).append(name)
        for _k, members in by_key.items():
            # EVERY member has to say which disc it is. Without that guard the serial
            # trick starts joining games that were only ever sold together: Final
            # Fantasy I [SLES_040.34] and Final Fantasy II [SLES_140.34] share a key
            # and are two different games, and neither calls itself a disc.
            if len(members) < 2:
                continue
            if any(disc_of(m) is None for m in members):
                continue
            members = sorted(members, key=lambda n: disc_of(n) or 99)
            folder = set_name(members[0])
            sets[folder] = members
            for m in members:
                folder_of[m] = folder
        if folder_of:
            print("  %d multi-disc set(s), %d discs sharing a folder"
                  % (len(set(folder_of.values())), len(folder_of)))
            for folder in sorted(set(folder_of.values())):
                members = sorted(sets[folder], key=lambda n: disc_of(n) or 99)
                print("    %s  (%d discs)" % (folder[:56], len(members)))
            print()

    def card_source(name):
        """Whose memory cards a folder should get.

        For a set, disc 1's: that is where you started the story, so that is the
        folder POPStarter has been writing your saves into. Falling back to the
        first disc that actually has a folder keeps a set that was started on
        disc 2 from arriving empty.
        """
        folder = folder_of.get(name)
        if folder is None:
            return name
        members = sorted(sets[folder], key=lambda n: disc_of(n) or 99)
        for m in members:
            if os.path.isdir(os.path.join(vcd_dir, m)):
                return m
        return members[0]

    todo, missing, done, cards, no_card, freed_early = [], [], 0, 0, 0, 0
    for key, name in sorted(wanted.items(), key=lambda kv: kv[1].lower()):
        if match is not None and match not in name.lower():
            continue
        src = sources.get(key)
        if src is None:
            missing.append(name)
            continue
        if layout == "ember":
            out_dir = os.path.join(base, folder_of.get(name, name))
        else:
            out_dir = base
        cue = os.path.join(out_dir, name + ".cue")
        binf = os.path.join(out_dir, name + ".bin")
        vcd = os.path.join(vcd_dir, name + ".VCD")
        if not os.path.isfile(vcd):
            vcd = os.path.join(vcd_dir, name + ".vcd")
        vcd = vcd if os.path.isfile(vcd) else None
        # "Already done" means the .bin is the size it should be, not merely that a
        # .cue is lying about beside it. A raw MODE2/2352 image is always a whole
        # number of 2352-byte sectors, and from a .VCD its size is known exactly.
        if os.path.isfile(cue) and os.path.isfile(binf) and not force:
            have = os.path.getsize(binf)
            want = None
            if src.lower().endswith(".vcd") and os.path.isfile(src):
                want = os.path.getsize(src) - VCD_IMAGE_AT
            if (want is not None and have == want) or (want is None and have % 2352 == 0
                                                       and have > 0):
                done += 1
                # Games converted before the cards were handled: bring their saves
                # over now rather than leaving them behind for good.
                if (layout == "ember" and not dry
                        and os.path.isdir(os.path.join(vcd_dir, name))
                        and not os.path.isfile(os.path.join(out_dir, "MC1.vmc"))):
                    print("  %-58s already converted" % name[:58])
                    got, had = copy_cards(vcd_dir, card_source(name), out_dir)
                    cards += got
                    if not had:
                        no_card += 1
                # A game converted on an earlier run still has its .VCD sitting there.
                # Skipping it as "done" and walking past the .VCD would leave the space
                # locked up for good - which on a disk with 239 MB free is the whole
                # problem. The size test just passed, so the replacement is provably
                # complete: this is the same verification the conversion path uses.
                if delete_vcd and vcd is not None and not dry and want is not None:
                    try:
                        gone = os.path.getsize(vcd)
                        os.remove(vcd)
                        freed_early += gone
                        elf = os.path.join(os.path.dirname(vcd), "XX." + name + ".ELF")
                        if os.path.isfile(elf):
                            os.remove(elf)
                        print("  %-58s done earlier, .VCD removed (%s)"
                              % (name[:58], human(gone)))
                    except OSError as exc:
                        print("      ! could not remove %s: %s" % (vcd, exc))
                continue
            print("  %-58s incomplete, will be redone" % name[:58])
        todo.append((name, src, out_dir, cue, vcd))

    # Ember Beta 1 does not play CD audio - the author has confirmed the path exists
    # but was not wired up for the release (Gageformer/Ember issue 44). A disc with a
    # single track has no CD audio to lose and will sound right; a disc with several
    # will run in silence apart from its sound effects until the next Ember build.
    # --data-only converts the first kind and leaves the second as .VCD, where
    # POPStarter still plays the music today.
    audio = sum(1 for _n, _s, _d, _c, v in todo if v and (vcd_tracks(v) or 1) > 1)
    if audio:
        print("  %d of the %d to convert have CD audio. Ember Beta 1 plays none yet, so"
              % (audio, len(todo)))
        print("  their music will be missing until it does; POPStarter still plays it.")
        print("  --data-only converts only the games that lose nothing.\n")
    if data_only:
        before = len(todo)
        # A set is held back whole or not at all. If disc 3 of four has CD audio and
        # the others do not, converting three of them leaves a game that starts, plays
        # and then cannot be finished - the worst of both worlds, and the kind of thing
        # you only discover twenty hours in.
        loud = set()
        for n, _s, _d, _c, v in todo:
            if v and (vcd_tracks(v) or 1) > 1:
                loud.add(folder_of.get(n, n))
        todo = [t for t in todo if folder_of.get(t[0], t[0]) not in loud]
        split = sum(1 for f in loud if f in sets)
        print("  --data-only: %d held back, %d to do." % (before - len(todo), len(todo)))
        if split:
            print("  (%d of them are whole sets: one disc has CD audio, so none go.)"
                  % split)
        print()

    if limit:
        todo = todo[:limit]

    total = sum(os.path.getsize(s) for _n, s, _d, _c, _v in todo if os.path.isfile(s))
    print("  %d to convert, %d already done, %d with no source" % (len(todo), done, len(missing)))
    from_vcd = sum(1 for _n, s, _d, _c, _v in todo if s.lower().endswith(".vcd"))
    if from_vcd == len(todo):
        print("  Sources total %s; each .bin is 1 MiB smaller than its .VCD, so"
              % human(total))
        print("  deleting as you go is very nearly an even trade.\n")
    else:
        print("  Sources total %s; a .bin from a .chd will be larger than its source.\n"
              % human(total))

    if missing and len(missing) <= 40:
        print("  No disc image found for:")
        for n in missing:
            print("    %s" % n)
        print()

    if chdman is None:
        print("  chdman not found in %s" % chdman_dir)
        print("  Only games whose source is already .cue/.bin can be done.\n")

    ok, failed, freed = 0, 0, freed_early
    for name, src, out_dir, cue, vcd in todo:
        ext = os.path.splitext(src)[1].lower()
        src_size = os.path.getsize(src) if os.path.isfile(src) else 0
        # How big the .bin will be. From a .VCD it is the source less its 1 MiB header,
        # so the swap is very nearly one for one; from a .chd, which is compressed,
        # twice the source is a rough floor rather than a promise.
        if ext == ".vcd":
            need = max(src_size - VCD_IMAGE_AT, 0)
        else:
            need = src_size * 2
        print("  %-58s %s" % (name[:58], os.path.basename(src)))
        if dry:
            continue

        # Room for this one, checked before starting rather than discovered halfway
        # through with a half-written .bin on a full disk.
        room = free_space(prism)
        if room is not None and room < need + 64 * 1024 * 1024:
            print("      ! %s free on %s, this game needs about %s."
                  % (human(room), out_drive, human(need)))
            if not delete_vcd:
                print("      Stopping. Free some room, or answer yes to deleting each")
                print("      .VCD as it is replaced, and run again.")
                break
            print("      Stopping: even with deletions there is not enough room.")
            break

        os.makedirs(out_dir, exist_ok=True)
        if ext == ".vcd":
            try:
                vcd_extract(src, out_dir, name)
            except ValueError as exc:
                print("      ! %s" % exc)
                failed += 1
                continue
            except OSError as exc:
                print("      ! %s" % exc)
                failed += 1
                continue
        elif ext == ".chd":
            if chdman is None:
                failed += 1
                continue
            binf = os.path.join(out_dir, name + ".bin")
            r = subprocess.run([chdman, "extractcd", "-i", src, "-o", cue, "-ob", binf],
                               capture_output=True, text=True)
            if r.returncode != 0 or not os.path.isfile(cue):
                print("      ! chdman: %s" % (r.stderr or "").strip().splitlines()[-1:])
                failed += 1
                continue
        else:
            # Already a .cue/.bin pair, or a single .bin: copy it under the .VCD's name
            # and write a cue for it if there is none.
            import shutil
            if ext == ".cue":
                shutil.copy2(src, cue)
                folder = os.path.dirname(src)
                with open(src, "r", encoding="utf-8", errors="replace") as fh:
                    text = fh.read()
                for track in re.findall(r'FILE\s+"([^"]+)"', text):
                    p = os.path.join(folder, os.path.basename(track))
                    if os.path.isfile(p):
                        shutil.copy2(p, os.path.join(out_dir, os.path.basename(track)))
            else:
                binf = os.path.join(out_dir, name + ".bin")
                shutil.copy2(src, binf)
                with open(cue, "w", encoding="ascii", errors="replace", newline="\n") as fh:
                    fh.write('FILE "%s" BINARY\n  TRACK 01 MODE2/2352\n'
                             "    INDEX 01 00:00:00\n" % (name + ".bin"))
        ok += 1

        # The saves follow the game. Only in the ember layout, where each game has its
        # own folder: in the roms layout every disc shares one folder, so two games'
        # cards would land on each other - there Prism carries them at launch instead.
        if layout == "ember":
            got, had = copy_cards(vcd_dir, card_source(name), out_dir)
            cards += got
            if not had:
                no_card += 1
                print("      no POPS save for this game - Ember will make its own")

        # And only now, with the replacement on the disk and of a believable size, the
        # .VCD goes. Its XX.<name>.ELF launcher goes with it - it launches nothing any
        # more - and the POPS/<game>/ folder stays, because the memory cards are in it.
        if delete_vcd and vcd is not None:
            binf = os.path.join(out_dir, name + ".bin")
            written = os.path.getsize(binf) if os.path.isfile(binf) else 0
            if os.path.isfile(cue) and written > 1024 * 1024:
                size = os.path.getsize(vcd)
                try:
                    os.remove(vcd)
                    freed += size
                    elf = os.path.join(os.path.dirname(vcd), "XX." + name + ".ELF")
                    if os.path.isfile(elf):
                        os.remove(elf)
                    print("      .VCD removed, %s back on %s" % (human(size), out_drive))
                except OSError as exc:
                    print("      ! could not remove the .VCD: %s" % exc)
            else:
                print("      .VCD KEPT: the .bin does not look right (%s)" % human(written))

    print("\n  %d converted, %d failed." % (ok, failed))
    if cards:
        print("  %d memory card(s) copied over. The POPS originals are still in" % cards)
        print("  %s - keep them until you have loaded a save under Ember." % vcd_dir)
    if no_card:
        print("  %d game(s) had no POPS save to bring over." % no_card)
        print("  Nothing was lost: POPStarter writes a SLOT0.VMC only once you have")
        print("  played and saved. Ember makes its own on first run.")
    if freed:
        print("  %s freed by removing .VCD files." % human(freed))
    room = free_space(prism)
    if room is not None:
        print("  %s free on %s now." % (human(room), out_drive))
    if layout == "ember":
        print("  Ember plays them straight from Ember/games/ - nothing is moved at launch.")
    else:
        print("  Prism will move one at a time into Ember/games/ when you start it.")
    if not delete_vcd:
        print("  The .VCD files are untouched: delete them when you are happy.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
