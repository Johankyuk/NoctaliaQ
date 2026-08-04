#!/usr/bin/env bash
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/papirus-recolor.sh"
"$DIR/cursor-recolor.sh"
pkill -9 -f thunar 2>/dev/null || true
sleep 1
thunar & disown
echo "recolor completo (folders + cursor)"
