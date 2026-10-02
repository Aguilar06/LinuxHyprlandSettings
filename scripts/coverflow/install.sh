#!/usr/bin/env bash
# ============================================
#  Coverflow 3D - Instalacion de dependencias
# ============================================
#
#  Todo lo que hace falta esta en los repositorios oficiales:
#  no hay nada que compilar desde el AUR.
#
#      quickshell   interfaz del carrusel (QtQuick)
#      imagemagick  miniaturas
#
#  Y ya debes tener instalados:
#      awww         transiciones del fondo (swww ya no existe)
#      wallust      paleta de colores
#
# ============================================

set -euo pipefail

PACKAGES=(quickshell imagemagick)

RED=$'\033[0;31m'; OK=$'\033[0;32m'; WARN=$'\033[1;33m'; OFF=$'\033[0m'

echo "Paquetes a instalar:"
printf '  - %s\n' "${PACKAGES[@]}"
echo

# Aviso previo de lo que ya deberia estar.
missing_tools=()
command -v awww    >/dev/null 2>&1 || missing_tools+=("awww")
command -v wallust >/dev/null 2>&1 || missing_tools+=("wallust")

if [ ${#missing_tools[@]} -gt 0 ]; then
    printf '%s[aviso]%s Faltan: %s\n' "$WARN" "$OFF" "${missing_tools[*]}"
    echo "        awww    -> sudo pacman -S awww"
    echo "        wallust -> yay -S wallust"
    echo
fi

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

printf '%s[ok]%s Dependencias instaladas\n' "$OK" "$OFF"

# Comprobacion final.
fail=0
for cmd in quickshell magick awww wallust; do
    if command -v "$cmd" >/dev/null 2>&1; then
        printf '  %-10s %s\n' "$cmd" "ok"
    else
        printf '  %-10s %s\n' "$cmd" "FALTA"
        fail=1
    fi
done

if [ "$fail" -ne 0 ]; then
    printf '\n%s[aviso]%s Revisa los que faltan antes de abrir el carrusel.\n' "$WARN" "$OFF"
fi

cat <<'EOF'

Listo. Para usarlo:

  hyprctl reload          # recargar los atajos
  SUPER + T               # abrir con el menu de modos
  SUPER + SHIFT + T      # abrir directo en modo Wallpapers

Tus wallpapers van en:

  ~/.config/hypr/scripts/coverflow/themes/wallpapers/

Los subdirectorios de ahi se interpretan como albunes.
EOF
