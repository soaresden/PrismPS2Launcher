# Credits

Prism stands on other people's work, and this file says whose.

## Foundation

**Spaghetticode (Boon Tobias)** — [RETROLauncher](https://github.com/Spaghetticode-Boon-Tobias/RETROLauncher).
Prism is a fork of RETROLauncher at commit `e6f9508`. The list rendering, the
menu framework, the theme editor, the sprites and logos, and the integration of
Enceladus, RetroArch, POPStarter, Neutrino and OPL into one program are his. His
commits are in this repository's history under his name. He built the thing that
made everything else here possible.

## The emulators and runtimes Prism drives

| | Author | Licence |
|---|---|---|
| [Enceladus](https://github.com/DanielSant0s/Enceladus) — the Lua runtime | DanielSant0s | GPL-3.0 |
| [RetroArch PS2 port](https://github.com/libretro/RetroArch) and the 61 cores | fjtrujy and the libretro contributors | GPL and others, per core |
| [Neutrino](https://github.com/rickgaiser/neutrino) | Maximus32 (rickgaiser) | — |
| POPStarter | krHACKen | — |
| [Ember](https://github.com/Gageformer/Ember) — PS1 emulation on the PS2 itself | Gageformer | Ember Public Beta Testing Licence |
| [Open PS2 Loader](https://github.com/ps2homebrew/Open-PS2-Loader) | the ps2homebrew team | AFL 3.0 |
| [wLaunchELF ISR](https://github.com/israpps/wLaunchELF_ISR) | israpps | — |
| [ps2sdk](https://github.com/ps2dev/ps2sdk) and its `ata_bd` driver | the ps2dev community | AFL 2.0 |

## Tools the helper scripts rely on

| | Author |
|---|---|
| `chdman` from MAME | the MAME team |
| `cue2pops` | krHACKen; rebuilt source by Bucanero |
| POPS-VCD-Manager | its author, for shipping `cue2pops.exe` and documenting `DISCS.TXT` |

## The interface

**EmulationStation**, as Batocera ships it (the fork maintained by Fabrice Caruso), for the
model: two views, named themable elements, a systems table separate from the
front-end. Prism reimplements that model in Lua; no ES code is used.

**[PlayStation-X](https://github.com/pajarorrojo/es-theme-PlayStation-X)** by
**pajarorrojo**, licensed CC BY-NC-SA 4.0, for the visual language: the dark
blue gradient, the translucent panels, the blue selector bar, the progress bar
with the step written inside, the coloured PlayStation buttons. Every asset in
Prism was redrawn from that description, none copied from the theme; the credit
is owed all the same.

## The font

**[Dosis](https://fonts.google.com/specimen/Dosis)** by **Pablo Impallari**
(Impallari Type), SIL Open Font License 1.1 — the interface font, shipped with
its licence in `System/Medias/Font/`. A rounded humanist sans, the nearest thing
under a free licence to the lettering PlayStation used.

**Public Pixel** by **GGBot**, CC0 — the pixel font inherited from RETROLauncher,
still there as the fallback when no other font is installed.

## Knowledge

- The `SifIopReset()` limitation of the PS2 libretro cores, confirmed in
  PSBBN issue #448.
- The `.VCD` layout, from the cue2pops v2.3 source rebuilt by Bucanero.
- The APCM sound format, from ps2sdk's `audsrv`.
- The POPStarter filename limits and disc-swap combinations, from the
  PS2-HOME and PSX-Place communities.

## Prism

Created by **soaresden**.

All console names, logos, game artwork and trademarks belong to their owners.
Prism ships no BIOS, no game data and no emulator binary that is not free to
redistribute.
