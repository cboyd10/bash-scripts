# pretty-logs

Colorized, human-readable Kubernetes/OpenShift pod logs with optional filtering—built on `oc`/`kubectl` and `jq`.

---

## Features

- **Readable output**
  - **[LEVEL]** is color-coded by severity (ERROR:red, WARN:yellow, INFO:green, DEBUG:blue, TRACE:magenta)
  - **Message** in **white**
  - **Context** (timestamp, environment, service, logger, etc.) in **light gray**
- **Filtering**: include only selected levels via `LEVELS` (e.g., `WARN,ERROR`)
- **Auto-completion (Bash)**:
  - Tab-complete **pod names**, **container names**, and **flags**
  - If the cluster is **unreachable** or you’re **not logged in**, completion **always shows a hint candidate** (no spaces, so it’s visible on all Bash versions):
    ```
    __NO_PODS__cluster_unreachable_or_not_logged_in
    ```
    and for containers:
    ```
    __NO_CONTAINERS__cannot_fetch_pod_or_cluster_unreachable
    ```
  - Adds a **1-second timeout** for completion calls  
    (Linux `timeout`; macOS `gtimeout` if GNU coreutils installed)
  - **Caches** results for 10 seconds to keep completion snappy
- **Diagnostics**: `pretty-logs --diag-completion` checks auth/connectivity/context
- **Preflight checks**: Friendly install hints if dependencies are missing
- **Help**: `pretty-logs --help` shows usage, options, and examples

---

## Requirements

- **One of:**
  - OpenShift CLI: `oc`
  - Kubernetes CLI: `kubectl`
- **`jq`** (JSON processor)
- **bash-completion** (optional but recommended for tab completion)

The script checks for these and prints OS-specific install tips if anything is missing.

---

## Installation

### 1) Save the script

Create a file named `pretty-logs` (no `.sh` extension recommended):

```bash
nano pretty-logs
# Paste the full script content
# Save and exit (Ctrl+O, Enter, Ctrl+X)
````

> Important: The first line **must** be exactly:
>
> ```bash
> #!/usr/bin/env bash
> ```
>
> If you edited on Windows, convert line endings to Unix (LF) before running:
>
> ```bash
> dos2unix pretty-logs
> ```

### 2) Make it executable and put it on your PATH

**User install:**

```bash
mkdir -p "$HOME/bin"
mv pretty-logs "$HOME/bin/pretty-logs"
chmod +x "$HOME/bin/pretty-logs"
```

Ensure `$HOME/bin` is on your PATH:

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**System-wide (recommended so `sudo` can find it):**

```bash
sudo mv "$HOME/bin/pretty-logs" /usr/local/bin/pretty-logs
sudo chmod +x /usr/local/bin/pretty-logs
```

Verify:

```bash
which pretty-logs
pretty-logs --help
```

***

## Getting Started

Run the script with a pod name (container optional):

```bash
pretty-logs -p my-pod
pretty-logs my-pod my-container
```

***

## Auto-Completion

The script includes built-in **Bash completion** for pods, containers, and flags.

### Enable bash-completion

**macOS (Homebrew):**

```bash
brew install bash-completion@2
echo '[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"' >> ~/.bash_profile
source ~/.bash_profile
```

**Debian/Ubuntu:**

```bash
sudo apt-get install -y bash-completion
echo '[[ -r /etc/bash_completion ]] && . /etc/bash_completion' >> ~/.bashrc
source ~/.bashrc
```

**RHEL/CentOS/Fedora:**

```bash
sudo dnf install -y bash-completion
echo '[[ -r /etc/bash_completion ]] && . /etc/bash_completion' >> ~/.bashrc
source ~/.bashrc
```

### Install completion for `pretty-logs`

**User-level:**

```bash
pretty-logs --install-completion
source ~/.bash_completion.d/pretty-logs
```

**System-wide** (ensure `pretty-logs` is in `/usr/local/bin` so root can find it):

```bash
sudo pretty-logs --install-completion system
# Activate now:
source /etc/bash_completion.d/pretty-logs \
  || source /opt/homebrew/etc/bash_completion.d/pretty-logs \
  || source /usr/local/etc/bash_completion.d/pretty-logs
```

### Verify completion

*   Pod names:
    ```bash
    pretty-logs -p <TAB><TAB>
    ```
*   Container names (after selecting a pod):
    ```bash
    pretty-logs -p mypod -c <TAB><TAB>
    ```
*   Flags:
    ```bash
    pretty-logs --<TAB><TAB>
    ```

If the cluster is unreachable or you’re not logged in, you will see one of:

    __NO_PODS__cluster_unreachable_or_not_logged_in
    __NO_CONTAINERS__cannot_fetch_pod_or_cluster_unreachable

> Tip: Improve completion UX with Readline settings:
>
> ```bash
> printf '%s\n' \
> 'set show-all-if-ambiguous on' \
> 'set page-completions off' \
> 'set completion-ignore-case on' \
> 'set bell-style none' >> ~/.inputrc
> bind -f ~/.inputrc
> ```

***

## Usage Examples

```bash
# Follow logs with color (auto on TTY)
pretty-logs -p canvas-banner-batch

# Specific container
pretty-logs -p canvas-banner-batch -c processor

# Filter to WARN and ERROR only
pretty-logs -p canvas-banner-batch --levels WARN,ERROR

# Force color when piping to less (use -R to preserve ANSI colors)
COLOR_MODE=on pretty-logs -p canvas-banner-batch | less -R
```

***

## Command Reference

*   **Help**:
    ```bash
    pretty-logs --help
    ```

*   **Print completion script**:
    ```bash
    pretty-logs --print-completion
    ```

*   **Install completion**:
    ```bash
    pretty-logs --install-completion            # user-level
    sudo pretty-logs --install-completion system  # system-wide
    ```

*   **Diagnose completion connectivity**:
    ```bash
    pretty-logs --diag-completion
    ```

***

## Configuration

*   **Pod name**: `-p`, `--pod`, or positional first argument
*   **Container name**: `-c`, `--container`, or positional second argument
*   **Levels filter**: `--levels` or `LEVELS=...`  
    Default: `ERROR,WARN,INFO,DEBUG,TRACE`
*   **Color mode**: `--color` or `COLOR_MODE=auto|on|off`  
    Default: `auto` (colors on TTY; off in pipes/files)
*   **CLI override**: `OC_OR_KUBECTL=oc|kubectl`  
    Default: auto-detect (prefers `oc` if available)

***

## Troubleshooting

*   **Command not found**:
    ```bash
    which pretty-logs
    chmod +x /path/to/pretty-logs
    echo 'export PATH="/path/to:$PATH"' >> ~/.bashrc && source ~/.bashrc
    ```
    For system use, install to `/usr/local/bin/pretty-logs`.

*   **“Illegal option -o pipefail”**:
    Ensure the script runs under Bash (not `sh`), and the shebang is the **first line**:
    ```bash
    #!/usr/bin/env bash
    ```
    Or run explicitly:
    ```bash
    bash /usr/local/bin/pretty-logs --help
    ```

*   **Completion hints don’t show**:
    *   Confirm bash-completion is enabled:
        ```bash
        type _init_completion >/dev/null 2>&1 || echo "bash-completion not loaded"
        ```
    *   Re-source completion file:
        ```bash
        source ~/.bash_completion.d/pretty-logs
        ```
    *   Press `<TAB><TAB>` to display candidates.  
        Unreachable/not logged cases return **no-space sentinel** candidates:
            __NO_PODS__cluster_unreachable_or_not_logged_in
            __NO_CONTAINERS__cannot_fetch_pod_or_cluster_unreachable

*   **Cluster connectivity/auth**:
    *   OpenShift:
        ```bash
        oc login
        oc whoami
        ```
    *   Kubernetes:
        ```bash
        kubectl cluster-info
        kubectl config current-context
        ```

*   **No colors when piping**:
    ```bash
    COLOR_MODE=on pretty-logs -p mypod | less -R
    ```

*   **Diagnose completion**:
    ```bash
    pretty-logs --diag-completion
    ```

***

## Uninstall

```bash
# Command
rm -f /usr/local/bin/pretty-logs
rm -f "$HOME/bin/pretty-logs"

# Completion
rm -f ~/.bash_completion.d/pretty-logs
sudo rm -f /etc/bash_completion.d/pretty-logs
sudo rm -f /opt/homebrew/etc/bash_completion.d/pretty-logs
sudo rm -f /usr/local/etc/bash_completion.d/pretty-logs
```

***
