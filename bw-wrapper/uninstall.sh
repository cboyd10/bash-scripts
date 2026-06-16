#!/usr/bin/env bash
set -euo pipefail

WRAPPER="${HOME}/.local/bin/bw"
SESSION_FILE="${HOME}/.bw_session"
SENTINEL="BW_WRAPPER_SENTINEL"

# Refuse to remove a real bw binary that isn't the wrapper
if [[ -f "${WRAPPER}" ]] && ! grep -q "${SENTINEL}" "${WRAPPER}" 2>/dev/null; then
  printf '❌ %s does not appear to be the bw wrapper — refusing to remove it.\n' "${WRAPPER}" >&2
  exit 1
fi

removed=0

if [[ -f "${WRAPPER}" ]]; then
  rm -f "${WRAPPER}"
  printf '✅ Removed wrapper: %s\n' "${WRAPPER}"
  (( removed++ )) || true
else
  printf 'ℹ️  Wrapper not found at %s (already removed?)\n' "${WRAPPER}"
fi

if [[ -f "${SESSION_FILE}" ]]; then
  rm -f "${SESSION_FILE}"
  printf '✅ Removed session file: %s\n' "${SESSION_FILE}"
  (( removed++ )) || true
else
  printf 'ℹ️  Session file not found at %s (already removed?)\n' "${SESSION_FILE}"
fi

(( removed > 0 )) && printf '\n✅ Uninstall complete.\n'
