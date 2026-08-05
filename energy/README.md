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
