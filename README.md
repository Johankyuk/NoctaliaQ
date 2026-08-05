# NoctaliaQ

Addon sobre una instalación existente de niri + Noctalia. No quita ni reemplaza nada de Noctalia — agrega encima: cursor Bibata negro, recolor dinámico de folders, transparencia/blur en apps GTK, terminal (kitty) con blur, branding en fastfetch que sigue el acento activo, y un fix para que el panel interno no pierda su refresh rate nativo tras un toggle de MUX (Ultimate/Híbrido).

## Requisitos

- niri instalado y corriendo.
- Noctalia instalado y corriendo al menos una vez (necesita haber generado `~/.config/gtk-4.0/noctalia.css`).

## Instalación

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Johankyuk/NoctaliaQ/main/scripts/install.sh)
```

Esto:

1. Clona (o actualiza) este repo en `~/NoctaliaQ`.
2. Respalda y symlinkea `~/.config/{niri,noctalia,gtk-3.0,gtk-4.0,fastfetch}` hacia el repo.
3. Instala la entrada del lanzador de Noctalia (recolor de folders).
4. Instala `kitty`, `thunar`, la fuente y `papirus-icon-theme` vía pacman.
5. Instala el cursor Bibata-Modern-Classic (una sola vez, ver sección Cursor).
6. Corre un primer recolor de folders con la paleta activa.

## No es un color fijo (con una excepción a propósito: el cursor)

Folders (Papirus) y el logo de fastfetch siguen la paleta que Noctalia genera a partir del wallpaper activo — no hay un hex fijo en ningún lado. El cursor es la única pieza que **no** sigue el wallpaper: es Bibata-Modern-Classic (negro) fijo, a propósito, para no tener que regenerarlo cada vez que cambia el fondo.

## Cursor

`scripts/install-cursor.sh` baja el release oficial de `ful1e5/Bibata_Cursor` (negro, sin tintar) a `~/.local/share/icons/Bibata-Modern-Classic` y lo activa. Se corre una sola vez desde el instalador; correrlo de nuevo simplemente reinstala/actualiza. `misc.kdl` (niri) y `gtk-3.0`/`gtk-4.0` `settings.ini` ya apuntan a ese nombre fijo.

Esto reemplaza un enfoque anterior con recolor dinámico (clickgen + build por paleta); si preferís volver a un cursor que siga el acento, esa lógica sigue disponible en el historial de git (`git log -- scripts/cursor-recolor.sh`), pero no se usa por defecto.

## Recolor dinámico (folders)

Papirus (folders de Thunar) lee el accent color activo de Noctalia (`~/.config/gtk-4.0/noctalia.css`) al momento de correr, no un hex fijo. Después de cambiar de wallpaper/paleta:

```bash
~/NoctaliaQ/scripts/recolor-all.sh        # folders (wrapper, por si se suma algo mas adelante)
~/NoctaliaQ/scripts/papirus-recolor.sh    # lo mismo, directo
```

También disponible desde el lanzador de Noctalia ("NoctaliaQ: Recolor Folders").

El tema de kitty (`~/.config/kitty/themes/noctalia.conf`) ya lo regenera Noctalia solo, sin scripts nuestros — NoctaliaQ solo le agrega opacidad dinámica (`background_opacity`) y fuente (JetBrainsMono Nerd Font) encima.

## Blur

Global en `.config/niri/config.kdl` (`window-rule` sin `match`, aplica a toda ventana). kitty lo soporta nativo vía el protocolo de niri. Para que se note en apps GTK como Thunar, `gtk.css` importa `noctaliaq-blur.css` con alpha sobre los colores base de Noctalia — si se ve muy sutil o muy fuerte, edítalo directo, no requiere rebuild de nada.

## fastfetch

`~/.config/fastfetch` corre automático al abrir terminal (vía el saludo default de `cachyos-fish-config`, no algo que NoctaliaQ dispare). El logo (`noctaliaq.txt`) usa `"color": {"1": "green"}` en `config.jsonc` — no un hex fijo: fastfetch emite el código ANSI del color 2, que kitty resuelve con `color2` de `themes/noctalia.conf`, el mismo slot que Noctalia ya usa para el accent (coincide con `url_color`/`active_border_color` en ese archivo). Cambia el wallpaper, cambia `color2`, cambia el logo — sin ningún script nuestro corriendo por el medio.

## refresh-lock (panel interno / MUX)

En equipos con MUX (toggle Ultimate/Híbrido vía rog-control-center o `asusctl`/`supergfxctl`), activar Ultimate dispara un reinit del GPU y niri puede volver al modo "preferred" del panel según su EDID — que en algunos paneles es más bajo que el refresh real que soportan (ej. 60Hz en vez de 144Hz), aunque el modo alto siga disponible.

`refresh-lock/` corrige esto sin asumir marca, modelo ni resolución de ningún equipo: le pregunta a niri por IPC cuál es el panel interno y cuál es su modo de mayor resolución+refresh, y lo reaplica si hace falta. Corre solo, enganchado en `cfg/autostart.kdl`. Ver `refresh-lock/README.md` para el detalle.

## asusd-fixes / energy

Fixes puntuales de asusd/asusctl/rog-control-center (`asusd-fixes/`) y el módulo de fan-curves/PRIME portado de horus-nix, actualmente en pausa (`energy/`) — ver el README de cada carpeta.

## Estructura
```
.config/niri/       config de niri (keybinds, reglas de ventana, blur global)
.config/noctalia/   paletas y settings de Noctalia
.config/gtk-3.0/ .config/gtk-4.0/  tema GTK + transparencia para el blur
.config/kitty/       opacidad + fuente encima del tema que genera Noctalia
.config/fastfetch/   logo y config, corre via el saludo de fish
scripts/             recolor de folders, instalador, instalador de cursor
refresh-lock/        fix generalizado de refresh-rate del panel interno tras MUX
asusd-fixes/         fixes puntuales de asusd/rog-control-center
energy/              fan-curves/PRIME portado de horus-nix (en pausa)
```

