# kwinctrl

Run-or-raise for KDE Plasma. Finds and focuses an existing window by class/title, or launches the application if it isn't running. Works on both X11 and Wayland.

A Rust rewrite of [ww-run-raise](https://github.com/academo/ww-run-raise), compatible with KDE 5.x and 6.x.

## Benchmark
Toggle-raise a `com.mitchellh.ghostty` window, 10 runs each, via `./benchmark.sh`:

```
Benchmark 1: kwinctrl
  Time (mean ± σ):      10.8 ms ±   1.6 ms    [User: 1.1 ms, System: 5.3 ms]
  Range (min … max):     8.3 ms …  13.0 ms    10 runs

Benchmark 2: ww
  Time (mean ± σ):      21.4 ms ±   1.6 ms    [User: 8.3 ms, System: 10.6 ms]
  Range (min … max):    19.2 ms …  23.8 ms    10 runs

Summary
  kwinctrl ran
    1.99 ± 0.33 times faster than ww
```

## Installing

```bash
cargo install --path .
```

Or build a release binary:

```bash
cargo build --release
# copy target/release/kwinctrl to somewhere in your PATH
```

## Usage

### Run or raise

Focus an existing Firefox window, or launch it if not running:

```sh
kwinctrl -f firefox -- firefox
```

Focus a window with a specific class, launching with that class if needed:

```sh
kwinctrl -f kitty.terminal -- kitty --class kitty.terminal
```

### Toggle (minimize if already focused)

```sh
kwinctrl -t -f firefox -- firefox
```

### Filter by title

Match windows by title using a regex pattern (matches against the window caption):

```sh
kwinctrl -a 'Zoom meeting'
```

### Filter by class regex

```sh
kwinctrl -r '^firefox'
```

### Center and resize on launch

Toggle a scratchpad terminal, centering it on first launch:

```sh
kwinctrl \
    --toggle \
    --center=initial \
    --filter dotfiles.andrewrabert.tmux-scratchpad \
    -- ghostty --class=dotfiles.andrewrabert.tmux-scratchpad -e zsh -ic 'tmux-attach --prompt'
```

Toggle Obsidian, centering on first launch, matching the Flatpak process:

```sh
kwinctrl \
    --toggle \
    --center=initial \
    --filter obsidian \
    --process-regex '^/app/obsidian\x00' \
    -- kioclient exec ~/.local/share/flatpak/exports/share/applications/md.obsidian.Obsidian.desktop
```

### Center and scale the focused window

Resize the currently focused window to 80% of the screen, capping the aspect ratio at 1.6:

```sh
kwinctrl \
    --filter-focused \
    --center \
    --scale-factor 0.8 \
    --max-aspect 1.6
```

### Inspect the active window

```sh
kwinctrl -i
```

Prints all KWin properties for the focused window -- useful for finding the right `--filter` value.

## KDE Shortcuts

Bind these commands to keyboard shortcuts via KDE's Custom Shortcuts or `.desktop` files in `~/.local/share/kwin/scripts/` to get global hotkeys for run-or-raise.

## How it works

1. Checks if a matching process is already running by scanning `/proc` directly (no dependency on `pgrep`).
2. If running, loads a temporary KWin script over D-Bus that finds the matching window and focuses it.
3. If not running, spawns the given command, then optionally centers/resizes the new window after a delay.

The KWin script is loaded, executed, and immediately stopped/unloaded in a single sequence.
