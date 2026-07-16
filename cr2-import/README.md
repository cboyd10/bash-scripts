# cr2-import

Convert Canon `.CR2` raw photos into timestamp-named JPGs, ready to drag into
a date-sorted photo archive (e.g. NextCloud's `photos/YYYY/MM` folders).

Given a folder of `.CR2` files, `cr2-import`:

1. Converts every `.CR2` in the folder to a JPG in a `converted/` subfolder,
   using `rawtherapee-cli` — a real raw demosaic, not just a low-quality
   embedded thumbnail.
2. Renames each converted JPG to:

   ```
   YY-MM-dd HH-mm-ss <original CR2 filename>.jpg
   ```

   using the photo's actual capture time (EXIF `DateTimeOriginal`), not the
   file's modification time.

The original `.CR2` files are **never modified, renamed, or moved**. If a
run goes wrong, just delete `converted/` and run the script again.

## Prerequisites

- Ubuntu (this script only supports apt-based installs; other distros aren't tested)
- `exiftool` — apt package `libimage-exiftool-perl`
- `rawtherapee-cli` — apt package `rawtherapee` (this also installs the RawTherapee GUI; there's no separate CLI-only package)

You don't need to install these yourself — see below.

## Install

Clone or pull this repo, then:

```bash
chmod +x cr2-import/cr2-import
```

Optionally symlink it onto your `PATH`, e.g.:

```bash
ln -s "$(pwd)/cr2-import/cr2-import" ~/.local/bin/cr2-import
```

The first time you run it, if `exiftool` or `rawtherapee-cli` are missing,
it will print the exact `apt install` command and offer to run it for you:

```
Missing required tool(s). Install with:
  sudo apt update && sudo apt install libimage-exiftool-perl rawtherapee
Install now? [y/N]
```

Say yes, or decline and run that command yourself first.

## Usage

```bash
cr2-import [OPTIONS] [FOLDER]
```

`FOLDER` is optional and defaults to the current directory. It is **not**
searched recursively — only `.CR2` files directly inside `FOLDER` are
processed.

Each step (converting, then renaming) shows a live progress bar with a
count and the photo currently being processed:

```
Step 1/2: Converting 20 CR2 file(s) to JPG (quality 92)
[####################----------] 13/20  IMG_1246.CR2
```

### Options

| Flag | Description |
|---|---|
| `-q, --quality NUM` | JPEG output quality, 1-100 (default: 92) |
| `-h, --help` | Show help and exit |

### Examples

```bash
# From inside the folder of picks
cd ~/Pictures/2026-06-family-outing
cr2-import

# From anywhere, pointing at a folder
cr2-import ~/Pictures/2026-06-family-outing

# Higher JPEG quality
cr2-import -q 97 ~/Pictures/2026-06-family-outing
```

Output lands in `~/Pictures/2026-06-family-outing/converted/`, e.g.:

```
converted/26-06-14 15-32-07 IMG_1234.jpg
converted/26-06-14 15-32-19 IMG_1235.jpg
```

## Recommended workflow: cull before you copy

Don't transfer an entire memory card just to delete most of it. Instead:

1. Mount the card (plug in your card reader; it'll show up as a normal
   filesystem, no special driver needed).
2. Install [Geeqie](https://geeqie.org/) if you don't have it:
   `sudo apt install geeqie`. It reads the small JPEG preview embedded in
   each `.CR2` for fast browsing, without decoding the full raw file.
3. Open the card's `DCIM` folder in Geeqie, browse your shots, and copy or
   move only the keepers into a working folder on your computer (e.g.
   `~/Pictures/2026-06-family-outing`).
4. Run `cr2-import` on that working folder.
5. Drag the JPGs from `converted/` into the matching NextCloud month folder
   (e.g. `photos/2026/06`).

## Troubleshooting

**"No .CR2 files found directly in '...'"**
You're either in the wrong folder, or your files are nested in a
subfolder (e.g. straight off a card at `DCIM/100CANON/`). This script
doesn't recurse — copy the files up a level, or point it directly at the
subfolder.

**A JPG didn't get renamed / still has its original camera filename**
The script couldn't read `DateTimeOriginal` from that CR2 (rare, but can
happen with a corrupted file). It's left in `converted/` with its default
name from `rawtherapee-cli` rather than being skipped entirely — check
the warning printed during the run.

**I want to redo a batch**
Delete `converted/` and run `cr2-import` again. The source `.CR2` files
were never touched, so nothing is lost.
