# bw-wrapper

A transparent bash wrapper for the [Bitwarden CLI](https://bitwarden.com/help/cli/) (`bw`) that manages vault session state automatically.

Any terminal session, shell script, Python script, or tool (including Claude Code) can call `bw` as normal without ever managing `BW_SESSION` manually.

## How it works

The wrapper lives at `~/.local/bin/bw`, shadowing the real `bw` binary on `$PATH`. On every invocation it:

1. Reads `~/.bw_session` (the Session Token cache)
2. Validates the token against the vault
3. If valid — injects `--session <token>` and delegates to the real binary
4. If invalid or missing and a TTY is present — prompts for the master password, unlocks the vault, caches the new token, then delegates
5. If invalid or missing and **no TTY** — exits 1 with a clear error message

`bw lock` and `bw logout` are intercepted: the real command runs first, then `~/.bw_session` is deleted.

The master password is read interactively via `/dev/tty`, passed to `bw unlock` through an environment variable, and never written to disk.

## Prerequisites

- Bitwarden CLI installed (`bw` on `$PATH`)
- Logged in (`bw login` completed at least once)
- `bash` 4+

## Install

```bash
cd bw-wrapper
bash install.sh
```

Then ensure `~/.local/bin` is at the **front** of your `$PATH` in `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="${HOME}/.local/bin:${PATH}"
```

Open a new terminal (or `source ~/.bashrc`) and verify:

```bash
which bw          # should print ~/.local/bin/bw
bw --version      # should work unchanged
```

## Usage

Use `bw` exactly as before. The first call after a lock will prompt for your master password:

```
$ bw get item mysite
Bitwarden master password:
...
```

Subsequent calls in any process reuse the cached session without prompting.

## Uninstall

```bash
cd bw-wrapper
bash uninstall.sh
```

Removes `~/.local/bin/bw` and `~/.bw_session`.

## Security notes

- `~/.bw_session` is always `chmod 600` (owner read/write only)
- The master password never touches disk and never appears in the process list
- The session token is passed to `bw` via `--session` flag, not `BW_SESSION` env var, to limit shell-history exposure

## Roadmap

### Phase 2a — Idle TTL

Delete `~/.bw_session` and call `bw lock` after a configurable period of inactivity. Likely implemented as a systemd user timer that resets on each wrapper invocation.

### Phase 2b — Wayland screen-lock trigger

Call `bw lock` when the screen locks. Hook via the `org.freedesktop.ScreenSaver` D-Bus signal, `swayidle`, or `hyprlock` depending on compositor.

### Phase 3 — System tray app

Show lock/unlock status and a wrapper activity log from a system tray applet.
