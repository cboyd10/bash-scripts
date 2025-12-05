# pretty-logs

Colorized, human-readable Kubernetes/OpenShift pod logs with optional filtering—built on `oc`/`kubectl` and `jq`.

---

## Features

| Feature | Description |
| :--- | :--- |
| **Readable Output** | JSON logs are parsed and color-coded. <br>• **[LEVEL]**: Colored by severity (ERROR:red, WARN:yellow, INFO:green, DEBUG:blue, TRACE:magenta)<br>• **Message**: White<br>• **Context**: Light gray (timestamp, environment, service, logger) |
| **Filtering** | Include only selected levels via `LEVELS` (e.g., `WARN,ERROR`). |
| **Log Tailing** | • Default: tails last 10 lines<br>• Customizable via `--tail <n>`<br>• Fetch all logs via `--all` |
| **Auto-completion** | Tab-complete pod names, container names, and flags. <br>• **Smart Hints**: If cluster is unreachable, shows explicit `__NO_PODS__` hints.<br>• **Fast**: Caches results for 10s and uses a 1s timeout. |
| **Diagnostics** | Run `pretty-logs --diag-completion` to check auth & connectivity. |
| **Preflight Checks** | Friendly install hints if dependencies (`jq`, `oc`/`kubectl`) are missing. |

---

## Requirements

The script checks for these dependencies and provides install tips if missing.

*   **Cluster CLI** (one of):
    *   `oc` (OpenShift CLI)
    *   `kubectl` (Kubernetes CLI)
*   **JSON Processor**:
    *   `jq`
*   **Bash Completion** (Optional):
    *   `bash-completion` package (recommended for tab completion)

---

## Installation

### 1. Save the script

Create the file (no extension recommended):
```bash
vim pretty-logs
# Paste the full script content
# Save and exit
```
> **Note**: First line must be `#!/usr/bin/env bash`. If editing on Windows, convert line endings with `dos2unix pretty-logs`.

### 2. Install to PATH

| Scope | Commands |
| :--- | :--- |
| **User** | `mkdir -p ~/bin`<br>`mv pretty-logs ~/bin/`<br>`chmod +x ~/bin/pretty-logs`<br>*(Ensure `~/bin` is in your `$PATH`)* |
| **System** | `sudo mv pretty-logs /usr/local/bin/`<br>`sudo chmod +x /usr/local/bin/pretty-logs` |

---

## Usage
```bash
pretty-logs -p <pod> [-c <container>] [options...]
```
### Options

| Flag | Description | Default |
| :--- | :--- | :--- |
| `-p`, `--pod <name>` | Pod name (**required** unless positional). | |
| `-c`, `--container <name>` | Container name. | First container |
| `--levels <list>` | Comma-separated levels to include. | `ERROR,WARN,INFO,DEBUG,TRACE` |
| `--tail <n>` | Number of lines to show from the end. | `10` |
| `--all` | Show all logs (disables tailing). | `false` |
| `--color <mode>` | Color mode: `auto`, `on`, `off`. | `auto` |
| `-h`, `--help` | Show help message. | |

### Advanced Commands

| Command | Description |
| :--- | :--- |
| `--print-completion` | Print the raw bash completion script to stdout. |
| `--install-completion [scope]` | Install completion script. Scope: `user` (default) or `system`. |
| `--diag-completion` | Diagnose completion connectivity & auth issues. |

---

## Configuration (Environment Variables)

You can set these environment variables to override defaults permanently.

| Variable | Description | Default |
| :--- | :--- | :--- |
| `LEVELS` | Default log levels to filter. | `ERROR,WARN,INFO,DEBUG,TRACE` |
| `TAIL_LINES` | Default number of lines to tail. | `10` |
| `COLOR_MODE` | Color output mode. | `auto` |
| `OC_OR_KUBECTL` | Force specific CLI (`oc` or `kubectl`). | Auto-detect (prefers `oc`) |

---

## Examples

**Basic Tailing (Last 10 lines)**
```bash
pretty-logs -p canvas-banner-batch
```
**Tail 50 Lines**
```bash
pretty-logs -p canvas-banner-batch --tail 50
```

**Show All Logs**
```bash
pretty-logs -p canvas-banner-batch --all
```

**Specific Container & Filter Levels**
```bash
pretty-logs -p canvas-banner-batch -c processor --levels WARN,ERROR
```

**Pipe to Less (Preserve Colors)**
```bash
COLOR_MODE=on pretty-logs -p canvas-banner-batch | less -R
```

---

## Auto-Completion Setup

### 1. Enable bash-completion
Ensure your OS has bash-completion installed and sourced.

*   **macOS**: `brew install bash-completion@2`
*   **Linux**: `sudo apt install bash-completion` or `sudo dnf install bash-completion`

### 2. Install Script Completion

| Scope | Command |
| :--- | :--- |
| **User** | `pretty-logs --install-completion`<br>`source ~/.bash_completion.d/pretty-logs` |
| **System** | `sudo pretty-logs --install-completion system`<br>`source /etc/bash_completion.d/pretty-logs` |

### 3. Verification
Type `pretty-logs -p <TAB>` to see pod suggestions.

---

## Troubleshooting

| Issue | Solution |
| :--- | :--- |
| **Command not found** | Check if `pretty-logs` is in a directory included in your `$PATH`. |
| **No Colors** | If piping, force colors: `COLOR_MODE=on pretty-logs ... | less -R`. |
| **Completion Fails** | Run `pretty-logs --diag-completion` to check cluster connectivity. |
| **"Illegal option -o pipefail"** | Ensure you run with `bash`, not `sh`. |

---

## Uninstall

To remove the script and completion files:

```bash
# Remove script
rm -f /usr/local/bin/pretty-logs ~/bin/pretty-logs

# Remove completion
rm -f ~/.bash_completion.d/pretty-logs /etc/bash_completion.d/pretty-logs
```
