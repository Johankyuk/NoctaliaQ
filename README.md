
# NoctaliaQ



Configuración personal de niri + Noctalia (fondo violeta/dark, cursor y folders de Papirus recoloreados dinámicamente según la paleta activa).



## Requisitos



- niri instalado y corriendo.

- Noctalia instalado y corriendo al menos una vez (necesita haber generado `~/.config/gtk-4.0/noctalia.css`).



Este repo **no instala niri ni Noctalia** — es una capa que se aplica encima de una instalación existente.



## Instalación



```bash

bash <(curl -fsSL https://raw.githubusercontent.com/Johankyuk/NoctaliaQ/main/scripts/install.sh)

```



Esto:



1. Clona (o actualiza) este repo en `~/NoctaliaQ`.

2. Respalda y symlinkea `~/.config/{niri,noctalia,gtk-3.0,gtk-4.0}` hacia el repo.

3. Instala las entradas del lanzador de Noctalia (recolor de folders, cursor, y ambos juntos).

4. Instala dependencias de los scripts de recolor (`nodejs`, `npm`, `python-pip`, `clickgen`, `papirus-icon-theme`).

5. Corre un primer recolor de cursor + folders con la paleta activa.



## Recolor dinámico



El cursor (Bibata) y los folders de Thunar (Papirus) se recolorean leyendo el accent color activo de Noctalia (`~/.config/gtk-4.0/noctalia.css`), no un color fijo.



Después de cambiar de wallpaper/paleta, corre uno de estos (o úsalos desde el lanzador de Noctalia):



```bash

~/NoctaliaQ/scripts/recolor-all.sh        # cursor + folders

~/NoctaliaQ/scripts/cursor-recolor.sh     # solo cursor

~/NoctaliaQ/scripts/papirus-recolor.sh    # solo folders

```



El cursor queda instalado como `Bibata-NoctaliaQ-<hash de paleta>` (el hash cambia en cada recolor para forzar que niri/GTK lo recarguen; no es un bug).



## Estructura

.config/niri/       config de niri (keybinds, reglas de ventana, blur global)
 .config/noctalia/   paletas y settings de Noctalia
 .config/gtk-3.0/    .config/gtk-4.0/   tema GTK + transparencia para el blur
 scripts/            recolor de cursor y folders, instalador

## Blur



El blur global está en `.config/niri/config.kdl` (`window-rule` sin `match`, aplica a todo). Para que se note en apps GTK como Thunar, `gtk.css` importa `noctaliaq-blur.css` con alpha sobre los colores base — si se ve muy sutil o muy fuerte, edítalo directo, no requiere rebuild de nada.

