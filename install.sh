#! /usr/bin/env bash

SRC_DIR=$(cd $(dirname $0) && pwd)

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr"
else
  DEST_DIR="$HOME"
fi

THEME_NAME=MacSequoia

COLOR_VARIANTS=('-Light' '-Dark')

usage() {
  cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)
  -n, --name NAME         Specify theme name (Default: $THEME_NAME)
  -c, --color VARIANT     Specify color variant(s) [light|dark] (Default: All variants)s)
  --round VARIANT         Specify round aurorae variant
  -h, --help              Show help
EOF
}

install() {
  local dest=${1}
  local name=${2}
  local color=${3}

  # Destination directory
  if [[ "$UID" -eq "$ROOT_UID" ]]; then
    AURORAE_DIR="${dest}/share/aurorae/themes"
    SCHEMES_DIR="${dest}/share/color-schemes"
    PLASMA_DIR="${dest}/share/plasma/desktoptheme"
    PLASMOIDS_DIR="${dest}/share/plasma/plasmoids"
    LOOKFEEL_DIR="${dest}/share/plasma/look-and-feel"
    KVANTUM_DIR="${dest}/share/Kvantum"
    WALLPAPER_DIR="${dest}/share/wallpapers"
  else
    AURORAE_DIR="${dest}/.local/share/aurorae/themes"
    SCHEMES_DIR="${dest}/.local/share/color-schemes"
    PLASMA_DIR="${dest}/.local/share/plasma/desktoptheme"
    PLASMOIDS_DIR="${dest}/.local/share/plasma/plasmoids"
    LOOKFEEL_DIR="${dest}/.local/share/plasma/look-and-feel"
    KVANTUM_DIR="${dest}/.config/Kvantum"
    WALLPAPER_DIR="${dest}/.local/share/wallpapers"
    LATTE_DIR="${dest}/.config/latte"
  fi

  [[ ! -d "${AURORAE_DIR}" ]] && mkdir -p ${AURORAE_DIR}
  [[ ! -d "${SCHEMES_DIR}" ]] && mkdir -p ${SCHEMES_DIR}
  [[ ! -d "${PLASMA_DIR}" ]] && mkdir -p ${PLASMA_DIR}
  [[ ! -d "${PLASMOIDS_DIR}" ]] && mkdir -p ${PLASMOIDS_DIR}
  [[ ! -d "${LOOKFEEL_DIR}" ]] && mkdir -p ${LOOKFEEL_DIR}
  [[ ! -d "${KVANTUM_DIR}" ]] && mkdir -p ${KVANTUM_DIR}
  [[ ! -d "${WALLPAPER_DIR}" ]] && mkdir -p ${WALLPAPER_DIR}

  [[ ${color} == '-Dark' ]] && local ELSE_COLOR='Dark'
  [[ ${color} == '-Light' ]] && local ELSE_COLOR='Light'

  [[ -d "${AURORAE_DIR}/${name}${color}" ]] && rm -rf ${AURORAE_DIR}/${name}${color}{'','-1.25x','-1.5x'}
  [[ -d "${PLASMA_DIR}/${name}${color}" ]] && rm -rf ${PLASMA_DIR}/${name}${color}
  [[ -f "${SCHEMES_DIR}/${name}${ELSE_COLOR}".colors ]] && rm -rf ${SCHEMES_DIR}/${name}${ELSE_COLOR}.colors
  [[ -d "${LOOKFEEL_DIR}/com.github.vinceliuice.${name}${color}" ]] && rm -rf ${LOOKFEEL_DIR}/com.github.vinceliuice.${name}${color}
  [[ -d "${KVANTUM_DIR}/${name}" ]] && rm -rf ${KVANTUM_DIR}/${name}
  [[ -d "${WALLPAPER_DIR}/${name}" ]] && rm -rf ${WALLPAPER_DIR}/${name}
  [[ -d "${WALLPAPER_DIR}/${name}${color}" ]] && rm -rf ${WALLPAPER_DIR}/${name}${color}

  if [[ "$round" == 'true' ]]; then
    cp -r ${SRC_DIR}/aurorae/Round/${name}${color}{'','-1.25x','-1.5x'}              ${AURORAE_DIR}
  else
    cp -r ${SRC_DIR}/aurorae/Sharp/${name}${color}{'','-1.25x','-1.5x'}              ${AURORAE_DIR}
  fi

  cp -r ${SRC_DIR}/Kvantum/${name}                                                   ${KVANTUM_DIR}
  cp -r ${SRC_DIR}/color-schemes/${name}${ELSE_COLOR}.colors                         ${SCHEMES_DIR}
  cp -r ${SRC_DIR}/plasma/desktoptheme/${name}${color}                               ${PLASMA_DIR}
  cp -r ${SRC_DIR}/plasma/desktoptheme/icons                                         ${PLASMA_DIR}/${name}${color}
  cp -r ${SRC_DIR}/plasma/look-and-feel/com.github.vinceliuice.${name}${color}       ${LOOKFEEL_DIR}
  cp -r ${SRC_DIR}/wallpapers/${name}                                                ${WALLPAPER_DIR}
  cp -r ${SRC_DIR}/wallpapers/${name}${color}                                        ${WALLPAPER_DIR}
  mkdir -p                                                                           ${PLASMA_DIR}/${name}${color}/wallpapers
  cp -r ${SRC_DIR}/wallpapers/${name}${color}                                        ${PLASMA_DIR}/${name}${color}/wallpapers

  if [[ "$UID" != "$ROOT_UID" && -d "${LATTE_DIR}" ]]; then
    if [[ -f ${LATTE_DIR}/${name}.layout.latte ]]; then
      rm -rf ${LATTE_DIR}/${name}{'','_x2'}.layout.latte
    fi

    cp -r ${SRC_DIR}/latte-dock/${name}{'','_x2'}.layout.latte         ${LATTE_DIR}
  fi
}

while [[ "$#" -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "Destination directory does not exist. Let's make a new one..."
        mkdir -p ${dest}
      fi
      shift 2
      ;;
    -n|--name)
      name="${1}"
      shift
      ;;
    --round)
      round='true'
      echo -e "Install rounded Aurorae version."
      shift
      ;;
    -c|--color)
      shift
      for variant in "$@"; do
        case "$variant" in
          light)
            colors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo -e "ERROR: Unrecognized color variant '$1'."
            echo -e "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo -e "ERROR: Unrecognized installation option '$1'."
      echo -e "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

echo -e "Installing '${THEME_NAME} kde themes'..."

for color in "${colors[@]:-${COLOR_VARIANTS[@]}}"; do
  install "${dest:-$DEST_DIR}" "${name:-${THEME_NAME}}" "${color}"
done

echo -e "Install finished..."
