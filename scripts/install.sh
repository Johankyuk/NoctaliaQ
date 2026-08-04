
#!/usr/bin/env bash

# Instalador de NoctaliaQ. Requiere niri + Noctalia ya instalados y funcionando.

# No los instala desde cero: solo aplica la capa NoctaliaQ encima.

set -uo pipefail



REPO_HTTPS="https://github.com/Johankyuk/NoctaliaQ.git"

REPO_SSH="git@github.com:Johankyuk/NoctaliaQ.git"

TARGET="$HOME/NoctaliaQ"



echo "== NoctaliaQ installer =="



if ! command -v niri >/dev/null 2>&1; then

    echo "ERROR: no encontre 'niri' en PATH."

    echo "NoctaliaQ es una capa sobre una instalacion existente de niri + Noctalia, no un instalador desde cero."

    exit 1

fi



if [ ! -d "$HOME/.config/noctalia" ]; then

    echo "ADVERTENCIA: no encontre ~/.config/noctalia — parece que Noctalia no esta instalado/corrido todavia."

    read -p "¿Continuar de todas formas? [s/N] " ans

    case "$ans" in [sS]) ;; *) exit 1 ;; esac

fi



if [ -d "$TARGET/.git" ]; then

    echo "-> NoctaliaQ ya clonado, actualizando..."

    git -C "$TARGET" pull --ff-only

else

    echo "-> Clonando NoctaliaQ..."

    git clone "$REPO_HTTPS" "$TARGET"

fi

git -C "$TARGET" remote set-url origin "$REPO_SSH" 2>/dev/null || true



ts=$(date +%s)

for d in niri noctalia gtk-3.0 gtk-4.0; do

    live="$HOME/.config/$d"

    target="$TARGET/.config/$d"

    [ -d "$target" ] || continue

    if [ -e "$live" ] && [ ! -L "$live" ]; then

        echo "-> Respaldando ~/.config/$d -> $live.bak.$ts"

        cp -r "$live" "$live.bak.$ts"

        rm -rf "$live"

    fi

    ln -sfn "$target" "$live"

done



mkdir -p "$HOME/.local/share/applications"

for f in "$TARGET"/.local/share/applications/*.desktop; do

    [ -e "$f" ] || continue

    ln -sfn "$f" "$HOME/.local/share/applications/$(basename "$f")"

done

command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$HOME/.local/share/applications" || true



echo "-> Instalando dependencias de los scripts de recolor (pide sudo)..."

sudo pacman -S --needed --noconfirm nodejs npm python-pip papirus-icon-theme

pip install --user --break-system-packages -q "clickgen>=2.2.5"

export PATH="$HOME/.local/bin:$PATH"



echo "-> Corriendo el primer recolor (cursor + folders con la paleta actual)..."

"$TARGET/scripts/recolor-all.sh" || echo "AVISO: el recolor fallo — revisa que ~/.config/gtk-4.0/noctalia.css exista (Noctalia debe haber corrido al menos una vez)."



echo "== listo =="

echo "Reinicia sesion (o al menos cierra/abre las apps GTK) para que todo cargue limpio."

