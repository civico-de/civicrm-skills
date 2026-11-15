#!/usr/bin/env bash
# Puts the stand-in ck into the run's workspace.
set -euo pipefail
cp "$(dirname "${BASH_SOURCE[0]}")/../fixtures/ck" ./ck
chmod +x ./ck
