# asusd-fixes/

Fixes puntuales para bugs de asusd/asusctl/rog-control-center en este
hardware (ASUS TUF A16 FA607NUG — Ryzen 7 7445HS + Radeon 740M + RTX 4050
Max-Q). No relacionado con `energy/` (mecanismo dinámico de fan-curves/PRIME
portado de horus-nix, actualmente pausado).

## fix-nv-dynamic-boost-range.sh

**Síntoma:** rog-control-center, pestaña System Control, GPU Configuration
muestra en rojo "The asus-armoury driver is not loaded" — pese a que el
módulo del kernel SÍ está cargado y los atributos sysfs se leen bien.

**Causa raíz:** `/etc/asusd/asusd.ron` tenía `NvDynamicBoost: 0` en
`dc_profile_tunings.Balanced` (perfil de batería). El firmware acepta solo
5-25. Al arrancar en batería, asusd intenta restaurar ese 0, el kernel
devuelve EINVAL (código 22), y ese fallo a medias en el reload de
`asus_armoury` deja el objeto D-Bus `AsusArmoury` sin registrar del todo —
de ahí el mensaje genérico (engañoso) de "driver no cargado".

Confirmado que en AC no se manifestaba (perfil Performance/AC ya tenía
`NvDynamicBoost: 25`, válido) — bug específico a boot en batería.

**Fix:** cambia ese valor a 5 (mínimo válido) en vez de 0.
Confirmado con boot real: log limpio sin `ERROR ... nv_dynamic_boost`,
`Restored asus-armoury setting nv_dynamic_boost to Integer(25)` en perfil
AC, y rog-control-center carga GPU Configuration sin el aviso rojo.

**Uso:** `./fix-nv-dynamic-boost-range.sh`

**Revertir:** restaurar desde el backup generado (`asusd.ron.bak-<timestamp>`),
luego `sudo systemctl restart asusd`.

**Nota abierta:** el valor roto se escribió en algún momento (mtime del
.ron dos días posterior a la instalación del binario actual) probablemente
al configurar el perfil de batería asumiendo "0 = sin boost". Validar que
rog-control-center/asusctl no vuelvan a aceptar 0 como input silencioso.
