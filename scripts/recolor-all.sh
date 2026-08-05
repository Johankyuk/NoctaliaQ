#!/usr/bin/env bash
# El cursor (Bibata-Modern-Classic) ya no es dinamico -- ver
# install-cursor.sh, se instala una sola vez. Este script solo re-corre
# lo que si sigue la paleta activa: los folders de Thunar/Papirus.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/papirus-recolor.sh"
echo "recolor completo (folders)"
