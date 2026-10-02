#!/usr/bin/env bash
# Restaura el ultimo wallpaper aplicado. Para el autostart de Hyprland.
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="$SCRIPT_DIR/.state"

# El daemon debe existir antes de aplicar nada.
# Se busca su socket de IPC, que es la senal fiable: `pgrep -x` no lo
# detecta en este sistema y `pgrep -f` daria falsos positivos con
# cualquier shell cuya linea de comandos mentione "awww-daemon".
if ! compgen -G "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/wayland-*-awww-daemon.sock" >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
    sleep 0.4
fi

if [[ -f $STATE_FILE ]]; then
    img=$(head -n 1 "$STATE_FILE")
    if [[ -f $img ]]; then
        awww img "$img" --transition-type fade --transition-duration 1 >/dev/null 2>&1
        printf 'fondo restaurado: %s\n' "$(basename -- "$img")"
        exit 0
    fi
fi

printf 'sin wallpaper guardado; se deja el que hubiera\n'
