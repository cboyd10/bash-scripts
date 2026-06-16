# Context: Bitwarden CLI Wrapper

A shell wrapper that transparently intercepts `bw` commands, manages vault session
tokens on behalf of the caller, and prompts for unlock when needed — so any terminal
session, script, or tool (including Claude Code) can use `bw` without manually
managing session state.

## Terms

### Session Management

**Session Token**:
The value returned by `bw unlock` that decrypts vault data for a CLI invocation.
Passed to the real `bw` binary via `--session`. Valid indefinitely until `bw lock`
or `bw logout` is called. Not the same as the master password.

**Session File**:
`~/.bw_session` — a `chmod 600` plain text file storing the current **Session Token**
and the Unix timestamp of when it was written. The single shared source of session
truth for all callers on the machine.

**Real Binary**:
The actual `bw` executable at its installed absolute path (e.g. `/usr/bin/bw` or
`/usr/local/bin/bw`). Never called directly by the user — always invoked by the
**Wrapper**.

**Wrapper**:
The script at `~/.local/bin/bw` that shadows the **Real Binary** on `$PATH`. Reads
the **Session File**, validates the token, prompts for unlock if needed, then
delegates to the **Real Binary** with `--session` injected.

**Vault Lock**:
The state where the **Session Token** is invalidated server-side. Triggered by
`bw lock` or `bw logout`. The **Wrapper** intercepts these commands to also delete
the **Session File**.

### Caller Contexts

**Interactive Caller**:
Any process that has a TTY attached — a terminal session, a script run manually in
a terminal. The **Wrapper** may prompt for the master password in this context.

**Non-interactive Caller**:
Any process without a TTY — cron jobs, systemd services, CI pipelines. The
**Wrapper** fails fast with a clear error message rather than hanging.

## Relationships

- The **Wrapper** reads and writes exactly one **Session File** per user
- The **Wrapper** delegates all commands to the **Real Binary** after injecting `--session`
- A **Vault Lock** always invalidates the **Session Token** and deletes the **Session File**
- A **Non-interactive Caller** can succeed only if a valid **Session File** already exists
