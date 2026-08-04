# NoctaliaQ

Addon sobre una instalación existente de niri + Noctalia. No quita ni reemplaza nada de Noctalia — agrega encima: recolor dinámico de cursor y folders, transparencia/blur en apps GTK, terminal (kitty) con blur, y branding en fastfetch.

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
3. Instala las entradas del lanzador de Noctalia (recolor de folders, cursor, y ambos juntos).
4. Instala dependencias de los scripts de recolor (`nodejs`, `npm`, `python-pip`, `clickgen`, `papirus-icon-theme`).
5. Corre un primer recolor de cursor + folders con la paleta activa.

## No es un color fijo

Nada de esto está atado a un color en particular — todo sigue la paleta que Noctalia genera a partir del wallpaper activo. Cambias de fondo, cambia el acento, y el cursor/folders/terminal se pueden re-generar para seguirlo (ver siguiente sección).

## Recolor dinámico

Cursor (Bibata) y folders de Thunar (Papirus) leen el accent color activo de Noctalia (`~/.config/gtk-4.0/noctalia.css`) al momento de correr, no un hex fijo. Después de cambiar de wallpaper/paleta:

```bash
~/NoctaliaQ/scripts/recolor-all.sh        # cursor + folders
~/NoctaliaQ/scripts/cursor-recolor.sh     # solo cursor
~/NoctaliaQ/scripts/papirus-recolor.sh    # solo folders
```

También disponibles desde el lanzador de Noctalia. El cursor queda instalado como `Bibata-NoctaliaQ-<hash de paleta>` (el hash cambia en cada recolor para forzar que niri/GTK lo recarguen; no es un bug).

El tema de kitty (`~/.config/kitty/themes/noctalia.conf`) ya lo regenera Noctalia solo, sin scripts nuestros — NoctaliaQ solo le agrega opacidad dinámica (`background_opacity`) y fuente (JetBrainsMono Nerd Font) encima.

## Blur

Global en `.config/niri/config.kdl` (`window-rule` sin `match`, aplica a toda ventana). kitty lo soporta nativo vía el protocolo de niri. Para que se note en apps GTK como Thunar, `gtk.css` importa `noctaliaq-blur.css` con alpha sobre los colores base de Noctalia — si se ve muy sutil o muy fuerte, edítalo directo, no requiere rebuild de nada.

## fastfetch

`~/.config/fastfetch` corre automático al abrir terminal (vía el saludo default de `cachyos-fish-config`, no algo que NoctaliaQ dispare). NoctaliaQ solo trackea y versiona el logo/config (`noctaliaq.txt`).

## Estructura
.config/niri/ config de niri (keybinds, reglas de ventana, blur global)
.config/noctalia/ paletas y settings de Noctalia
.config/gtk-3.0/ .config/gtk-4.0/ tema GTK + transparencia para el blur
.config/kitty/ opacidad + fuente encima del tema que genera Noctalia
.config/fastfetch/ logo y config, corre via el saludo de fish
scripts/ recolor de cursor y folders, instalador
