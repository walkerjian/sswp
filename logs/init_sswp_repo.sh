#!/bin/bash

# Set root path
ROOT="/Users/ian/dev/sswp"

# Create directories
mkdir -p "$ROOT/lib"
mkdir -p "$ROOT/output"
cd "$ROOT" || exit 1

# Create main script scaffold
cat << 'EOF' > "$ROOT/sswp.sh"
#!/bin/bash

# Sequoia Sweep Forensics Script (sswp.sh)
# Usage: ./sswp.sh [target_path]
set -e

timestamp=$(date +"%Y%m%d_%H%M%S")
OUTDIR="$HOME/Desktop/sswp_out_$timestamp"
mkdir -p "$OUTDIR"

# Detect or accept target path
if [[ -z "$1" ]]; then
  TARGET="/Volumes/Sequoia HD - Data"
  echo "[*] No target specified. Using default: $TARGET"
else
  TARGET="$1"
  echo "[*] Using specified target: $TARGET"
fi

if [[ ! -d "$TARGET" ]]; then
  echo "[!] Target path not found: $TARGET"
  exit 1
fi

echo "[*] Beginning sweep of $TARGET"
# Placeholder for main scanning logic
echo "[+] Output will be stored in: $OUTDIR"

# TODO: Insert calls to lib/*.sh modules here
EOF

# Make main script executable
chmod +x "$ROOT/sswp.sh"

# Create README
cat << 'EOF' > "$ROOT/README.md"
# sswp

**Sequoia Sweep (sswp)** is a forensic scanning script for traversing mounted external macOS volumes and scanning for:

- Suspicious LaunchAgents/Daemons
- Login items and browser data
- Embedded secrets (e.g. Bitcoin WIF keys)
- High-entropy encrypted blobs

## Usage

```bash
./sswp.sh /Volumes/Sequoia\ HD\ -\ Data
