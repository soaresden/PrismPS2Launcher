# Fork changes — internal exFAT HDD support and UI additions

Fork of [Spaghetticode-Boon-Tobias/RETROLauncher](https://github.com/Spaghetticode-Boon-Tobias/RETROLauncher),
based on `e6f9508` (v1.0 rev 2).

Tested on a PS2 FAT with a network adapter and an internal HDD formatted in
exFAT, booting RETROLauncher from USB.

---

## 1. The internal exFAT HDD now works

This is the point of the fork, and it answers issue #1, open since 2024.

### The blocker nobody had found

`System/IRX/` exists in upstream so users can load extra IOP drivers, but the
folder ships empty and the feature had never been exercised. It does not work:

**`Sif.loadModule(path)` freezes the console on every call.** Not "fails" —
freezes, before video init, with no message. Verified with:

- `dev9_ns.irx` and `poweroff.irx` (valid IRX modules),
- **a plain text file renamed to `.irx`** (not a module at all),
- both the 1-argument and 3-argument call forms,
- both the bundled 2024 Enceladus build and the current 2025 one.

An invalid file should return a negative ID immediately and never reach the IOP.
It freezes anyway, so this is not a driver problem.

**Cause:** `SifLoadModule` makes the *IOP* resolve the path, through its
`LOADFILE` module, which uses the old `ioman`. But `mass:` is provided by
`bdmfs_fatfs`, which registers with `iomanX`. The IOP cannot open the path and
the RPC never returns.

**Fix:** read the `.irx` on the EE side and hand over the bytes with
`IOP.loadModuleBuffer(data, size)`. No IOP-side path resolution, no freeze.

This is worth reporting upstream to Enceladus as well — any homebrew loading
IRX files from a BDM device from Lua will hit it.

### What was added

- `dev9_ns.irx` and `ata_bd.irx` (already shipped with Neutrino) are loaded at
  startup, **in that order** — `ata_bd` imports the `dev9` library, and
  `System.listDirectory` guarantees no ordering.
- A blocklist skips modules Enceladus already loads. Loading a second BDM stack
  registers twice (`BDM: ERROR: Already registered!`) and hangs the console.
- The internal disk then appears as **`massN:`**, never as `hdd0:`. `hdd0:` is
  the native ATAD/PFS stack, a different world.
- Drives that appear *after* the drivers load are tagged as ATA, which
  distinguishes a mounted internal disk from a second USB stick. Upstream's
  "device on the second USB port" guard used to fire on the internal disk and
  block startup in an infinite loop.

### Cumulative game search

Games are now searched in **both** the boot device and the internal disk, in a
folder of the same name as the launcher:

```
mass:/RETROLauncher      (USB, boot)
mass1:/RETROLauncher     (internal exFAT)
```

Applies to RetroArch systems, PS1 `.cue` for Ember, and PS2 ISOs — plus `DVD/`
and `CD/` at the root of ATA drives. Duplicates are de-duplicated by name, USB
wins. Each entry remembers where it came from, so launching resolves against the
right root.

**PS2 ISOs on the internal disk launch and run.** RETROLauncher already passed
`-bsd=ata` to Neutrino for the `.hdd` extension; this fork detects an ATA origin
and forces it automatically, rewriting the device prefix to `mass:` — with
`-bsd=ata` Neutrino loads only `ata_bd`, so the internal disk is its only block
device. A plain `.iso` is enough, no renaming needed.

**PS1 works too**, through Ember, from the internal disk.

### POPS

`POPS` was hardcoded to the boot device across 47 references. It is now resolved
at startup: an ATA drive whose `POPS/` contains `POPS_IOX.PAK` is preferred,
then any existing `POPS/`, then the boot device.

---

## 2. Interface

**Quick system selection.** `L1 + R1` together opens a grid of system logos —
only systems enabled in `SISTEMAS.*_ON`, cursor on the current one, Cross to
confirm, Triangle to cancel. Each trigger alone still cycles as before. The
combination was chosen because SELECT, L3, R3, START, L2 and R2 are all taken in
the main menu. An on-screen hint sits top-left.

**Media and format tags in the list.** Entries are prefixed with their origin and
extension, e.g. `[ATA].iso God Of War I`, `.zip Sonic The Hedgehog`. Names are
still displayed without their extension (`CONTROL.EXTENSION`), so the tag is the
only way to tell a `.zip` from a loose ROM.

**The OPL ELF picker** (Options → *PlayStation 2* → SELECT) now lists ATA drives,
so a custom `OPNPS2LD` on the internal disk can be selected. Device selector
banners also grow with the number of entries instead of overflowing.

**Typo:** `POSP` → `POPS` in the PS1 error string, in all three languages.

**PS1 errors now say what is missing and where.** Instead of a generic message,
the screen lists the absent files and the directory they were expected in.

---

## 3. Compatibility layer

`system.lua` fills in globals removed between the 2024 and 2025 Enceladus builds
(`FREAD` / `FWRITE` / `FRDWR` / `FCREATE`, `SET` / `CUR` / `END`, `Sif` → `IOP`,
`System.rename` → `System.moveFile`). The block is inert on the original build,
so **the fork runs on both interpreters**. IRX loading only activates when the
`IOP` global is present.

Note that the bundled `RETROLauncher.elf` has not been rebuilt since 2024-10-20,
while `irx_load()` was added on 2026-01-17 — which is why the folder had never
been exercised.

---

## 4. Diagnostics

- `BDM_REPORT.txt` — module loading, mounted drives, search roots. During module
  loading the file is flushed on every line, so a freeze is pinpointed.
- `LAUNCH_LOG.txt` — written before every `System.loadELF`: resolved paths and
  an existence check on each.
- `INVENTARIO_ON` in `system.lua` adds a full listing of what the launcher finds
  in each root. Off by default.

---

## 5. Known issue, unrelated to this fork — since solved, see section 8

> Kept for the record: this is what the symptom looked like before the cause was
> found. Cores run now.

**RetroArch cores do not run on this setup.** They start and return to the
system menu. This was verified to happen **with the original 2024 ELF as well**,
with an uncompressed ROM, on the boot device, with both the bundled cores and
current nightlies. `LAUNCH_LOG.txt` shows correct paths and `[ok]` on both core
and ROM, so the launcher hands over correctly. No RetroArch log is produced even
with `log_verbosity = "true"`, meaning the core dies before its own logging
starts.

Along the way this fork also fixed, without solving the above: config paths that
still referred to an older folder name, a duplicated slash in `log_dir`, and the
missing `logs`, `savefiles`, `system`, `states` and `screenshots` directories.

`IOP_REBOOT_CORES` in `system.lua` controls whether the IOP is reset before
launching a core. Setting it to `1` moved the symptom from a black screen to a
clean exit, so it is worth keeping.

---

## 6. Latent bug fixed

The Ember `.cue` scan was nested inside the `device:/POPS` check. With no `POPS`
folder on the boot device, PS1 games were never listed even when correctly
placed. The scan is now independent.

---

## 7. Follow-up on review feedback (PR #17)

- **Extension tag and grid hint are now behind the Circle button**, like the
  existing `[USB]`/`[HDD]` indicator. Showing the prefix permanently lengthened
  the line without `scroll_texto` knowing about it, so the selected title stopped
  scrolling — good catch, fixed.
- **The grid hint is anchored to the system logo position** (`CONTROL.LOGO_*`)
  instead of a fixed corner, so it follows a user-customised layout.
- **`BUSCAR_CDVD` in `system.lua`, `false` by default**, omits every `cdfs:`
  probe: the APPS and PS2 search lists, the existence check and the launch path.
  This follows the report that the program freezes when started from a
  wLaunchELF that has already loaded the CD/DVD module on a Slim.
- **POPS shortcuts, cheats and Hugopocked patches** all follow `POPS_RAIZ`, so
  they are created on the same drive as `POPS/` — the internal disk here. 52
  references in total.
- **Credits updated** in `README.md`.
- Configurations in the repository are back to their default state.

### Still open

- **Booting from the HDD** is not possible without rebuilding Enceladus: the
  drivers load after startup, so the ELF cannot live on a disk it cannot yet
  read. This also means the relocation path cannot be tested from the HDD.
- **File writing on the newer Enceladus** works here thanks to the compatibility
  layer — `FRDWR` in particular was missing and broke settings saving.

---

## 8. RetroArch cores run again

Section 5 above reported cores starting and returning to the system menu. That
is fixed, and there were two causes, both introduced by the environment rather
than by the launcher.

**The IOP was being reset twice.** `System.loadELF` was called with
`reboot_iop = 1` for cores and with `0` for everything else — and everything
else worked. RetroArch resets the IOP itself on entry (`reset_IOP()` in
`frontend_ps2_init`), so doing it first only stripped the loader of the drivers
it needed. `IOP_REBOOT_CORES` is now `0`.

**The device was named wrong.** Enceladus 2025 mounts block devices as `mass0:`,
`mass1:`. RetroArch reloads its own USB stack, where the device is `mass:` —
`rootDevicePath(BOOT_DEVICE_MASS)` returns exactly that. The core was handed a
path it could not open and exited silently. The ROM argument now goes through a
device-prefix rewrite, the same one Neutrino already needed.

Worth noting for the record that the hand-off itself was always correct:
Enceladus puts the ELF path in `argv[0]` and chains the variadic arguments from
`argv[1]`, which is precisely what `frontend_ps2_get_env` reads into
`content_path`.

**`raboot.elf` is a dead end and is now disabled** (`RABOOT_ON = false`). It is
the Salamander, and in `platform_ps2.c` the block that forwards the game to the
core sits inside `#ifndef IS_SALAMANDER`: it launches cores with zero arguments.
It can only ever open the RetroArch menu, and it rewrites
`retroarch-salamander.cfg` with its own choice on the way out.

### Core selection at launch

Launching a game now offers the cores that can actually run it, with the
system's default already selected — one press of Cross and it starts. The list
only appears when there is more than one candidate, so most systems are
unaffected.

Filtering reads `supported_extensions` from
`Retroarch Extracted Files/info/<core>.info` and crosses it with the real
extensions of the system. `zip` and `bin` are excluded from the match: eight of
the bundled cores declare `bin`, which would make almost anything look
compatible with anything. Results are cached per system, so the `.info` files
are read once per session.

---

## 9. Ember

- The emulator resolves the `.cue` **relative to its own directory** and is given
  the bare file name. Moving it to a shared `Bios/` folder broke that contract
  and Ember booted to the PlayStation BIOS screen with no disc. `ember.elf` and
  `bios.bin` are now deployed next to the games, copied from `Bios/` the first
  time a game is launched from that folder.
- The PS1 error screen names the missing `ember.elf` and `bios.bin`. Before it
  only mentioned the `.cue`, which made a missing emulator look like a missing
  game.

---

## 10. POPStarter

**`POPS/` is searched on every drive**, not only on the one resolved at startup.
A game can live in the `POPS` folder of the boot device and another in the one
on the internal disk. `POPS_DE()` then resolves, per game, the drive that holds
it: POPStarter requires its ELF, the `.VCD` and the virtual memory card to be on
the same device, so launching everything from a single `POPS_RAIZ` could not
work. Cheats and Hugopocked patches follow the same drive.

**A second library is accepted**, `Roms/psx-pops(vcd)/`, so `.VCD` files can sit
with the rest of the collection. POPStarter only ever reads `<drive>/POPS/`, so
the file is moved there on first launch — a rename within the same volume,
instant whatever the size.

**`IOPRP252.IMG` is no longer required to list a game.** The official quick start
guide is explicit that USB mode needs one file, `POPS_IOX.PAK`; the others belong
to the HDD setup. Demanding them rejected valid installs.

**The USB access delay is patched into the shortcuts.** POPStarter's debug build
prints

```
Opening mass:/POPS/... FAILED
No POPS directory ?
The POPS directory is here ? Increase the USB access delay or contact kHn.
```

on a perfectly good folder: its drivers are dated 2019/01/14 and it gives up
before some sticks have finished coming up. The delay is a single byte at offset
`0x413` of the configuration table, and it has to be present in every
`XX.<game>.ELF` since each shortcut is a complete POPStarter. `POPS_USB_DELAY`
in `system.lua` (default 20, stock value is 3) is written into each shortcut the
launcher creates, guarded by a signature check on the surrounding bytes.

---

## 11. Artwork

**The alpha channel is mandatory.** The manual says it on page 31 — *"The image
must have a transparency mask, otherwise it will not be displayed"* — and it is
not a suggestion: a PNG without one is loaded and then silently ignored. Artwork
scraped from EmulationStation and the covers OPL ships are usually 8-bit palette
or plain RGB, so nothing showed. This is a packaging rule rather than a code
change, but it cost a long time to find and is now documented and enforced by the
helper script.

**OPL's `ART` folder is searched on every drive.** It was resolved against the
boot device only, so PlayStation 2 covers sitting in `<internal disk>/ART`
were never found. Nothing is copied out of it: the launcher reads the artwork
where OPL already keeps it.

**Media folders are indexed once.** The manual warns (page 46) that checking for
one image in a folder of a thousand is not the same as in a folder of five
hundred — and this fork multiplied the places to look, up to six filesystem
calls on every move through the list. Each folder is now listed once and lookups
become table reads. The index is dropped when a list is rebuilt.

---

## 12. `exfatdb.json`

Rewritten, grouped by support and by system rather than by directory:

```json
{
  "USB": { "unidad": "mass0:", "juegos": { "roms/megadrive": [ ... ] } },
  "ATA": { "unidad": "mass1:", "juegos": { "roms/ps2-isos":  [ ... ] } }
}
```

This also fixed a real bug. The same directory appears twice in the search list —
once under its own name, once as an EmulationStation alias resolving to the same
string — and on the second pass the games are already in `vistos`, so the list
came back empty. The record was being *replaced*, which wiped everything found on
the first pass; every system on the boot device reported zero games. Entries are
merged now. PlayStation 1 and 2 were not inventoried at all and are included.

---

## 13. Diagnostics

- **`LAUNCH_LOG.txt` is a history**, not a snapshot. Every failed attempt returns
  to the launcher and requires a restart, so overwriting the file left only the
  last launch of a session, almost always the one that worked. Each boot inserts
  a dated separator; the file is trimmed from the start past 60 KB.
- **`MEDIA_LOG.txt`** records the path of an image immediately before
  `Graphics.loadImage`, the same technique that located the IRX freeze. If the
  console hangs while loading artwork, the last line names the file.
- **Cover lookups are traced** into `LAUNCH_LOG.txt`: every candidate path that
  was probed, in order, with its result.

---

## 14. Helper scripts

`HelperScripts/` gains three tools. None of them is required to use the fork.

- **`MediaCopier.py`** builds the artwork and title layout from a Batocera,
  Recalbox or EmulationStation install. It re-encodes every image to RGBA and
  fits it in 320×240 as the manual requires, folds accents out of titles (page 46
  again: a special character breaks the display), extracts GBA archives and
  deletes them once done, removes artwork whose ROM is gone, and completes a
  partial `POPS` folder without touching what is already there.
- **`PopsCheck.py`** verifies a POPStarter install: the published MD5 of the four
  POPS binaries, that each `XX.*.ELF` is a byte-for-byte copy of
  `POPSTARTER.ELF`, and the structure of each `.VCD` — 1 MiB table of contents
  followed by raw 2352-byte sectors, which is what distinguishes a real
  conversion from a renamed `.iso`.
- **`PopsDelay.py`** reads and raises the USB access delay described in section
  10, in every launcher of a `POPS` folder, keeping backups.

---

## 15. Folder layout

Systems use short EmulationStation-style names and are self-contained, so a
system can live on the USB stick or on the internal disk indifferently:

```
Roms/<system>/<rom>
Roms/<system>/media/covers/<rom without extension>.png
Roms/<system>/media/screenshots/<rom without extension>.png
Roms/<system>/titles.txt
```

`titles.txt` holds `file|title` pairs and makes the launcher show real game
titles instead of file names. The historical `Multimedia/Covers/Covers <System>/`
locations are still read, and the original long folder names still work.

Also:

- **`Bios/`** gathers the system files — `psx-ember.elf`, `bios.bin`,
  `gba_bios.bin`, and a copy of the POPStarter binaries.
- **`Retroarch Extracted Files/`** takes a RetroArch nightly extracted as-is. A
  core found in its `cores/` folder overrides the bundled one, on any drive, so
  updating means dropping in an archive. There is no date comparison: the Lua
  API exposes only name, size and type.
- **`Roms/!Retrolauncher/`** holds shared backgrounds and fonts.
- Artwork and titles are always written to the boot device, whatever the drive
  the game is on, so there is only ever one library of images to maintain.
