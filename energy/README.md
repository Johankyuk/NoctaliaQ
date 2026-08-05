# energy — EN PAUSA

Portado de horus-nix (fan curves quiet/balanced/performance, perfiles
power-profiles-daemon, switch PRIME dinamico por AC/bateria, cap de CPU).

Desactivado el 2026-08-05: se prefiere el control nativo via rog-control-center
+ asusd. Motivo: horus-gpu-watch fuerza offload PRIME en AC que introduce un
paso de copia dGPU->iGPU (con vsync activo en el juego, se percibia menos
fluido pese a que el contador de FPS marcara alto); se resolvio desactivando
vsync en el juego, no en este modulo. Se conserva la duracion de bateria que
ya se tenia con el control nativo.

Codigo intacto, binarios y sudoers siguen instalados pero inertes (los
servicios estan disabled). Para reactivar:
  systemctl --user enable --now horus-gpu-watch.service
  sudo systemctl enable --now horus-fan-curves.service

## Actualizacion 2026-08-05 (sesion posterior): revision de la decision sobre Ultimate/supergfxd

En la sesion original se documento que el boton Ultimate de rog-control-center
"no hacia nada" por falta del daemon supergfxd (dgpu_disable seguia en 0
tras activarlo). Investigacion posterior en esta misma fecha encontro
evidencia que contradice ese diagnostico:

- Log de asusd al activar Ultimate: "Queueing GPU attribute gpu_mux_mode = 0
  for delayed apply" seguido de "Applied queued GPU attribute gpu_mux_mode = 0".
- dmesg confirma un reinit completo de amdgpu (VBIOS, Display Core) en el
  mismo segundo que el log de asusd.
- El conector eDP fisico salta: card0-eDP-2 (amdgpu) pasa a "disconnected"
  y card1-eDP-1 (nvidia) pasa a "connected".

Conclusion: el MUX si conmuta de verdad, sin supergfxd instalado. El valor
0 en gpu_mux_mode corresponde al modo Ultimate/discreto en este firmware,
no al hibrido como se asumio originalmente (no se probo explicitamente
volver a hibrido para confirmar el valor opuesto — pendiente si hace falta
certeza total).

Esto reabre la pregunta de consumo/bateria que se habia dado por cerrada
en la decision original (la logica de "no importa el trade-off porque el
boton no hace nada" ya no aplica). Pendiente: medir consumo real en modo
Ultimate (reposo y carga) vs modo hibrido/nativo actual antes de decidir
si se usa Ultimate de forma regular.

Efecto colateral encontrado y ya resuelto por separado: el toggle de MUX
hace que niri vuelva al modo "preferred" del panel (60Hz) en vez del nativo
144Hz. Fix aplicado en .config/niri/cfg/display.kdl (bloque output "eDP-1"
forzando 1920x1200@144.001), no relacionado a este modulo pausado.
