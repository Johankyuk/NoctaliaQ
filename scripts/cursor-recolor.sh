#!/usr/bin/env bash
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib-palette.sh"
extract_palette || exit 1

export PATH="$HOME/.local/bin:$PATH"
command -v ctgen >/dev/null || { echo "falta ctgen (pip install --user --break-system-packages clickgen)"; exit 1; }
command -v npx >/dev/null || { echo "falta npx (pacman -S nodejs npm)"; exit 1; }

CACHE="$HOME/.cache/bibata-build"
if [ ! -d "$CACHE/.git" ]; then
    rm -rf "$CACHE"
    git clone --depth 1 https://github.com/ful1e5/Bibata_Cursor.git "$CACHE" || exit 1
fi
cd "$CACHE" || exit 1
git pull --ff-only -q || true

rm -rf bitmaps/Bibata-NoctaliaQ themes/Bibata-NoctaliaQ
PUPPETEER_SKIP_DOWNLOAD=1 npx --yes cbmp -d 'svg/modern' -o 'bitmaps/Bibata-NoctaliaQ' \
    -bc "$ACCENT" -oc "$VIEW_FG" -wc "$WINDOW_BG" || exit 1
ctgen configs/normal/x.build.toml -s 16 20 22 24 28 30 32 40 48 56 64 72 80 88 96 -p x11 \
    -d 'bitmaps/Bibata-NoctaliaQ' -o 'themes' -n 'Bibata-NoctaliaQ' -c 'Bibata recolor dinamico NoctaliaQ' || exit 1

mkdir -p "$HOME/.local/share/icons"
rm -rf "$HOME/.local/share/icons/Bibata-NoctaliaQ"
cp -r themes/Bibata-NoctaliaQ "$HOME/.local/share/icons/Bibata-NoctaliaQ"

gsettings set org.gnome.desktop.interface cursor-theme "Bibata-NoctaliaQ"
gsettings set org.gnome.desktop.interface cursor-size 30
touch "$HOME/NoctaliaQ/.config/niri/cfg/misc.kdl"

echo "listo: Bibata-NoctaliaQ regenerado con la paleta actual"
