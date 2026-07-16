#!/usr/bin/env bash
set -euo pipefail

WRAPPER_DEST="${HOME}/.local/bin/bw"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER_SRC="${SCRIPT_DIR}/bw"
SENTINEL="BW_WRAPPER_SENTINEL"

# ---------------------------------------------------------------------------
# Locate the real bw binary (must not be the wrapper itself)
# ---------------------------------------------------------------------------

find_real_bw() {
  local candidate

  # Walk PATH entries, skipping ~/.local/bin to avoid finding a prior wrapper
  while IFS= read -r -d: dir; do
    [[ "${dir}" == "${HOME}/.local/bin" ]] && continue
    candidate="${dir}/bw"
    if [[ -x "${candidate}" ]] && ! grep -q "${SENTINEL}" "${candidate}" 2>/dev/null; then
      printf '%s' "${candidate}"
      return 0
    fi
  done <<< "${PATH}:"

  # Explicit fallbacks
  for candidate in /usr/bin/bw /usr/local/bin/bw; do
    if [[ -x "${candidate}" ]] && ! grep -q "${SENTINEL}" "${candidate}" 2>/dev/null; then
      printf '%s' "${candidate}"
      return 0
    fi
  done

  return 1
}

real_bw="$(find_real_bw)" || {
  printf '❌ Could not locate the real bw binary. Install Bitwarden CLI first.\n' >&2
  exit 1
}

printf '✅ Found real bw binary: %s\n' "${real_bw}"

# ---------------------------------------------------------------------------
# Install the wrapper
# ---------------------------------------------------------------------------

mkdir -p "${HOME}/.local/bin"

# Substitute the placeholder with the real binary path
sed "s|__BW_REAL_BINARY__|${real_bw}|g" "${WRAPPER_SRC}" > "${WRAPPER_DEST}"
chmod +x "${WRAPPER_DEST}"

printf '✅ Wrapper installed at %s\n' "${WRAPPER_DEST}"

# ---------------------------------------------------------------------------
# PATH reminder
# ---------------------------------------------------------------------------

case ":${PATH}:" in
  *":${HOME}/.local/bin:"*)
    # Check it's before the real bw location
    case "${PATH%%"${real_bw%/*}"*}" in
      *"${HOME}/.local/bin"*)
        printf '✅ ~/.local/bin is on $PATH ahead of %s\n' "${real_bw%/*}"
        ;;
      *)
        printf '⚠️  ~/.local/bin is on $PATH but not ahead of %s — move it to the front.\n' "${real_bw%/*}" >&2
        ;;
    esac
    ;;
  *)
    printf '\n⚠️  ~/.local/bin is not on $PATH. Add this to ~/.bashrc or ~/.zshrc:\n' >&2
    printf '    export PATH="${HOME}/.local/bin:${PATH}"\n' >&2
    printf 'Then open a new terminal or run: source ~/.bashrc\n' >&2
    ;;
esac
