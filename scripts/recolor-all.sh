#!/usr/bin/env bash
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/papirus-recolor.sh"
"$DIR/cursor-recolor.sh"
echo "recolor completo (folders + cursor)"
