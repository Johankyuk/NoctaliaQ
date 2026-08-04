#!/usr/bin/env bash
set -uo pipefail

SRC_BASE="/usr/share/icons/Papirus"
OUT_BASE="$HOME/.local/share/icons/Papirus-Dark-NoctaliaQ"
CSS="$HOME/.config/gtk-4.0/noctalia.css"

[ -f "$CSS" ] || { echo "no encontré $CSS"; exit 1; }
[ -d "$SRC_BASE" ] || { echo "no encontré $SRC_BASE"; exit 1; }

ACCENT=$(grep -oP '(?<=@define-color accent_color )#[0-9a-fA-F]{6}' "$CSS" | head -1)
WINDOW_BG=$(grep -oP '(?<=@define-color window_bg_color )#[0-9a-fA-F]{6}' "$CSS" | head -1)
VIEW_FG=$(grep -oP '(?<=@define-color view_fg_color )#[0-9a-fA-F]{6}' "$CSS" | head -1)

for v in ACCENT WINDOW_BG VIEW_FG; do
    [ -n "${!v}" ] || { echo "no pude extraer $v de noctalia.css"; exit 1; }
done

SECONDARY=$(python3 -c "
h='$ACCENT'.lstrip('#')
r,g,b=(int(h[i:i+2],16) for i in (0,2,4))
print(f'#{int(r*0.75):02x}{int(g*0.75):02x}{int(b*0.75):02x}')
")

echo "Paleta detectada: primary=$ACCENT secondary=$SECONDARY symbol=$WINDOW_BG paper=$VIEW_FG"

OLD_COLORS="#5294e2 #4877b1 #1d344f #e4e4e4"
NEW_COLORS="$ACCENT $SECONDARY $WINDOW_BG $VIEW_FG"

recolor() {
    IFS=" " read -ra old_c <<< "$1"
    IFS=" " read -ra new_c <<< "$2"
    local f="$3"
    for (( i=${#old_c[@]}-1; i>=0; i-- )); do
        sed -i "s/${old_c[$i]}/${new_c[$i]}/gI" "$f"
    done
}

for s in 16x16 22x22 24x24 32x32 48x48 64x64; do
    src_dir="$SRC_BASE/$s/places"
    out_dir="$OUT_BASE/$s/places"
    [ -d "$src_dir" ] || continue
    mkdir -p "$out_dir"
    while IFS= read -r -d '' f; do
        base="$(basename "$f")"
        newbase="${base/-blue/}"
        cp -f "$f" "$out_dir/$newbase"
        recolor "$OLD_COLORS" "$NEW_COLORS" "$out_dir/$newbase"
    done < <(find "$src_dir" -regextype posix-extended -regex ".*/(folder|user)-blue([-.].*)?\.svg" -print0)
done

cat > "$OUT_BASE/index.theme" <<EOF
[Icon Theme]
Name=Papirus-Dark-NoctaliaQ
Comment=Papirus-Dark con folders recoloreados a la paleta activa de NoctaliaQ
Inherits=Papirus-Dark,Papirus,hicolor
Directories=16x16/places,22x22/places,24x24/places,32x32/places,48x48/places,64x64/places

[16x16/places]
Size=16
Context=Places
Type=Fixed

[22x22/places]
Size=22
Context=Places
Type=Fixed

[24x24/places]
Size=24
Context=Places
Type=Fixed

[32x32/places]
Size=32
Context=Places
Type=Fixed

[48x48/places]
Size=48
Context=Places
Type=Fixed

[64x64/places]
Size=64
Context=Places
Type=Fixed
EOF

gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark-NoctaliaQ"
echo "listo: Papirus-Dark-NoctaliaQ instalado y activo"
