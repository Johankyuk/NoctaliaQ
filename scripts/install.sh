
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

for d in niri noctalia gtk-3.0 gtk-4.0 fastfetch; do

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



echo "-> Instalando kitty, thunar, fuente y papirus-icon-theme (pide sudo)..."

sudo pacman -S --needed --noconfirm kitty thunar ttf-jetbrains-mono-nerd papirus-icon-theme



echo "-> Instalando cursor Bibata-Modern-Classic (estatico, una sola vez)..."

"$TARGET/scripts/install-cursor.sh" || echo "AVISO: no se pudo instalar el cursor — revisa conexion a github.com."



echo "-> Instalando reglas udev (bateria + teclado, pide sudo)..."
sudo install -m 644 "$TARGET/udev/90-noctaliaq-battery.rules" /etc/udev/rules.d/90-noctaliaq-battery.rules
sudo install -m 644 "$TARGET/udev/90-noctaliaq-kbd-backlight.rules" /etc/udev/rules.d/90-noctaliaq-kbd-backlight.rules
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=leds --subsystem-match=power_supply
if ! groups "$USER" | grep -qw video; then
    echo "AVISO: tu usuario no esta en el grupo 'video' — el teclado no podra escribirse sin sudo."
    echo "        corre: sudo usermod -aG video \"$USER\"   (y cierra sesion despues)"
fi

echo "-> Fijando limite de bateria por defecto (80%, pide sudo la primera vez)..."
"$TARGET/scripts/noctaliaq-battery.sh" set 80 || echo "AVISO: no pude fijar el limite — corre '$TARGET/scripts/noctaliaq-battery.sh --actual' para diagnosticar."

echo "-> Habilitando servicios de usuario (recolor automatico + teclado al iniciar sesion)..."
mkdir -p "$HOME/.config/systemd/user"
for u in "$TARGET"/systemd/user/*.service; do
    ln -sfn "$u" "$HOME/.config/systemd/user/$(basename "$u")"
done
systemctl --user daemon-reload
systemctl --user enable --now noctaliaq-keyboard-boot.service noctaliaq-recolor-watch.service 2>&1 \
    || echo "AVISO: no pude habilitar los servicios --user (¿estas dentro de una sesion grafica activa?)."

echo "-> Corriendo el primer recolor (folders + teclado, con la paleta actual)..."
"$TARGET/scripts/recolor-all.sh" || echo "AVISO: el recolor fallo — revisa que ~/.config/gtk-4.0/noctalia.css exista (Noctalia debe haber corrido al menos una vez)."



echo "== listo =="
echo ""
echo "Wizards disponibles desde el lanzador de Noctalia (o directo en terminal):"
echo "  $TARGET/scripts/noctaliaq-gpu.sh"
echo "  $TARGET/scripts/noctaliaq-battery.sh"
echo "  $TARGET/scripts/noctaliaq-keyboard.sh   -- corre '--diag' primero si el color/brillo no responde"
echo ""
echo "Si todo lo de arriba responde bien, ya no necesitas asusd/asusctl/rog-control-center."
echo "Para dejar de depender de ellos del todo (opcional, hazlo cuando ya hayas"
echo "probado GPU/bateria/teclado y confies en que funcionan):"
echo "  sudo systemctl disable --now asusd.service"
echo "  sudo pacman -Rns rog-control-center asusctl   # o el paquete equivalente de tu distro"
echo ""
echo "Reinicia sesion (o al menos cierra/abre las apps GTK) para que todo cargue limpio."
echo "El modo GPU (iGPU/Hibrida/Ultimate) que elijas en el wizard necesita un REINICIO COMPLETO aparte."

