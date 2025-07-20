# sswp

**Sequoia Sweep (sswp)** is a forensic scanning script for traversing mounted external macOS volumes and scanning for:

- Suspicious LaunchAgents/Daemons
- Login items and browser data
- Embedded secrets (e.g. Bitcoin WIF keys)
- High-entropy encrypted blobs

## Usage

```bash
./sswp.sh /Volumes/Sequoia\ HD\ -\ Data
