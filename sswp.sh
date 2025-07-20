#!/usr/bin/env bash
# Sequoia Sweep Forensics Script (sswp.sh)
# Usage: ./sswp.sh [target_path]
set -euo pipefail

# ---[ Toolchain config ]---
GREP="$(command -v ggrep || command -v grep)"
STRINGS="$(command -v strings)"
SHA256="$(command -v shasum)"
FIND="$(command -v gfind || command -v find)"

# Check required tools
for tool in "$GREP" "$STRINGS" "$SHA256" "$FIND"; do
  if [[ ! -x "$tool" ]]; then
    echo "[!] Required tool not found: $tool"
    exit 1
  fi
done

# ---[ Setup output directory ]---
timestamp="$(date +"%Y%m%d_%H%M%S")"
OUTDIR="$HOME/Desktop/sswp_out_$timestamp"
mkdir -p "$OUTDIR"

# ---[ Target detection ]---
if [[ $# -eq 0 ]]; then
  TARGET="/Volumes/sequoia"
  echo "[*] No target specified. Using default: \"$TARGET\""
else
  TARGET="$1"
  echo "[*] Using specified target: \"$TARGET\""
fi

if [[ ! -d "$TARGET" ]]; then
  echo "[!] Target path not found: \"$TARGET\""
  exit 1
fi

echo "[*] Beginning sweep of: $TARGET"
echo "[+] Output will be stored in: $OUTDIR"

# ---[ SCAN BLOCKS BEGIN ]---

echo "[*] Step 1: Grepping readable files for suspicious terms..."
"$FIND" "$TARGET" -type f -size +0c \( -iname '*.plist' -o -iname '*.txt' -o -iname '*.sh' \) -print0 \
  | xargs -0 "$GREP" --binary-files=text -iE 'launchctl|keylogger|reverse shell|backdoor|bitcoin|wallet|base64|curl|osascript' \
  > "$OUTDIR/grep_hits.txt" 2>/dev/null || true
echo "[✓] grep_hits.txt written."

echo "[*] Step 2: Scanning binaries for embedded WIF/private keys (this may take a while)..."
file_count=0
"$FIND" "$TARGET" -type f -executable -size +512c -size -100M -print0 \
  | while IFS= read -r -d '' file; do
      ((file_count++))
      if ((file_count % 100 == 0)); then
        echo "  [*] Processed $file_count files..."
      fi
      "$STRINGS" -a "$file" 2>/dev/null | \
        "$GREP" -E '^5[HKL][1-9A-HJ-NP-Za-km-z]{50,51}$' >> "$OUTDIR/wallet_keys.txt" 2>/dev/null || true
  done
echo "[✓] wallet_keys.txt written."

echo "[*] Step 3: Hashing script and executable files..."
"$FIND" "$TARGET" -type f -size +0c \( -iname '*.sh' -o -perm +111 \) -print0 \
  | while IFS= read -r -d '' file; do
      "$SHA256" "$file" >> "$OUTDIR/hashes.txt" 2>/dev/null || true
  done
echo "[✓] hashes.txt written."

# ---[ FINISH ]---
echo "[✓] Sweep complete. Output saved to: $OUTDIR"
