#!/usr/bin/env bash
# Instala el modulo de energia de NoctaliaQ (portado de horus-nix): fan curves
# quiet/balanced/performance, perfiles power-profiles-daemon, switch hibrido
# por firmware, cap de CPU por fuente. Requiere asusctl y power-profiles-daemon
# ya instalados (AUR/repo segun tu setup) — este script no los instala.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/energy"

echo "== NoctaliaQ energy installer =="

for c in asusctl powerprofilesctl; do
    command -v "$c" >/dev/null 2>&1 || {
        echo "ERROR: falta '$c' en PATH. Instala asusctl y power-profiles-daemon primero."
        exit 1
    }
done

echo "-> Copiando binarios a /usr/local/bin (pide sudo)..."
sudo install -m 755 "$DIR"/bin/* /usr/local/bin/

echo "-> Instalando unit de sistema (fan curves al boot)..."
sudo install -m 644 "$DIR/systemd/system/horus-fan-curves.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now horus-fan-curves.service

echo "-> Habilitando dependencias de sistema si no estan activas..."
sudo systemctl enable --now power-profiles-daemon.service asusd.service

echo "-> Instalando unit de usuario (vigilante PRIME + fan curve performance)..."
mkdir -p "$HOME/.config/systemd/user"
install -m 644 "$DIR/systemd/user/horus-gpu-watch.service" "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
systemctl --user enable --now horus-gpu-watch.service

echo "-> Instalando sudoers NOPASSWD para horus-cpu-cap (pide sudo)..."
sed "s/__USER__/$(whoami)/" "$DIR/sudoers.d/horus-cpu-cap" | sudo tee /etc/sudoers.d/horus-cpu-cap >/dev/null
sudo chmod 440 /etc/sudoers.d/horus-cpu-cap
sudo visudo -c -f /etc/sudoers.d/horus-cpu-cap || {
    echo "ERROR: sudoers invalido, revirtiendo."
    sudo rm -f /etc/sudoers.d/horus-cpu-cap
    exit 1
}

echo "== listo =="
echo "Estado: horus-power --actual"
echo "Logs del vigilante: journalctl --user -u horus-gpu-watch -f"
