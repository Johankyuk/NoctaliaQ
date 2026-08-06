#!/usr/bin/env bash
# noctaliaq-keyboard.sh — retroiluminacion del teclado, NoctaliaQ.
#
# Reemplaza asusctl/rog-control-center por sysfs directo, sin ningun daemon.
# Solo color solido + brillo por ahora (sin breathing/rainbow/strobe todavia
# — es lo que pediste como prioridad). El "mode = static (0)" es el unico
# dato 100% consistente entre TODAS las fuentes consultadas para hardware
# asus-wmi/TUF, asi que es seguro confiar en el; el resto (interfaz nueva vs
# vieja) se detecta en caliente.
#
# Interfaces posibles (se detecta cual existe en tu equipo, en este orden):
#   A) moderna:  /sys/class/leds/asus::kbd_backlight/kbd_rgb_mode
#      formato:  echo "<cmd> 0 <r> <g> <b> 0" > kbd_rgb_mode   (r/g/b 0-255, cmd ignorado)
#   B) legacy:   /sys/devices/platform/asus-nb-wmi/kbbl/kbbl_{red,green,blue,mode,speed,flags,set}
#      formato:  se escribe cada componente por separado, mode=0, y kbbl_set=1 al final para confirmar
# Brillo (0-3) siempre por: /sys/class/leds/asus::kbd_backlight/brightness
#
# Sin sudo en el uso normal: el udev rule (ver install.sh) le da permiso de
# escritura al grupo `video` sobre estos nodos. Si tu usuario no esta en ese
# grupo: sudo usermod -aG video "$USER" (requiere cerrar sesion).
#
#   noctaliaq-keyboard.sh                wizard interactivo (sin argumentos)
#   noctaliaq-keyboard.sh color RRGGBB   fija color solido (sin # al inicio)
#   noctaliaq-keyboard.sh brillo <0-3>   fija el nivel de brillo
#   noctaliaq-keyboard.sh apply          re-aplica el ultimo color+brillo guardado
#   noctaliaq-keyboard.sh --diag         lista los nodos detectados en tu equipo
#   noctaliaq-keyboard.sh --actual       estado (una linea por dato)
set -uo pipefail
P='\033[0;35m'; G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; N='\033[0m'
C='\033[0;36m'; D='\033[2m'
log(){ echo -e "${P}[kbd]${N} $1"; }; ok(){ echo -e "${G}[+]${N} $1"; }
warn(){ echo -e "${Y}[i]${N} $1"; }; err(){ echo -e "${R}[x]${N} $1"; }

LED_DIR=/sys/class/leds/asus::kbd_backlight
BRIGHT="$LED_DIR/brightness"
RGB_MODERNO="$LED_DIR/kbd_rgb_mode"
KBBL_DIR=/sys/devices/platform/asus-nb-wmi/kbbl
CONF="$HOME/.config/noctaliaq/keyboard.conf"
DEFAULT_BRIGHT=2

_interfaz(){
    # imprime: moderna | legacy | ninguna
    [ -e "$RGB_MODERNO" ] && { echo moderna; return; }
    [ -d "$KBBL_DIR" ] && [ -e "$KBBL_DIR/kbbl_red" ] && { echo legacy; return; }
    echo ninguna
}

_hex_a_dec(){ # $1 = componente de 2 hex chars -> imprime decimal
    printf '%d' "0x$1"
}

_set_color(){ # $1 = RRGGBB (sin #)
    local hex="${1#\#}"
    [[ "$hex" =~ ^[0-9a-fA-F]{6}$ ]] || { err "color invalido, usa formato RRGGBB (ej. 7aa2f7)."; return 1; }
    local r g b interfaz
    r=$(_hex_a_dec "${hex:0:2}"); g=$(_hex_a_dec "${hex:2:2}"); b=$(_hex_a_dec "${hex:4:2}")
    interfaz=$(_interfaz)
    case "$interfaz" in
        moderna)
            echo "1 0 $r $g $b 0" | tee "$RGB_MODERNO" >/dev/null 2>&1 \
                || { echo "1 0 $r $g $b 0" | sudo tee "$RGB_MODERNO" >/dev/null 2>&1; }
            ;;
        legacy)
            printf '%02x' "$r" | tee "$KBBL_DIR/kbbl_red" >/dev/null 2>&1 || printf '%02x' "$r" | sudo tee "$KBBL_DIR/kbbl_red" >/dev/null
            printf '%02x' "$g" | tee "$KBBL_DIR/kbbl_green" >/dev/null 2>&1 || printf '%02x' "$g" | sudo tee "$KBBL_DIR/kbbl_green" >/dev/null
            printf '%02x' "$b" | tee "$KBBL_DIR/kbbl_blue" >/dev/null 2>&1 || printf '%02x' "$b" | sudo tee "$KBBL_DIR/kbbl_blue" >/dev/null
            echo 0 | tee "$KBBL_DIR/kbbl_mode" >/dev/null 2>&1 || echo 0 | sudo tee "$KBBL_DIR/kbbl_mode" >/dev/null
            echo 1 | tee "$KBBL_DIR/kbbl_set" >/dev/null 2>&1 || echo 1 | sudo tee "$KBBL_DIR/kbbl_set" >/dev/null
            ;;
        ninguna)
            err "No encontre ni $RGB_MODERNO ni $KBBL_DIR — corre '--diag' y revisa que existe en tu equipo."
            return 1 ;;
    esac
    mkdir -p "$(dirname "$CONF")"
    local brillo_actual; brillo_actual=$(grep -oP '(?<=BRIGHTNESS=)\d+' "$CONF" 2>/dev/null || echo "$DEFAULT_BRIGHT")
    printf 'COLOR=%s\nBRIGHTNESS=%s\n' "$hex" "$brillo_actual" > "$CONF"
    ok "Color de teclado -> #${hex} (interfaz $interfaz)."
}

_set_brillo(){ # $1 = 0-3
    case "$1" in 0|1|2|3) ;; *) err "el brillo debe ser 0, 1, 2 o 3."; return 1 ;; esac
    [ -e "$BRIGHT" ] || { err "No encontre $BRIGHT en este equipo."; return 1; }
    echo "$1" | tee "$BRIGHT" >/dev/null 2>&1 || echo "$1" | sudo tee "$BRIGHT" >/dev/null
    local post; post=$(cat "$BRIGHT" 2>/dev/null)
    [ "$post" = "$1" ] || { err "El firmware no acepto el brillo $1 (sigue en $post)."; return 1; }
    mkdir -p "$(dirname "$CONF")"
    local color_actual; color_actual=$(grep -oP '(?<=COLOR=)[0-9a-fA-F]{6}' "$CONF" 2>/dev/null || echo "")
    { [ -n "$color_actual" ] && echo "COLOR=$color_actual"; echo "BRIGHTNESS=$1"; } > "$CONF"
    ok "Brillo de teclado -> $1."
}

_apply(){
    [ -r "$CONF" ] || { warn "No hay configuracion guardada todavia (usa el wizard o 'color'/'brillo')."; return 0; }
    local color brillo
    color=$(grep -oP '(?<=COLOR=)[0-9a-fA-F]{6}' "$CONF" 2>/dev/null || echo "")
    brillo=$(grep -oP '(?<=BRIGHTNESS=)\d+' "$CONF" 2>/dev/null || echo "$DEFAULT_BRIGHT")
    [ -n "$color" ] && _set_color "$color"
    _set_brillo "$brillo"
}

_diag(){
    echo -e "  ${P}Diagnostico de hardware — teclado${N}"
    echo -e "  ${D}─────────────────────────────────────────────${N}"
    if [ -d "$LED_DIR" ]; then
        ok "Existe $LED_DIR"
        ls -la "$LED_DIR" 2>/dev/null | sed 's/^/    /'
    else
        err "No existe $LED_DIR"
    fi
    echo ""
    if [ -d "$KBBL_DIR" ]; then
        ok "Existe $KBBL_DIR (interfaz legacy)"
        ls -la "$KBBL_DIR" 2>/dev/null | sed 's/^/    /'
    else
        warn "No existe $KBBL_DIR (normal si tu kernel usa solo la interfaz moderna)"
    fi
    echo ""
    log "Interfaz RGB detectada: $(_interfaz)"
    [ -e "$BRIGHT" ] && log "Brillo actual: $(cat "$BRIGHT" 2>/dev/null)" || warn "No encontre el nodo de brillo."
}

_pausa(){ echo ""; read -rsn1 -p "$(echo -e "  ${D}[cualquier tecla para volver]${N}")"; echo ""; }

_wizard(){
    [ -t 0 ] || { echo "uso: noctaliaq-keyboard.sh [color RRGGBB|brillo <0-3>|apply|--diag|--actual]"; return 0; }
    local opt color brillo interfaz
    while true; do
        interfaz=$(_interfaz)
        color=$(grep -oP '(?<=COLOR=)[0-9a-fA-F]{6}' "$CONF" 2>/dev/null || echo "sin definir")
        brillo=$([ -e "$BRIGHT" ] && cat "$BRIGHT" 2>/dev/null || echo "?")

        printf '\033[2J\033[H'
        echo -e "  ${P}NoctaliaQ · TECLADO${N}"
        echo -e "  ${D}─────────────────────────────────────────────${N}"
        echo -e "  Interfaz ${C}${interfaz}${N}   ·   Color ${C}#${color}${N}   ·   Brillo ${C}${brillo}/3${N}"
        [ "$interfaz" = ninguna ] && echo -e "  ${R}No detecto ningun nodo compatible — usa la opcion 5 para diagnosticar.${N}"
        echo ""
        echo -e "   ${C}1${N}  Usar el accent activo de Noctalia   ${D}mismo color que folders de Thunar${N}"
        echo -e "   ${C}2${N}  Color manual (RRGGBB)"
        echo -e "   ${C}3${N}  Subir brillo"
        echo -e "   ${C}4${N}  Bajar brillo"
        echo -e "   ${C}5${N}  Diagnostico"
        echo ""
        echo -e "     ${C}0${N}  Salir"
        echo ""
        read -rsn1 -p "$(echo -e "  ${P}>${N} ")" opt
        echo ""
        case "$opt" in
            1)
                local dir; dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
                # shellcheck disable=SC1091
                source "$dir/lib-palette.sh" && extract_palette >/dev/null 2>&1 \
                    && _set_color "${ACCENT#\#}" \
                    || err "No pude leer la paleta activa de Noctalia."
                _pausa ;;
            2) read -rp "  Color (RRGGBB, sin #): " c; _set_color "$c"; _pausa ;;
            3) b=$(cat "$BRIGHT" 2>/dev/null || echo 0); [ "$b" -lt 3 ] && _set_brillo $((b+1)) || warn "ya esta al maximo."; _pausa ;;
            4) b=$(cat "$BRIGHT" 2>/dev/null || echo 0); [ "$b" -gt 0 ] && _set_brillo $((b-1)) || warn "ya esta al minimo."; _pausa ;;
            5) printf '\033[2J\033[H'; _diag; _pausa ;;
            0|q|Q) printf '\033[2J\033[H'; return 0 ;;
            *) ;;
        esac
    done
}

case "${1:-}" in
    color) [ -n "${2:-}" ] || { err "uso: noctaliaq-keyboard.sh color RRGGBB"; exit 1; }; _set_color "$2" ;;
    brillo) [ -n "${2:-}" ] || { err "uso: noctaliaq-keyboard.sh brillo <0-3>"; exit 1; }; _set_brillo "$2" ;;
    apply) _apply ;;
    --diag|diag) _diag ;;
    --actual|actual)
        echo "Interfaz RGB:  $(_interfaz)"
        [ -e "$BRIGHT" ] && echo "Brillo:        $(cat "$BRIGHT" 2>/dev/null)/3" || echo "Brillo:        no soportado"
        [ -r "$CONF" ] && echo "Guardado:      $(cat "$CONF" | tr '\n' ' ')"
        ;;
    --help|-h) echo "uso: noctaliaq-keyboard.sh [color RRGGBB|brillo <0-3>|apply|--diag|--actual]" ;;
    "") _wizard ;;
    *) err "opción desconocida: $1"; echo "uso: noctaliaq-keyboard.sh [color RRGGBB|brillo <0-3>|apply|--diag|--actual]"; exit 1 ;;
esac
