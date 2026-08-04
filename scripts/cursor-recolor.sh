#!/usr/bin/env bash
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib-palette.sh"
extract_palette || exit 1

export PATH="$HOME/.local/bin:$PATH"
command -v ctgen >/dev/null || { echo "falta ctgen"; exit 1; }
command -v npx >/dev/null || { echo "falta npx"; exit 1; }

HASH=$(echo -n "${ACCENT}${SECONDARY}${WINDOW_BG}${VIEW_FG}" | md5sum | cut -c1-8)
NAME="Bibata-NoctaliaQ-${HASH}"
echo "Tema versionado: $NAME"

CACHE="$HOME/.cache/bibata-build"
if [ ! -d "$CACHE/.git" ]; then
    rm -rf "$CACHE"
    git clone --depth 1 https://github.com/ful1e5/Bibata_Cursor.git "$CACHE" || exit 1
fi
cd "$CACHE" || exit 1
git pull --ff-only -q || true

rm -rf "bitmaps/$NAME" "themes/$NAME"
PUPPETEER_SKIP_DOWNLOAD=1 npx --yes cbmp -d 'svg/modern' -o "bitmaps/$NAME" \
    -bc "$ACCENT" -oc "$VIEW_FG" -wc "$WINDOW_BG" || exit 1
ctgen configs/normal/x.build.toml -s 16 20 22 24 28 30 32 40 48 56 64 72 80 88 96 -p x11 \
    -d "bitmaps/$NAME" -o 'themes' -n "$NAME" -c 'Bibata recolor dinamico NoctaliaQ' || exit 1

mkdir -p "$HOME/.local/share/icons"
rm -rf "$HOME/.local/share/icons/$NAME"
cp -r "themes/$NAME" "$HOME/.local/share/icons/$NAME"

# Limpiar versiones viejas (dejar solo la actual)
find "$HOME/.local/share/icons" -maxdepth 1 -iname "Bibata-NoctaliaQ-*" ! -iname "$NAME" -exec rm -rf {} \;
ln -sfn "$HOME/.local/share/icons/$NAME" "$HOME/.local/share/icons/Bibata-NoctaliaQ"

# Parchar misc.kdl con el nombre versionado (esto es lo que fuerza el reload real)
MISC="$HOME/NoctaliaQ/.config/niri/cfg/misc.kdl"
python3 - "$MISC" "$NAME" <<'PYEOF'
import sys, re
path, name = sys.argv[1], sys.argv[2]
s = open(path).read()
s = re.sub(r'xcursor-theme\s+"[^"]*"', f'xcursor-theme "{name}"', s)
s = re.sub(r'XCURSOR_THEME\s+"[^"]*"', f'XCURSOR_THEME "{name}"', s)
open(path, "w").write(s)
PYEOF

# Parchar gtk settings.ini tambien (mismo problema de cache por nombre)
python3 - "$NAME" <<'PYEOF'
import os, re, sys
name = sys.argv[1]
for ver in ("gtk-3.0", "gtk-4.0"):
    path = os.path.expanduser(f"~/.config/{ver}/settings.ini")
    if not os.path.exists(path):
        continue
    s = open(path).read()
    s = re.sub(r'gtk-cursor-theme-name=.*', f'gtk-cursor-theme-name={name}', s)
    open(path, "w").write(s)
PYEOF

gsettings set org.gnome.desktop.interface cursor-theme "$NAME"
gsettings set org.gnome.desktop.interface cursor-size 30

echo "listo: $NAME activo (versionado, forzando reload real)"
