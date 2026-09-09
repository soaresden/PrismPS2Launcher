#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PS1toPOPS.py

Takes a Batocera PlayStation 1 library and produces what POPStarter wants on a
PS2 drive: one .VCD per disc, and one memory card per game carrying the saves
you already had.

    D:\\batocera\\roms\\psx\\Gran Turismo [SCES_009.84].chd
    D:\\batocera\\saves\\psx\\Gran Turismo [SCES_009.84].srm
    D:\\batocera\\saves\\psx\\Gran Turismo [SCES_009.84]_1.mcd
        ->  E:\\POPS\\Gran Turismo [SCES_009.84].VCD
            E:\\POPS\\Gran Turismo [SCES_009.84]\\SLOT0.VMC
            E:\\POPS\\XX.Gran Turismo [SCES_009.84].ELF

Nothing is ever written to the source folders.

--------------------------------------------------------------------------------
ONE COPY OF THE ARTWORK, IN Roms\psx
--------------------------------------------------------------------------------
The .VCD go in POPS\, because that is what POPStarter and OPL expect. The
pictures do NOT go next to them, and that is not an oversight.

Prism scans POPS\ for .VCD and Ember\games\ for .cue folders. Artwork is a
different matter. RUTA_MEDIA looks for a picture under Roms\<alias>\media\
first, then beside the game itself using ORIGEN_DIR. For a .VCD found in
POPS\ the scan fills in ORIGEN but NOT ORIGEN_DIR, so the second lookup never
happens - a cover sitting in POPS\media\covers\ would never be read.

And a PS1 game is the same game whether it is a .cue or a .VCD, so its cover
has no business being filed by dump format. Both share, as EmulationStation
lays it out:

    <launcher>\Roms\psx\media\covers\<name>.png
    <launcher>\Roms\psx\media\screenshots\<name>.png
    <launcher>\Roms\psx\titles.txt

A note is left in the folder explaining where the .VCD live, so the split is
written down rather than deduced.

--------------------------------------------------------------------------------
PREFER THE REAL TOOL
--------------------------------------------------------------------------------
If cue2pops.exe is available, this calls it. It is the reference implementation
and it has been converting people's discs for years; the writer below is a
reimplementation of a DECOMPILATION of it, which is one degree further from the
truth. There is no reason to prefer a careful guess to the thing itself.

The built-in writer exists so the script still works without it, and so the
format is written down somewhere legible rather than living only in a binary.
It also lets cue2pops's output be checked against an independent implementation
of the same spec, which is how you find out that one of them is wrong.

cue2pops takes:  cue2pops input.cue [gap++|gap--|vmode|trainer] output.VCD

  gap++ / gap--  shift every track index by two seconds
  vmode          patch the video mode to NTSC and fix the screen position
  trainer        enable cheats

--------------------------------------------------------------------------------
THE .VCD FORMAT
--------------------------------------------------------------------------------
A .VCD is not a disc image with a different extension. It is a 1 MiB table of
contents followed by the raw 2352-byte sectors of the disc. Rename a .bin to
.VCD and POPS will not mount it.

The layout below is taken from the cue2pops v2.3 source (krHACKen, rebuilt by
Bucanero at github.com/bucanero/pops2cue), not from guesswork.

The first 0x400 bytes are raw-TOC descriptors, 10 bytes each, in the shape of a
SCSI READ TOC descriptor without its leading session byte:

    +0  ADR/Control     0x41 data track, 0x01 audio track
    +1  TNO             always 0
    +2  POINT           track number in BCD, or 0xA0/0xA1/0xA2
    +3  Min  (BCD)
    +4  Sec  (BCD)
    +5  Frame (BCD)
    +6  Zero
    +7  PMIN (BCD)
    +8  PSEC (BCD)
    +9  PFRAME (BCD)

    0x00  POINT A0   first track number in PMIN, disc type 0x20 in PSEC
    0x0A  POINT A1   last track number in PMIN
    0x14  POINT A2   lead-out position in PMIN/PSEC/PFRAME
    0x1E  first track descriptor, then every 10 bytes, up to 99 tracks

Every MSF value is BCD, one byte per field, so there is no endianness to get
wrong. Times in a cue sheet are relative; CD absolute time is two seconds
later, hence the +150 frames.

One quirk is reproduced deliberately. cue2pops adds those two seconds to the
Min/Sec/Frame of every track EXCEPT the first, while adding them to the
PMIN/PSEC/PFRAME of every track without exception. So track 1 ends up with
00:00:00 in one field pair and 00:02:00 in the other. That is what POPS has
been fed for years, so that is what this writes.

Then:

    0x400  magic "kHn\\x22"   (6B 48 6E 22)
    0x408  sector count, u32 little-endian
    0x40C  the same count again
    0x410  zero to the end of the 1 MiB

and from 0x100000, the raw sectors, copied byte for byte. No descrambling, no
EDC or ECC regeneration, no padding at the end. The final size is exactly
1 MiB + the size of the .bin.

--------------------------------------------------------------------------------
THE MEMORY CARDS
--------------------------------------------------------------------------------
This is the easy half: POPStarter's SLOT0.VMC and Batocera's .srm and .mcd are
all the same thing, a raw 128 KiB PlayStation memory card starting with "MC".
Verified on a real POPS card and on 300-odd Batocera saves.

    16 blocks of 8192 bytes
    block 0 is the directory: 64 frames of 128 bytes
        frame 0      header, "MC", XOR checksum of bytes 0..0x7E at 0x7F
        frames 1-15  one entry per save block
        frames 16-35 broken sector list
        frames 36-63 reserved
    blocks 1-15 hold the save data

A directory entry:

    +0x00  u32 LE  state: 0x51 first block of a file, 0x52 middle, 0x53 last,
                          0xA0 free, 0xA1/A2/A3 the same but deleted
    +0x04  u32 LE  file size in bytes, meaningful in the first block only
    +0x08  u16 LE  next block, 0-based over blocks 1..15, 0xFFFF if last
    +0x0A  20      filename, ASCII, null padded, first block only
    +0x7F  1       XOR of bytes 0x00..0x7E

WHY THE CARDS ARE MERGED RATHER THAN COPIED: Batocera keeps both a .srm and a
_1.mcd for most games, and they are NOT always the same file. On the library
this was written against, 137 games had both: 116 identical, and 21 different.
Picking one at random would have silently thrown away 21 games' progress. So
every card found for a game is read, its save files extracted, and all of them
written into a single fresh card. A name that appears twice with identical
contents is stored once; a name that appears twice with DIFFERENT contents is
reported and the first is kept, because two files cannot share one name on a
PlayStation card and renaming one would hide it from the game.

--------------------------------------------------------------------------------
USAGE
--------------------------------------------------------------------------------
    python PS1toPOPS.py                  ask for the folders, then dry run
    python PS1toPOPS.py --go             actually convert
    python PS1toPOPS.py --go --limit 3   the first three games only
    python PS1toPOPS.py --go --saves     memory cards only, no disc conversion
    python PS1toPOPS.py --go --discs     discs only, no memory cards
    python PS1toPOPS.py --go --vmode     ask cue2pops to force NTSC
    python PS1toPOPS.py --go --no-elf    skip the launchers
    python PS1toPOPS.py --yes            take the defaults without asking

Every game gets its XX.<name>.ELF, copied from POPSTARTER.ELF in the
destination folder, without being asked for. A .VCD on its own launches
nothing, so a run that produced only .VCD files would have produced a folder
that does not work.

Discs are converted into WORK_DIR first and only copied to the destination once
they are complete, so nothing half-written ever reaches the PS2 drive.
"""

import os
import re
import shutil
import struct
import subprocess
import sys

# ------------------------------------------------------------------ defaults

PSX_ROMS = r"D:\batocera\roms\psx"
PSX_SAVES = r"D:\batocera\saves\psx"
POPS_DEST = r"E:\POPS"

# Where Prism lives, for the artwork. Blank puts the pictures beside the
# .VCD instead. See ONE COPY OF THE ARTWORK, below.
LAUNCHER_ROOT = r"E:\Prism"
CHDMAN_DIR = r"D:\DOCS\Documents\a-Emulation\Batocera\Windows Tools\CHDMAN (RetroPie User-Friendly)"

# cue2pops.exe, if you have it. POPS-VCD-Manager ships one, in its Common\
# subfolder - point at either that or the folder holding the .exe, both work.
# See PREFER THE REAL TOOL, below.
CUE2POPS_DIR = r"D:\DOCS\Documents\a-Emulation\EmuWindows\Sony-PS2\!PS2 Physique\POPS-VCD-Manager"

WORK_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "PopsWork")

# Leave this much free on the destination rather than filling it to the byte.
KEEP_FREE_BYTES = 1 * 1024 * 1024 * 1024

# ------------------------------------------------------------------ constants

VCD_HEADER_SIZE = 1 << 20
RAW_SECTOR = 2352
VCD_MAGIC = b"kHn\x22"
FRAMES_PER_SECOND = 75
SECONDS_PER_MINUTE = 60
PREGAP_FRAMES = 150          # the two-second offset of CD absolute time
DISC_TYPE_XA = 0x20
CTRL_DATA = 0x41
CTRL_AUDIO = 0x01

CARD_SIZE = 128 * 1024
FRAME_SIZE = 128
BLOCK_SIZE = 8192
DIR_ENTRIES = 15
ST_FIRST, ST_MIDDLE, ST_LAST, ST_FREE = 0x51, 0x52, 0x53, 0xA0

ROM_EXT = (".chd", ".cue", ".iso", ".bin")
SAVE_EXT = (".srm", ".mcd", ".mcr", ".vmc", ".gme", ".ps1")


# ------------------------------------------------------------------ small helpers

def bcd(n):
    return ((n // 10) << 4) | (n % 10)


def lba_to_msf(lba):
    """LBA to (minute, second, frame), each already in BCD."""
    m, rest = divmod(lba, SECONDS_PER_MINUTE * FRAMES_PER_SECOND)
    s, f = divmod(rest, FRAMES_PER_SECOND)
    return bcd(m), bcd(s), bcd(f)


def msf_to_lba(m, s, f):
    return (m * SECONDS_PER_MINUTE + s) * FRAMES_PER_SECOND + f


def human(n):
    for unit in ("B", "KB", "MB"):
        if abs(n) < 1024:
            return "%.0f %s" % (n, unit)
        n /= 1024.0
    return "%.2f GB" % n


def stamp(t):
    if not t:
        return "no date"
    import time
    return time.strftime("%Y-%m-%d %H:%M", time.localtime(t))


def safe_name(name):
    """A name Windows and exFAT will both accept."""
    out = re.sub(r'[<>:"/\\|?*]', "", name)
    out = out.rstrip(" .")
    return out


# POPStarter builds "mass:/POPS/XX.<name>.ELF" and its manual gives 89
# characters for that whole string, which leaves this for the name itself.
# Community testing lands on 73, close enough to agree. A few characters of
# margin are kept because a deeper POPS folder eats into the same budget.
POPS_NAME_MAX = 89 - len("mass:/POPS/XX.") - len(".ELF")

# What survives in a name. Letters, digits, space, dash, underscore, dot and
# square brackets - the brackets because a working POPStarter folder on the
# target drive uses them, which is better evidence than any forum post.
# Parentheses are the ones repeatedly reported as trouble.
POPS_NAME_OK = re.compile(r"[^A-Za-z0-9 _\-\[\].]")

# Parenthesised groups, from the most disposable to the least. Anything about
# a disc number is never dropped: "(Disc 1)" and "(Disc 2)" are the only thing
# telling two files apart, and collapsing them would silently lose a disc.
_DROP_ORDER = (
    re.compile(r"\(\s*[A-Za-z]{2}(?:\s*,\s*[A-Za-z]{2})+\s*\)"),      # (En,Fr,De,Es)
    re.compile(r"\(\s*(?:No EDC|Rev\s*\d+|v\d+(?:\.\d+)*[a-z]?)\s*\)", re.I),
    re.compile(r"\(\s*(?:Europe|USA|Japan|France|Germany|Spain|Italy|World|"
               r"Australia|Asia|Korea|E|U|J)(?:\s*,\s*[A-Za-z]+)*\s*\)", re.I),
    re.compile(r"\((?![^)]*\b[Dd]isc\b)[^)]*\)"),                     # any other
)


def pops_name(stem, budget=POPS_NAME_MAX):
    """A .VCD name POPStarter will accept, as close to the original as it fits.

    Rather than chopping the end off - which would take the [SLES_xxx.xx] with
    it and make two dumps of one game indistinguishable - the parenthesised
    tags come off first, least useful first: language lists, then dump notes,
    then the region. Most names fit long before the title itself is touched.
    """
    # The language list always goes, whatever the length. Its parentheses have
    # to be removed anyway, and what they leave behind is "EnFrDeEsIt", which
    # is longer than nothing and says less.
    name = _DROP_ORDER[0].sub(" ", stem)

    for pattern in _DROP_ORDER[1:]:
        if len(POPS_NAME_OK.sub("", name).strip()) <= budget:
            break
        name = pattern.sub(" ", name)

    name = POPS_NAME_OK.sub("", name)
    name = re.sub(r"\s+", " ", name).strip(" -.")
    if len(name) <= budget:
        return safe_name(name)

    # Still too long. Keep the [ID] - it is what tells two dumps of one game
    # apart - and take words out of the MIDDLE of the title rather than off the
    # end. Chopping the end turned "Final Fantasy Anthology - European Edition
    # - Final Fantasy IV" into "...- Final Fantasy", losing the one word that
    # distinguished it from Final Fantasy V.
    m = re.search(r"\[[^\]]{1,20}\]\s*$", name)
    tail = m.group(0) if m else ""
    head = name[:len(name) - len(tail)].rstrip(" -")
    keep = budget - len(tail) - (1 if tail else 0)
    if keep < 8:
        return safe_name(name[:budget])

    words = head.split(" ")
    while len(" ".join(words)) > keep and len(words) > 2:
        words.pop(len(words) // 2)
    head = " ".join(words).strip(" -")
    if len(head) > keep:
        head = head[:keep].rstrip(" -")
    return safe_name((head + (" " + tail if tail else "")).strip())


def game_id(text):
    """SCES-00984 out of '... [SCES_009.84]' or any of the usual spellings."""
    if not text:
        return None
    m = re.search(r"([A-Za-z]{4})[_\- ]?(\d{3})\.?(\d{2})", text)
    if m:
        return "%s-%s%s" % (m.group(1).upper(), m.group(2), m.group(3))
    return None


def card_game_id(name):
    """The game code inside a save's own name, e.g. BESCES-00984GT -> SCES-00984.

    A PlayStation save is named <2-letter region><game code><whatever>, so the
    code starts at the third character. Searching the whole string instead
    finds the wrong thing: BISLPSP02020AC3ES has no separator, and a loose
    search reads "LPSP-02020" out of the middle of it.
    """
    if not name or len(name) < 6:
        return None
    # ANCHORED at the start of the code, not searched. A loose search slides
    # along until something matches, and on BISLPSP02020AC3ES - where the
    # Japanese naming slips a letter between the code and the number - it slides
    # one character too far and reads "LPSP-02020" instead of "SLPS-02020".
    m = re.match(r"([A-Za-z]{4})[_\- ]?[A-Za-z]?(\d{3})\.?(\d{2})", name[2:])
    if m:
        return "%s-%s%s" % (m.group(1).upper(), m.group(2), m.group(3))
    return game_id(name[2:])


def same_game(a, b):
    """Two game codes for the same game, disc number aside.

    Multi-disc games number their discs in the FIRST digit of the code -
    SLES-01506 is disc 1 and SLES-11506 is disc 2 - while the save stays under
    disc 1's code for the whole game. Comparing the codes whole reports every
    second disc as a mismatch, which is noise, not a warning.
    """
    if not a or not b:
        return True
    ra, na = a.split("-", 1) if "-" in a else (a, "")
    rb, nb = b.split("-", 1) if "-" in b else (b, "")
    return ra == rb and na[-4:] == nb[-4:]


# ------------------------------------------------------------------ cue sheets

class Track(object):
    def __init__(self, num, data, index00, index01):
        self.num = num
        self.data = data
        self.index00 = index00
        self.index01 = index01


def parse_cue(path):
    """Tracks out of a cue sheet, with times as absolute LBA in the merged bin.

    A cue with several FILE statements restarts its times at 00:00:00 for each
    one, so the size of every file seen so far has to be carried along. chdman
    writes a single merged .bin, but a hand-made cue may not.
    """
    tracks, files = [], []
    base = os.path.dirname(path)
    offset_lba = 0
    pending_file = None
    cur = None

    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        lines = fh.read().splitlines()

    for raw in lines:
        line = raw.strip()
        up = line.upper()

        if up.startswith("FILE "):
            m = re.match(r'FILE\s+"(.+)"\s+(\S+)', line, re.I) or \
                re.match(r'FILE\s+(\S+)\s+(\S+)', line, re.I)
            if m is None:
                continue
            name = m.group(1)
            if pending_file is not None:
                offset_lba += pending_file[1]
            full = os.path.join(base, name)
            size = os.path.getsize(full) if os.path.exists(full) else 0
            pending_file = (full, size // RAW_SECTOR)
            files.append(full)

        elif up.startswith("TRACK "):
            m = re.match(r"TRACK\s+(\d+)\s+(\S+)", line, re.I)
            if m is None:
                continue
            if cur is not None:
                tracks.append(cur)
            mode = m.group(2).upper()
            cur = Track(int(m.group(1)), not mode.startswith("AUDIO"), None, None)
            cur._mode = mode
            cur._offset = offset_lba

        elif up.startswith("INDEX ") and cur is not None:
            m = re.match(r"INDEX\s+(\d+)\s+(\d+):(\d+):(\d+)", line, re.I)
            if m is None:
                continue
            lba = msf_to_lba(int(m.group(2)), int(m.group(3)), int(m.group(4)))
            lba += cur._offset
            if int(m.group(1)) == 0:
                cur.index00 = lba
            elif int(m.group(1)) == 1:
                cur.index01 = lba

        elif up.startswith("PREGAP") or up.startswith("POSTGAP"):
            # A gap DECLARED but absent from the .bin, so every following track
            # sits later on the disc than the cue says. chdman never writes
            # one; a hand-made cue might. Recorded so the caller can refuse the
            # file rather than build a table of contents that points into the
            # middle of a track.
            tracks_warn.append(line)

    if cur is not None:
        tracks.append(cur)
    return tracks, files


tracks_warn = []


# ------------------------------------------------------------------ the VCD

def build_vcd_header(tracks, sector_count):
    """The 1 MiB table of contents. See the module docstring for the layout."""
    h = bytearray(VCD_HEADER_SIZE)
    first, last = tracks[0], tracks[-1]
    ctrl_last = CTRL_DATA if last.data else CTRL_AUDIO

    # POINT A0 - first track, and the disc type.
    h[0x00] = CTRL_DATA
    h[0x02] = 0xA0
    h[0x07] = bcd(first.num)
    h[0x08] = DISC_TYPE_XA

    # POINT A1 - last track.
    h[0x0A] = ctrl_last
    h[0x0C] = 0xA1
    h[0x11] = bcd(last.num)

    # POINT A2 - lead-out.
    h[0x14] = ctrl_last
    h[0x16] = 0xA2
    m, s, f = lba_to_msf(sector_count + PREGAP_FRAMES)
    h[0x1A] = 0
    h[0x1B], h[0x1C], h[0x1D] = m, s, f

    p = 0x1E
    for i, t in enumerate(tracks):
        if p + 10 > 0x400:
            raise ValueError("more than 99 tracks")
        h[p + 0] = CTRL_DATA if t.data else CTRL_AUDIO
        h[p + 2] = bcd(t.num)

        # Min/Sec/Frame: the pregap if the track has one, else the track start.
        # Track 1 keeps the raw cue value; cue2pops does not add the two
        # seconds there, and this reproduces it on purpose.
        start = t.index00 if t.index00 is not None else t.index01
        if i > 0:
            start += PREGAP_FRAMES
        m, s, f = lba_to_msf(start)
        h[p + 3], h[p + 4], h[p + 5] = m, s, f

        # PMIN/PSEC/PFRAME: the track start, always in absolute time.
        m, s, f = lba_to_msf(t.index01 + PREGAP_FRAMES)
        h[p + 7], h[p + 8], h[p + 9] = m, s, f
        p += 10

    h[0x400:0x404] = VCD_MAGIC
    h[0x408:0x40C] = struct.pack("<I", sector_count)
    h[0x40C:0x410] = struct.pack("<I", sector_count)
    return bytes(h)


def write_vcd(dest, header, bin_paths):
    with open(dest, "wb") as out:
        out.write(header)
        for b in bin_paths:
            with open(b, "rb") as src:
                shutil.copyfileobj(src, out, 8 << 20)


def find_tool(folder, needle, depth=3):
    """A tool called something like <needle> anywhere under a folder.

    Two reasons this looks in subfolders instead of just the folder given.
    Names are not exact - the chdman here is called "a-chdman.exe" - and people
    point at the folder they think of as the program's, which is the one with
    the .exe in it, not the Common\\ subfolder where the helper actually lives.
    Better to find it than to say it is missing while it sits one level down.
    """
    if not folder or not os.path.isdir(folder):
        return None
    root_depth = folder.rstrip("\\/").count(os.sep)
    found = []
    for root, dirs, names in os.walk(folder):
        if root.count(os.sep) - root_depth >= depth:
            dirs[:] = []
        for n in names:
            low = n.lower()
            if needle in low and (low.endswith(".exe") or "." not in low):
                found.append(os.path.join(root, n))
    if not found:
        return None
    # Shallowest first, then shortest name: prefers "chdman.exe" in the folder
    # given over "chdman-old.exe" three levels down.
    found.sort(key=lambda p: (p.count(os.sep), len(os.path.basename(p))))
    return found[0]


def find_chdman(folder):
    return find_tool(folder, "chdman")


def chd_to_bincue(chdman, chd, workdir):
    """Extract a CHD to cue+bin. Returns the path of the cue."""
    stem = os.path.splitext(os.path.basename(chd))[0]
    cue = os.path.join(workdir, stem + ".cue")
    binf = os.path.join(workdir, stem + ".bin")
    for p in (cue, binf):
        if os.path.exists(p):
            os.remove(p)
    cmd = [chdman, "extractcd", "-i", chd, "-o", cue, "-ob", binf, "-f"]
    r = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if r.returncode != 0 or not os.path.exists(cue):
        msg = r.stdout.decode("utf-8", "replace").strip().splitlines()
        return None, (msg[-1] if msg else "chdman failed")
    return cue, None


def chd_expected_sectors(path):
    """Sector count straight from the CHD header, without decompressing."""
    try:
        with open(path, "rb") as f:
            head = f.read(64)
    except OSError:
        return None
    if head[:8] != b"MComprHD":
        return None
    ver = struct.unpack(">I", head[12:16])[0]
    if ver != 5:
        return None
    logical = struct.unpack(">Q", head[32:40])[0]
    unit = struct.unpack(">I", head[60:64])[0]
    if unit == 0:
        return None
    return logical // unit


# ------------------------------------------------------------------ memory cards

def xor127(frame):
    x = 0
    for b in frame[:0x7F]:
        x ^= b
    return x


def is_card(data):
    return len(data) == CARD_SIZE and data[:2] == b"MC"


def card_files(data):
    """Every save on a card: name, size, and its raw blocks.

    Only chains that start at 0x51 are followed. Deleted files (0xA1..0xA3) are
    left alone: the player deleted them, and bringing them back would be a
    surprise, not a service.
    """
    out = []
    for i in range(1, DIR_ENTRIES + 1):
        e = data[i * FRAME_SIZE:(i + 1) * FRAME_SIZE]
        if int.from_bytes(e[0:4], "little") != ST_FIRST:
            continue
        name = e[10:30].split(b"\x00")[0].decode("ascii", "replace")
        size = int.from_bytes(e[4:8], "little")
        chain, cur, seen = [], i, set()
        while cur is not None and cur not in seen and 1 <= cur <= DIR_ENTRIES:
            seen.add(cur)
            chain.append(cur)
            ee = data[cur * FRAME_SIZE:(cur + 1) * FRAME_SIZE]
            nxt = int.from_bytes(ee[8:10], "little")
            cur = None if nxt == 0xFFFF else nxt + 1
        blocks = b"".join(data[c * BLOCK_SIZE:(c + 1) * BLOCK_SIZE] for c in chain)
        out.append({"name": name, "size": size, "n": len(chain), "data": blocks})
    return out


def blank_card(template=None):
    """An empty card. The skeleton of a real one when we have it.

    Frames 16 to 63 - the broken sector list and the reserved area - are copied
    from a genuine card rather than invented, and the directory and the data
    blocks are cleared. Falls back to a plausible layout when no template is
    available.
    """
    if template is not None and is_card(template):
        card = bytearray(template)
    else:
        card = bytearray(CARD_SIZE)
        card[0:2] = b"MC"
        card[0x7F] = xor127(card[0:FRAME_SIZE])
        for i in range(16, 36):
            e = bytearray(FRAME_SIZE)
            e[0:4] = b"\xff\xff\xff\xff"
            e[8:10] = b"\xff\xff"
            e[0x7F] = xor127(e)
            card[i * FRAME_SIZE:(i + 1) * FRAME_SIZE] = e

    card[0:2] = b"MC"
    card[2:0x7F] = bytes(0x7F - 2)
    card[0x7F] = xor127(card[0:FRAME_SIZE])

    for i in range(1, DIR_ENTRIES + 1):
        e = bytearray(FRAME_SIZE)
        e[0:4] = struct.pack("<I", ST_FREE)
        e[8:10] = b"\xff\xff"
        e[0x7F] = xor127(e)
        card[i * FRAME_SIZE:(i + 1) * FRAME_SIZE] = e
        card[i * BLOCK_SIZE:(i + 1) * BLOCK_SIZE] = bytes(BLOCK_SIZE)
    return card


def merge_cards(sources, template=None):
    """One card holding the saves of all the others.

    THE NEWEST CARD WINS A TIE, and this is the part that matters.

    Two cards can hold the same save under the same name with different
    contents, and only one of them can go on the result: a PlayStation card
    cannot have two files with one name, and renaming one would hide it from
    the game. On the library this was written against there were three such
    cases, and the dates were not close - Parasite Eve had a 2024 .srm against
    a 2017 .mcd. Taking whichever came first in the directory listing would
    have quietly rolled that back by seven years.

    So the cards are read newest first, and the first version of a name wins.
    The loser is reported with both dates rather than dropped in silence.

    Returns (card, report) where report lists what was taken, what was already
    there, and what did not fit.
    """
    card = blank_card(template)
    report = {"kept": [], "duplicate": [], "conflict": [], "overflow": []}

    ordered = sorted(sources, key=lambda s: s.get("mtime", 0), reverse=True)

    chosen = []
    by_name = {}
    for src in ordered:
        for f in card_files(src["files"]):
            prev = by_name.get(f["name"])
            if prev is None:
                by_name[f["name"]] = (f, src)
                chosen.append(f)
            elif prev[0]["data"] == f["data"]:
                report["duplicate"].append((f["name"], src["path"]))
            else:
                report["conflict"].append((f["name"], prev[1], src))

    free = 1
    for f in chosen:
        n = f["n"]
        if free + n - 1 > DIR_ENTRIES:
            report["overflow"].append((f["name"], n))
            continue
        raw = f["name"].encode("ascii", "replace")[:20]
        for k in range(n):
            idx = free + k
            e = bytearray(FRAME_SIZE)
            if n == 1:
                state = ST_FIRST
            elif k == 0:
                state = ST_FIRST
            elif k == n - 1:
                state = ST_LAST
            else:
                state = ST_MIDDLE
            e[0:4] = struct.pack("<I", state)
            if k == 0:
                e[4:8] = struct.pack("<I", f["size"] or n * BLOCK_SIZE)
                e[10:10 + len(raw)] = raw
            # The link is 0-based over blocks 1..15, so the value stored for a
            # block at frame idx pointing at frame idx+1 is simply idx.
            e[8:10] = b"\xff\xff" if k == n - 1 else struct.pack("<H", idx)
            e[0x7F] = xor127(e)
            card[idx * FRAME_SIZE:(idx + 1) * FRAME_SIZE] = e
            card[idx * BLOCK_SIZE:(idx + 1) * BLOCK_SIZE] = \
                f["data"][k * BLOCK_SIZE:(k + 1) * BLOCK_SIZE]
        report["kept"].append((f["name"], n))
        free += n
    return card, report


# ------------------------------------------------------------------ pairing

def save_key(filename):
    """The name a save and its game have in common.

    Batocera writes '<game>.srm' and '<game>_1.mcd' for the same game, and
    sometimes '<game>_2.mcd'. The trailing _N is a slot number, not part of the
    title.
    """
    stem = os.path.splitext(filename)[0]
    return re.sub(r"_\d+$", "", stem).strip().lower()


def collect_saves(folder):
    """Every usable card in the folder, indexed by game key.

    Files that are not 128 KiB cards are skipped: the save-state files Batocera
    leaves alongside are a few hundred bytes and are not memory cards at all.
    """
    out, skipped = {}, []
    if not os.path.isdir(folder):
        return out, skipped
    for name in sorted(os.listdir(folder)):
        if not name.lower().endswith(SAVE_EXT):
            continue
        path = os.path.join(folder, name)
        try:
            with open(path, "rb") as f:
                data = f.read(CARD_SIZE + 1)
        except OSError:
            continue
        if not is_card(data[:CARD_SIZE]) or len(data) != CARD_SIZE:
            skipped.append((name, len(data)))
            continue
        try:
            mtime = os.path.getmtime(path)
        except OSError:
            mtime = 0
        out.setdefault(save_key(name), []).append(
            {"path": path, "files": data[:CARD_SIZE], "mtime": mtime})
    return out, skipped


def collect_roms(folder):
    """Discs to convert, and the multi-disc groups they belong to."""
    discs, groups = [], {}
    for root, _dirs, names in os.walk(folder):
        for n in sorted(names):
            low = n.lower()
            if low.endswith(".m3u"):
                path = os.path.join(root, n)
                try:
                    with open(path, "r", encoding="utf-8", errors="replace") as fh:
                        members = [l.strip() for l in fh if l.strip()
                                   and not l.startswith("#")]
                except OSError:
                    continue
                key = os.path.splitext(n)[0]
                groups[key] = [os.path.normpath(os.path.join(root, m)) for m in members]
            elif low.endswith(ROM_EXT):
                if low.endswith(".bin"):
                    # A .bin with a .cue beside it is handled through the cue.
                    if os.path.exists(os.path.join(root, n[:-4] + ".cue")):
                        continue
                discs.append(os.path.join(root, n))
    return discs, groups


# ------------------------------------------------------------------ conversion

def find_cue2pops(folder):
    return find_tool(folder, "cue2pops")


def run_cue2pops(exe, cue, dest, extra):
    """The reference converter. Returns None on success, or the reason."""
    cmd = [exe, cue] + list(extra) + [dest]
    try:
        r = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    except OSError as e:
        return str(e)
    if r.returncode != 0 or not os.path.exists(dest):
        out = r.stdout.decode("utf-8", "replace").strip().splitlines()
        return out[-1] if out else "cue2pops failed"
    return None


def prepare_cue(path, chdman, workdir):
    """Whatever the disc is, get a cue sheet out of it. (cue, cleanup) or (None, reason)."""
    low = path.lower()
    if low.endswith(".chd"):
        if chdman is None:
            return None, "chdman not found"
        cue, err = chd_to_bincue(chdman, path, workdir)
        if cue is None:
            return None, err
        return cue, None
    if low.endswith(".cue"):
        return path, None
    return None, "no cue sheet"


def convert_disc(path, chdman, workdir, cue=None):
    """One disc to (header, [bin parts], sector_count) or (None, reason).

    Only used when cue2pops is not available.
    """
    low = path.lower()
    del tracks_warn[:]

    if cue is not None:
        pass
    elif low.endswith(".chd"):
        if chdman is None:
            return None, "chdman not found"
        cue, err = chd_to_bincue(chdman, path, workdir)
        if cue is None:
            return None, err
    elif low.endswith(".cue"):
        cue = path
    elif low.endswith((".bin", ".iso")):
        size = os.path.getsize(path)
        if size % RAW_SECTOR == 0:
            t = Track(1, True, None, 0)
            return (build_vcd_header([t], size // RAW_SECTOR), [path],
                    size // RAW_SECTOR), None
        if size % 2048 == 0:
            return None, ("2048-byte sectors: POPS needs raw 2352 and this "
                          "cannot be rebuilt losslessly")
        return None, "size is not a whole number of sectors"
    else:
        return None, "unknown format"

    tracks, files = parse_cue(cue)
    if tracks_warn:
        return None, ("the cue declares %s, a gap that is not in the image; "
                      "every later track would be misplaced" % tracks_warn[0].split()[0])
    if not tracks:
        return None, "no track in the cue sheet"
    if tracks[0].index01 is None:
        return None, "track 1 has no INDEX 01"
    if tracks[0].index01 != 0:
        return None, "track 1 does not start at 00:00:00"
    missing = [f for f in files if not os.path.exists(f)]
    if missing:
        return None, "missing: " + os.path.basename(missing[0])

    total = sum(os.path.getsize(f) for f in files)
    if total % RAW_SECTOR != 0:
        return None, "the image is not a whole number of 2352-byte sectors"
    sectors = total // RAW_SECTOR
    return (build_vcd_header(tracks, sectors), files, sectors), None


# ------------------------------------------------------------------ main

def free_space(path):
    """Bytes free on the volume holding a path, walking up if it is not there yet."""
    p = os.path.abspath(path)
    while p and not os.path.exists(p):
        parent = os.path.dirname(p)
        if parent == p:
            return None
        p = parent
    try:
        return shutil.disk_usage(p).free
    except OSError:
        return None


def vcd_size_of(path):
    """What the .VCD will weigh, without converting anything."""
    if path.lower().endswith(".chd"):
        sectors = chd_expected_sectors(path)
        return (VCD_HEADER_SIZE + sectors * RAW_SECTOR) if sectors else None
    try:
        return VCD_HEADER_SIZE + os.path.getsize(path)
    except OSError:
        return None


# ------------------------------------------------------------------ artwork

# The PS2 manual asks for artwork below 320x240, and Prism reads
# "<folder>/media/covers/<name>.png" and ".../media/screenshots/<name>.png"
# beside the games. MediaCopier.py already builds exactly that for the ROM
# folders; this does the same for the VCDs, from the same gamelist.
MEDIA_MAX = (320, 240)

# Which gamelist tag becomes which picture, best first. "cartridge" is the disc
# art on a PlayStation scrape, which is what MediaCopier uses for covers too.
COVER_TAGS = ("cartridge", "boxart", "box", "image", "mix", "thumbnail")
SCREEN_TAGS = ("screenshot", "thumbnail", "image", "mix", "titleshot")


def load_gamelist(roms_folder):
    """stem -> {"cover": path, "screen": path} out of gamelist.xml."""
    index = {}
    path = os.path.join(roms_folder, "gamelist.xml")
    if not os.path.isfile(path):
        return index
    try:
        import xml.etree.ElementTree as ET
        root = ET.parse(path).getroot()
    except Exception:
        return index

    def resolve(rel):
        if not rel:
            return None
        rel = rel.strip().lstrip("./\\").replace("/", os.sep).replace("\\", os.sep)
        full = os.path.join(roms_folder, rel)
        return full if os.path.isfile(full) else None

    for game in root.findall("game"):
        p = game.findtext("path") or ""
        stem = os.path.splitext(os.path.basename(p.strip().rstrip("/\\")))[0]
        if not stem:
            continue
        entry = {}
        for key, tags in (("cover", COVER_TAGS), ("screen", SCREEN_TAGS)):
            for t in tags:
                got = resolve(game.findtext(t))
                if got:
                    entry[key] = got
                    break
        if entry:
            index[stem] = entry
    return index


def copy_art(src, dest):
    """One picture, fitted and re-encoded. True if it was written.

    Re-encoded to RGBA because the PS2 loader will not read every PNG variant a
    scraper produces - palette images with no alpha are the usual casualty -
    and scaled down because the manual asks for it. Without Pillow the file is
    copied as-is, which works often enough to be worth doing.
    """
    if os.path.exists(dest):
        return False
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    try:
        from PIL import Image
    except ImportError:
        shutil.copyfile(src, dest)
        return True
    try:
        im = Image.open(src)
        im = im.convert("RGBA")
        if im.width > MEDIA_MAX[0] or im.height > MEDIA_MAX[1]:
            im.thumbnail(MEDIA_MAX, Image.LANCZOS)
        im.save(dest, "PNG", optimize=True)
        return True
    except Exception:
        try:
            shutil.copyfile(src, dest)
            return True
        except OSError:
            return False


def place_art(art_folder, name, entry):
    """Cover and screenshot for one game. Returns how many were written."""
    if not entry:
        return 0
    n = 0
    for key, sub in (("cover", "covers"), ("screen", "screenshots")):
        src = entry.get(key)
        if not src:
            continue
        if copy_art(src, os.path.join(art_folder, "media", sub, name + ".png")):
            n += 1
    return n


POPS_NOTE = """\
Roms/psx - artwork and titles for EVERY PlayStation 1 game
==========================================================

One folder for both dump formats, as EmulationStation lays it out. A PS1
game is a .VCD in the drive's POPS folder, or a .cue + .bin folder in
Ember/games. It is the same game with the same cover, so its picture is kept
once, here, whichever of those it happens to be:

    media/covers/<file name without extension>.png
    media/screenshots/<file name without extension>.png
    titles.txt

The name of the picture matches the file it belongs to, so a .cue and a
.VCD of one game each need their own copy under their own name - that part
cannot be shared, the names differ.


Where the games themselves live
-------------------------------
The .VCD are NOT here. They are in the POPS folder of the drive, which is
where POPStarter and OPL look for them and where POPStarter creates each
game's memory card:

    POPS/<name>.VCD
    POPS/XX.<name>.ELF        a renamed copy of POPSTARTER.ELF
    POPS/<name>/SLOT0.VMC     the memory card
    POPS/<name>/DISCS.TXT     for a multi-disc game

Ember games are one folder each under Ember/games/<Game>/, with the .cue
and .bin inside; the folder name is the game's name in the list.


Why the artwork cannot live next to the .VCD
--------------------------------------------
RUTA_MEDIA looks in Roms/<alias>/media/ first, then falls back to the
folder the game was found in, using ORIGEN_DIR. The scan of POPS/ fills in
ORIGEN but not ORIGEN_DIR, so that fallback never fires: a cover placed in
POPS/media/covers/ would never be read. Hence one copy, here, in the folder
that is actually searched.

Written by HelperScripts/PS1toPOPS.py
"""


def write_pops_note(art_folder):
    os.makedirs(art_folder, exist_ok=True)
    path = os.path.join(art_folder, ".INFO - psx.txt")
    if not os.path.exists(path):
        with open(path, "w", encoding="utf-8") as f:
            f.write(POPS_NOTE)


def cleanup_work(workdir, source):
    """The .cue and .bin chdman left behind for this disc."""
    stem = os.path.splitext(os.path.basename(source))[0]
    for ext in (".cue", ".bin"):
        p = os.path.join(workdir, stem + ext)
        if os.path.exists(p):
            try:
                os.remove(p)
            except OSError:
                pass
    # Multi-bin extractions are named "<stem> (Track 2).bin" and friends.
    try:
        for n in os.listdir(workdir):
            if n.startswith(stem) and n.lower().endswith(".bin"):
                os.remove(os.path.join(workdir, n))
    except OSError:
        pass


def write_discs_txt(folder, vcd_names):
    """POPStarter's multi-disc list.

    One .VCD name per line, WITH the extension, and no line feed after the last
    one. Both of those are load-bearing - POPS-VCD-Manager has a changelog entry
    for each, having got them wrong once.
    """
    text = "\n".join(vcd_names)
    with open(os.path.join(folder, "DISCS.TXT"), "wb") as f:
        f.write(text.encode("ascii", "replace"))


def ask(label, default, assume_yes):
    if assume_yes:
        print("  %-26s %s" % (label + ":", default))
        return default
    try:
        got = input("  %s [%s]: " % (label, default)).strip().strip('"')
    except EOFError:
        return default
    return got or default


def main(argv):
    opts = set(a for a in argv[1:] if a.startswith("--"))
    go = "--go" in opts
    assume_yes = "--yes" in opts
    do_saves = "--discs" not in opts
    do_discs = "--saves" not in opts
    make_elf = "--no-elf" not in opts
    limit = None
    args = argv[1:]
    for i, a in enumerate(args):
        if a == "--limit" and i + 1 < len(args):
            try:
                limit = int(args[i + 1])
            except ValueError:
                pass
        elif a.startswith("--limit="):
            try:
                limit = int(a.split("=", 1)[1])
            except ValueError:
                pass

    print(__doc__.strip().splitlines()[0])
    print()
    roms = ask("Batocera PS1 roms folder", PSX_ROMS, assume_yes)
    saves = ask("Batocera PS1 saves folder", PSX_SAVES, assume_yes)
    dest = ask("Final POPS folder", POPS_DEST, assume_yes)
    chdmandir = ask("chdman folder", CHDMAN_DIR, assume_yes)
    c2pdir = ask("cue2pops folder (blank = built-in)", CUE2POPS_DIR, assume_yes)
    lroot = ask("Prism folder, for artwork", LAUNCHER_ROOT, assume_yes)
    print()

    if not os.path.isdir(roms):
        print("The roms folder does not exist: %s" % roms)
        return 1

    chdman = find_chdman(chdmandir)
    cue2pops = find_cue2pops(c2pdir) if c2pdir else None
    vcd_opts = []
    if "--vmode" in opts:
        vcd_opts.append("vmode")
    if "--trainer" in opts:
        vcd_opts.append("trainer")

    discs, groups = collect_roms(roms)
    cards, skipped = collect_saves(saves)
    art = load_gamelist(roms) if "--no-art" not in opts else {}

    print("%d disc(s), %d game(s) with a memory card, %d multi-disc group(s)"
          % (len(discs), len(cards), len(groups)))
    # One home for the pictures: the folder Prism actually searches for
    # PlayStation art, whichever drive the .VCD ended up on.
    art_dest = os.path.join(lroot, "Roms", "psx") if lroot else dest

    if art:
        n_cov = sum(1 for v in art.values() if "cover" in v)
        n_scr = sum(1 for v in art.values() if "screen" in v)
        try:
            import PIL  # noqa: F401
            how = "resized to %dx%d and re-encoded" % MEDIA_MAX
        except ImportError:
            how = "copied as-is (install Pillow to resize and re-encode)"
        print("gamelist.xml: %d cover(s), %d screenshot(s), %s"
              % (n_cov, n_scr, how))
        print("artwork:  %s" % os.path.join(art_dest, "media"))
        if art_dest != dest:
            print("          (one copy, in the only folder the launcher reads "
                  "for PS1 art)")
    elif "--no-art" not in opts:
        print("No gamelist.xml in the roms folder, so no artwork.")
    if skipped:
        print("%d file(s) in the saves folder are not 128 KiB cards and were "
              "ignored (save states)." % len(skipped))
    if chdman:
        print("chdman:   %s" % chdman)
    elif any(d.lower().endswith(".chd") for d in discs):
        print("chdman NOT FOUND in %s - .chd cannot be converted." % chdmandir)
    if cue2pops:
        print("cue2pops: %s%s"
              % (cue2pops, ("  options: " + " ".join(vcd_opts)) if vcd_opts else ""))
    else:
        print("cue2pops not found - using the built-in writer. It follows the same")
        print("spec, but the real tool is the one that has been proven on hardware.")

    starter = None
    for cand in (os.path.join(dest, "POPSTARTER.ELF"),
                 os.path.join(os.path.dirname(dest.rstrip("\\/")), "POPSTARTER.ELF")):
        if os.path.isfile(cand):
            starter = cand
            break
    if starter:
        print("launcher: %s  -> one XX.<name>.ELF per game" % starter)
    elif make_elf:
        print("POPSTARTER.ELF not in %s - the .VCD will be made but nothing will"
              % dest)
        print("be able to launch them until it is there.")
    # A .VCD is not compressed, so a library of .chd roughly doubles on the way
    # out. Worth knowing before starting, and worth checking before each file
    # rather than discovering it with a half-written image on a full drive.
    todo = [d for d in discs if not os.path.exists(
        os.path.join(dest, pops_name(os.path.splitext(os.path.basename(d))[0]) + ".VCD"))]
    total = sum(vcd_size_of(d) or 0 for d in todo)
    room = free_space(dest)
    print("%d disc(s) still to convert, about %s of .VCD"
          % (len(todo), human(total)))
    if room is not None:
        print("Destination has %s free%s" % (
            human(room),
            "" if room - KEEP_FREE_BYTES >= total
            else "  - NOT ENOUGH, the smallest games will be done first"))
    work_room = free_space(WORK_DIR)
    if work_room is not None and todo:
        biggest = max(vcd_size_of(d) or 0 for d in todo)
        if work_room < biggest * 2:
            print("Scratch folder has only %s free; the largest game needs about %s "
                  "there while it converts." % (human(work_room), human(biggest)))

    if not go:
        print("\nDRY RUN. Nothing will be written. Add --go to convert.")
    print("-" * 78)

    # Which discs belong to a multi-disc set, so their saves can be shared.
    disc_group = {}
    for key, members in groups.items():
        for m in members:
            disc_group[os.path.normpath(m).lower()] = key

    if go:
        os.makedirs(WORK_DIR, exist_ok=True)
        os.makedirs(dest, exist_ok=True)
        if art and art_dest != dest:
            write_pops_note(art_dest)

    template = None
    for lst in cards.values():
        template = lst[0]["files"]
        break

    done = failed = full = elfs = 0
    # Alphabetical normally, but smallest first when the drive cannot hold
    # everything: that way it holds as many games as possible instead of
    # stopping on the first oversized one and leaving the rest untried.
    orden = sorted(discs)
    if go and room is not None and total and room - KEEP_FREE_BYTES < total:
        orden = sorted(discs, key=lambda d: vcd_size_of(d) or 0)
    for i, path in enumerate(orden):
        if limit is not None and i >= limit:
            print("\n(stopping after %d, --limit)" % limit)
            break
        stem = os.path.splitext(os.path.basename(path))[0]
        name = pops_name(stem)
        gid = game_id(stem)
        vcd = os.path.join(dest, name + ".VCD")

        # --- the memory card ------------------------------------------------
        key = stem.strip().lower()
        group = disc_group.get(os.path.normpath(path).lower())
        wanted = [key]
        if group is not None:
            wanted = [os.path.splitext(os.path.basename(m))[0].strip().lower()
                      for m in groups[group]]
        sources = []
        for w in wanted:
            sources.extend(cards.get(w, []))

        # Most cards in a Batocera library are empty: one is created the first
        # time a game is launched, whether or not anything is ever saved. On
        # the library this was written against, 271 of 357 held nothing. They
        # are not worth a folder on the PS2 drive - POPStarter makes its own
        # SLOT0.VMC on first boot.
        card, rep, has_save = None, None, False
        card_note = "no save"
        if sources:
            card, rep = merge_cards(sources, template)
            has_save = bool(rep["kept"])
            if not has_save:
                card_note = "no save (%d empty card(s))" % len(sources)
            else:
                bits = ["%d file(s) from %d card(s)"
                        % (len(rep["kept"]), len(sources))]
                if rep["conflict"]:
                    bits.append("%d CONFLICT" % len(rep["conflict"]))
                if rep["overflow"]:
                    bits.append("%d DID NOT FIT" % len(rep["overflow"]))
                card_note = ", ".join(bits)
            # A card whose internal name does not carry this game's ID is a
            # save filed under the wrong title; say so rather than ship it.
            if gid:
                inside = set()
                for n, _k in rep["kept"]:
                    g = card_game_id(n)
                    if g:
                        inside.add(g)
                if inside and not any(same_game(gid, g) for g in inside):
                    card_note += "  [ID mismatch: card says %s]" % "/".join(sorted(inside))

        # --- the disc -------------------------------------------------------
        if not do_discs:
            print("%-52s %s" % (stem[:52], card_note))
            continue

        # Artwork goes in beside the .VCD whether or not the disc was converted
        # this time round, so a second run fills in what a first one missed.
        if go and art:
            place_art(art_dest, name, art.get(stem))

        exists = os.path.exists(vcd)
        if exists and go:
            print("%-52s already there" % stem[:52])
        elif not go:
            expect = chd_expected_sectors(path)
            size = (VCD_HEADER_SIZE + expect * RAW_SECTOR) if expect else None
            print("%-52s -> %s   %s   %s"
                  % (stem[:52], name + ".VCD",
                     human(size) if size else "?", card_note))
        else:
            # Checked per file, not once at the start: the free space changes
            # as we go, and stopping cleanly beats filling the drive and
            # leaving a truncated image that looks like a real one.
            need = vcd_size_of(path) or 0
            room = free_space(dest)
            if room is not None and need and room - need < KEEP_FREE_BYTES:
                print("%-52s SKIPPED, no room: needs %s, %s free"
                      % (stem[:52], human(need), human(room)))
                full += 1
                continue

            tmp = os.path.join(WORK_DIR, name + ".VCD")
            cue, err = prepare_cue(path, chdman, WORK_DIR)
            how = ""
            if cue is None:
                # Not a disc we can get a cue out of - a bare .bin or .iso goes
                # straight through the built-in writer.
                built, err = convert_disc(path, chdman, WORK_DIR)
                if built is None:
                    print("%-52s FAILED: %s" % (stem[:52], err))
                    failed += 1
                    continue
                header, parts, _sectors = built
                write_vcd(tmp, header, parts)
                how = "built-in"
            elif cue2pops is not None:
                err = run_cue2pops(cue2pops, cue, tmp, vcd_opts)
                if err is not None:
                    print("%-52s FAILED: %s" % (stem[:52], err))
                    failed += 1
                    cleanup_work(WORK_DIR, path)
                    continue
                how = "cue2pops"
            else:
                built, err = convert_disc(path, chdman, WORK_DIR, cue=cue)
                if built is None:
                    print("%-52s FAILED: %s" % (stem[:52], err))
                    failed += 1
                    cleanup_work(WORK_DIR, path)
                    continue
                header, parts, _sectors = built
                write_vcd(tmp, header, parts)
                how = "built-in"

            shutil.move(tmp, vcd)
            cleanup_work(WORK_DIR, path)
            # The launcher goes down with the game, not in a later pass: stop
            # the script halfway and what is on the drive still works.
            if make_elf and starter is not None:
                elf = os.path.join(dest, "XX." + name + ".ELF")
                if not os.path.exists(elf):
                    try:
                        shutil.copyfile(starter, elf)
                        elfs += 1
                    except OSError as e:
                        print("      could not write %s: %s" % (os.path.basename(elf), e))
            print("%-52s ok (%s)  %s   %s"
                  % (stem[:52], how, human(os.path.getsize(vcd)), card_note))
            done += 1

        # --- write the card next to the disc --------------------------------
        if go and do_saves and has_save:
            folder = os.path.join(dest, name)
            os.makedirs(folder, exist_ok=True)
            slot = os.path.join(folder, "SLOT0.VMC")
            if not os.path.exists(slot):
                with open(slot, "wb") as f:
                    f.write(card)
            for n, keep, drop in rep["conflict"]:
                print("      conflict on %r" % n)
                print("        kept    %s  (%s)"
                      % (os.path.basename(keep["path"]), stamp(keep.get("mtime"))))
                print("        ignored %s  (%s)"
                      % (os.path.basename(drop["path"]), stamp(drop.get("mtime"))))
            for n, k in rep["overflow"]:
                print("      no room for %r (%d block(s))" % (n, k))

    # --- multi-disc sets ----------------------------------------------------
    # POPStarter swaps discs from a DISCS.TXT sitting in the game's folder. A
    # multi-disc game without one plays disc 1 and stops there.
    sets = 0
    for key, members in sorted(groups.items()):
        names = [pops_name(os.path.splitext(os.path.basename(m))[0]) + ".VCD"
                 for m in members]
        present = [n for n in names
                   if os.path.exists(os.path.join(dest, n))] if go else names
        if len(present) < 2:
            continue
        sets += 1
        if go:
            for n in present:
                folder = os.path.join(dest, n[:-4])
                os.makedirs(folder, exist_ok=True)
                write_discs_txt(folder, present)
    if sets:
        print("%d multi-disc set(s): DISCS.TXT %s"
              % (sets, "written" if go else "would be written"))

    print("-" * 78)
    if go:
        print("%d converted, %d failed%s."
              % (done, failed, (", %d skipped for want of room" % full) if full else ""))

    # The launchers, as a matter of course rather than a second run.
    #
    # A .VCD on its own boots nothing: POPStarter finds a game through a copy of
    # POPSTARTER.ELF renamed after it. Leaving that behind a flag meant the
    # normal outcome of a normal run was a folder that does not work, which is
    # not a reasonable thing to hand someone. The sweep covers every .VCD in the
    # folder, including ones converted on an earlier run.
    if make_elf and starter is not None:
        # Counting the ones written beside each game as well as the ones this
        # sweep adds. Reporting only the sweep said "4 launchers" after 428
        # conversions, which reads like something went wrong.
        made = elfs
        for f in sorted(os.listdir(dest)):
            if not f.upper().endswith(".VCD"):
                continue
            elf = os.path.join(dest, "XX." + f[:-4] + ".ELF")
            if not os.path.exists(elf):
                if go:
                    try:
                        shutil.copyfile(starter, elf)
                    except OSError as e:
                        print("  could not write %s: %s" % (os.path.basename(elf), e))
                        continue
                made += 1
        if made:
            print("%d launcher(s) %s from %s"
                  % (made, "created" if go else "would be created",
                     os.path.basename(starter)))
        else:
            print("Every .VCD already has its XX.*.ELF.")
    elif make_elf:
        print("\nNo POPSTARTER.ELF in %s, so no XX.*.ELF could be made -" % dest)
        print("without them POPStarter has no way to launch any of these games.")
        print("Drop POPSTARTER.ELF in that folder and run this again.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
