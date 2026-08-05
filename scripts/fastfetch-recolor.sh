#!/usr/bin/env bash
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib-palette.sh"
extract_palette || exit 1

CFG="$HOME/.config/fastfetch/config.jsonc"
[ -f "$CFG" ] || { echo "no encontre $CFG"; exit 1; }

python3 - "$CFG" "$ACCENT" << 'PYEOF'
import sys, re
path, accent = sys.argv[1], sys.argv[2]
s = open(path).read()
new_s, n = re.subn(r'("color":\s*\{\s*"1":\s*)"[^"]*"', r'\1"' + accent + '"', s)
assert n == 1, f"esperaba 1 reemplazo, hice {n}"
open(path, "w").write(new_s)
PYEOF

echo "listo: logo de fastfetch en $ACCENT"
