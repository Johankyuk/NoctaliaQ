#!/usr/bin/env bash
# Fix: NvDynamicBoost fuera de rango en dc_profile_tunings (batería) rompe
# el objeto D-Bus AsusArmoury al boot -> rog-control-center no carga
# GPU Configuration ("asus-armoury driver is not loaded").
#
# Causa raíz: perfil DC/Balanced en /etc/asusd/asusd.ron tenía
# NvDynamicBoost: 0, fuera del rango real del firmware (5-25).
# Al arrancar en batería, asusd intenta aplicar 0 -> EINVAL -> falla
# el reload de asus_armoury -> AsusArmoury no se registra en D-Bus.
#
# Idempotente: solo actúa si detecta el valor roto.

set -euo pipefail

CONFIG="/etc/asusd/asusd.ron"
BACKUP="${CONFIG}.bak-$(date +%Y%m%d-%H%M%S)"

if [ ! -f "$CONFIG" ]; then
  echo "No se encontró $CONFIG — ¿asusd/asusctl instalado?"
  exit 1
fi

if ! grep -q "NvDynamicBoost: 0," "$CONFIG"; then
  echo "No se encontró NvDynamicBoost: 0 en $CONFIG — nada que corregir (¿ya aplicado, o config distinta?)."
  exit 0
fi

echo "Backup: $BACKUP"
sudo cp "$CONFIG" "$BACKUP"

echo "Aplicando fix: NvDynamicBoost 0 -> 5 (mínimo válido del firmware)"
sudo sed -i 's/NvDynamicBoost: 0,/NvDynamicBoost: 5,/' "$CONFIG"

echo "Reiniciando asusd..."
sudo systemctl restart asusd

echo "Verificación:"
grep -n "NvDynamicBoost" "$CONFIG"

echo "✓ fix aplicado — reiniciá el sistema para confirmar en un boot real"
