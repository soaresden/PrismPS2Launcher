# Prism PS2 Launcher

A PS2 homebrew front-end in Lua (Enceladus runtime), forked from RETROLauncher by Boon
Tobias. It lists games from every drive and launches them with OPL, Neutrino,
POPStarter, Ember or RetroArch cores. Author: Denis (soaresden).

## Never do

- Never commit BIOS files (`Bios/*.bin`, `bios.bin`, `scph*.bin`). They are the user's own dumps.
- Never commit `UI.ttf` (proprietary font, gitignored).
- Never add PlayStation-X theme assets (CC BY-NC-SA) to the repo. The look is redrawn, not copied.
- Only public-domain console photographs.
- Run `git status` and show it before any commit, and check nothing above slipped in.

## Conventions

- English identifiers in new code. Older Spanish names inherited from RETROLauncher stay.
- Commit messages are long and explain *why*. Write them to a file, then `git commit -F <file>`
  (multi-line messages break in PowerShell otherwise).
- Colours: exFAT = yellow, USB = cyan, unplayable = red. POPStarter = pink, Ember = orange.
- Credits: boot screen says "Created by soaresden"; Boon Tobias in Special Thanks;
  EmulationStation and pajarorrojo credited; Ember is by Gageformer.
- Python helpers ask their questions with the default in brackets; Enter takes it.
  Check them with `python -m py_compile` before handing them over.

## Layout and hardware

- The console payload lives in `To Transfer on USB or Exfat/Prism/` and is copied by hand
  to the drive. Git shows the folder as `Prism`, some tools as `PRISM` (Windows ignores case).
- `E:` = USB stick = `mass0:` on the console; the launcher runs from `E:\PRISM`.
- `F:` = internal exFAT disk = `mass1:` (ATA, BDM). `mc0:` = memory card; `mc0:/PRISMBOOT/` holds boot.lua.
- Nothing can be run on the console from here: every change to Lua must be tested on the real
  PS2 by Denis. Say plainly what has not been run.

## Hard-won facts (do not undo)

- `System.loadELF(path, reboot, arg)` — three arguments. A fourth is passed on as another argv
  and broke Ember.
- `Font.ftInit()` exactly once; re-running `ui/gfx.lua` blanks every font handle.
- `Graphics.loadImage` can HANG (not error) on some JPEGs: PNG only for any art folder we do not control.
- Game art is fetched only once the selection has held still `ART_SETTLE` frames (views/gamelist.lua):
  loading on every move froze the list for half a second.
- Titles: `pretty_title` strips an OPL serial in front and bracketed codes at the end; `stem_of` must
  not treat `.84]` as an extension; gamelist.xml `<name>` goes through `pretty_title` too;
  `System/Defaults/PS2_IDs.cfg` gives the real PS2 title from the serial.
- POPStarter cannot read the internal exFAT disk. Ember can (it uses the launcher's drivers).
- Ember Beta 2: argument is the game folder name, or `<Folder>/<file>.cue` (no `games/` prefix).
  Never reset the IOP before it (`IOP_REBOOT_EMBER = 0`). Cards are `MC1.vmc`/`MC2.vmc` in the game
  folder; POPStarter's `POPS/<game>/SLOT0.VMC` is a separate card, not shared.
- Multi-disc sets live in one Ember folder; Prism's triangle menu picks the disc.
- OPL is launched from a copy at `mc0:/PRISMBOOT/OPNPS2LD.ELF`, with an IOP reset first.
  Per-game cheats: `$CheatsSource=1`, `$EnableCheat=1`, `$CheatMode=0` in `CFG/<ID>.cfg`.
- The internal disk is detected via `internal-ata-disk.flag`, written by PRISMBOOT's boot.lua.
- PowerShell paths containing `[ ]` need `-LiteralPath`.

## Open

- Not yet verified on the console: the Ember disc chooser (with Beta 2's argument form), the
  title cleaning + PS2_IDs lookup, the square cycle and the art settle delay, CD audio under Beta 2.
- `F:\POPS` still holds the original POPStarter saves; it can go once a save loads under Ember.
- Deferred: dual-pane file explorer in the START menu; VMC manager (see github.com/bucanero/ps2vmc-tool);
  `TRACE_FRAMES = 0` once the interface is trusted.
