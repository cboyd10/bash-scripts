# 0001. Shadow the real bw binary with a wrapper on PATH using a shared session file

Date: 2026-06-15
Status: Accepted

## Context

The Bitwarden CLI requires a `BW_SESSION` token to be present for every command
that reads vault data. The token is only obtainable after calling `bw unlock`, which
requires interactive master password entry. Shell environment variables cannot be
inherited by child processes (scripts, Python programs, Claude Code sessions) that
weren't spawned from a shell that already exported `BW_SESSION`. A solution is
needed that works transparently for all caller contexts without requiring each caller
to manage session state.

## Decision

Place a wrapper script at `~/.local/bin/bw` that takes precedence over the real
`bw` binary on `$PATH`. The wrapper maintains a shared session file at
`~/.bw_session` (chmod 600) containing the session token. On every invocation the
wrapper reads the token from the file, validates it, prompts for the master password
if the vault is locked (interactive TTY only), writes a fresh token back, then calls
the real binary by its full absolute path with `--session` injected. `bw lock` and
`bw logout` are intercepted to also delete the session file.

## Alternatives considered

- **Shell function in .bashrc/.zshrc** — cannot export environment variables into
  child processes (scripts, Claude Code); ruled out by the hard requirement that all
  caller contexts must work.
- **Each caller manages its own session** — multiple concurrent unlocks invalidate
  each other's tokens; unworkable for the multi-caller use case.
- **Bitwarden Desktop IPC (bwbio)** — requires biometric hardware; not available on
  this system and adds significant complexity for no benefit here.
- **Store token in system keyring** — adds a dependency on GNOME Keyring / KWallet;
  unnecessary given the token has no expiry and a chmod 600 file provides equivalent
  protection for a single-user machine.

## Consequences

- Any process that calls `bw` inherits the wrapper transparently with no changes
  required in calling scripts or tools.
- The master password is never stored anywhere; only the session token is persisted.
- A single shared session file means one unlock serves all callers; concurrent
  unlocks from different processes will not fight each other.
- The real binary must be located at install time and its absolute path hardcoded
  (or discovered dynamically) in the wrapper to avoid recursive self-calls.
- Non-interactive callers (cron, systemd) will fail fast with a clear error if no
  valid session file exists; they depend on a human having unlocked in a terminal
  first.
- Phase 2 (idle TTL + Wayland screen lock hook) and Phase 3 (system tray app) are
  deferred but the session file design accommodates both without structural changes.
