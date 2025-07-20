#!/bin/bash

SEQUOIA_PATH="/Volumes/Sequoia HD - Data"
OUTDIR="$HOME/Desktop/sequoia_forensics_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

echo "[*] Output directory: $OUTDIR"

# Step 1: List all user folders
echo "[*] Users:" | tee "$OUTDIR/users.txt"
ls -l "$SEQUOIA_PATH/Users" | tee -a "$OUTDIR/users.txt"

# Step 2: Capture LaunchAgents and LaunchDaemons
mkdir -p "$OUTDIR/launch_items"
for loc in "Library/LaunchAgents" "Library/LaunchDaemons" "System/Library/LaunchAgents" "System/Library/LaunchDaemons"; do
    echo "[*] Scanning: $loc"
    cp -R "$SEQUOIA_PATH/$loc" "$OUTDIR/launch_items/$(basename $loc)" 2>/dev/null
done

# Step 3: Grep for suspicious terms
echo "[*] Grepping for potential RAT/backdoor keywords..." | tee "$OUTDIR/grep_hits.txt"
grep -iER "backdoor|rat|keylogger|reverse shell|launchctl|plist|base64" "$SEQUOIA_PATH" 2>/dev/null | tee -a "$OUTDIR/grep_hits.txt"

# Step 4: Safari and Chrome profile summary
mkdir -p "$OUTDIR/browser"
cp -R "$SEQUOIA_PATH/Users/walkerjian/Library/Safari" "$OUTDIR/browser/Safari" 2>/dev/null
cp -R "$SEQUOIA_PATH/Users/walkerjian/Library/Application Support/Google/Chrome" "$OUTDIR/browser/Chrome" 2>/dev/null

# Step 5: List most recently modified files
echo "[*] Most recently modified files:" | tee "$OUTDIR/recent_files.txt"
find "$SEQUOIA_PATH" -type f -not -path "*/Library/Caches/*" -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -n 100 | tee -a "$OUTDIR/recent_files.txt"

# Step 6: Dump loginitems plist
echo "[*] Dumping login items..." | tee "$OUTDIR/login_items.txt"
defaults read "$SEQUOIA_PATH/Users/walkerjian/Library/Preferences/com.apple.loginitems.plist" >> "$OUTDIR/login_items.txt" 2>/dev/null

echo "[+] Done. Artifacts saved to $OUTDIR"
