#!/usr/bin/env bash
# Author: Dolores Portalatin <hello@doloresportalatin.info>
# Dependencies: imagemagick, i3lock-color-git, scrot
# Lock ring input appears inside Lock layer
# value: Boolean
# Custom result

# WALLPAPER
#
# See screenshot as wallpaper
# value: Boolean
use_screenshot=true
#
# If set $use_screenshot as false, have to declare wallpaper absolute path
# value: Boolean
wallpaper=false
#

# EDIT WALLPAPER
#
# Blur value
# available value here: https://imagewmagick.org/Usage/blur/blur_montage.jpg
blur_value=0x4
#
# Dim percent value
# value: Percent
dim_value=60%
#

# LOCK LAYER
#
# Use Lock layer or not
# value: Boolean
use_lock=true
lock="$HOME/Git/tungcena-i3lock/lock.png"
#
# Set Lock layer location in screen
# value: Percent or Number in pixel
lock_x=10%
lock_y=80%

ring_inside_lock=true
#
# should set center of lock icon
# so Lock ring input will overlay lock icon
# if $ring_inside_lock is false, $ring_x and $ring_y will be coordinates of screen
# value: Number in pixel
ring_x=10
ring_y=10
#
# Calculate Lock ring input location
if [[ $ring_inside_lock = true ]]
then
  ring_screen_x=$(($x+$ring_x))
  ring_screen_y=$(($y+$ring_y))
else
  ring_screen_x=$ring_x
  ring_screen_y=$ring_y
fi

# Merge Lock layer and $screenshot
if [[ "$use_lock" = true ]]
then
  lock_w=$(identify -format "%w" $lock)
  lock_h=$(identify -format "%h" $lock)
  x=$lock_x
  y=$lock_y

  if [[ $lock_x =~ "%" ]]
  then
    x=$(($(echo $lock_x| cut -d'%' -f 1)*$screen_w/100))
  fi

  if [[ $lock_y =~ "%" ]]
  then
    y=$(($(echo $lock_y| cut -d'%' -f 1)*$screen_h/100))
  fi

  if [[ $x < 0 ]]
  then
    merge_x=-$x
  else
    merge_x=+$x
  fi

  if [[ $y < 0 ]]
  then
    merge_y=-$y
  else
    merge_y=+$y
  fi
  convert "$IMAGE" \
    "$lock" -geometry "$merge_x""$merge_y" -composite \
    "$screenshot"

fi
set -o errexit -o noclobber -o nounset

HUE=(-level 0%,100%,0.6)
EFFECT=(-filter Gaussian -resize 20% -define filter:sigma=1.5 -resize 500.5%)
# default system sans-serif font
FONT="$(convert -list font | awk "{ a[NR] = \$2 } /family: $(fc-match sans -f "%{family}\n")/ { print a[NR-1]; exit }")"
IMAGE="$(mktemp).png"

OPTIONS="Options:
    -h, --help   This help menu.
    -g, --greyscale  Set background to greyscale instead of color.
    -p, --pixelate   Pixelate the background instead of blur, runs faster.
    -f <fontname>, --font <fontname>  Set a custom font. Type 'convert -list font' in a terminal to get a list."

# move pipefail down as for some reason "convert -list font" returns 1
set -o pipefail
trap 'rm -f "$IMAGE"' EXIT
TEMP="$(getopt -o :hpgf: -l help,pixelate,greyscale,font: --name "$0" -- "$@")"
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h|--help)
            printf "Usage: $(basename $0) [options]\n\n$OPTIONS\n\n" ; exit 1 ;;
        -g|--greyscale) HUE=(-level 0%,100%,0.6 -set colorspace Gray -separate -average) ; shift ;;
        -p|--pixelate) EFFECT=(-scale 10% -scale 1000%) ; shift ;;
        -f|--font)
            case "$2" in
                "") shift 2 ;;
                *) FONT=$2 ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) echo "error" ; exit 1 ;;
    esac
done

SCRIPTPATH="/usr/share/i3lock-fancy"

# l10n support
TEXT="Type password to unlock"
case "$LANG" in
    de_* ) TEXT="Bitte Passwort eingeben" ;; # Deutsch
    en_* ) TEXT="Type password to unlock" ;; # English
    es_* ) TEXT="Ingrese su contrase??a" ;; # Espa??ola
    fr_* ) TEXT="Entrez votre mot de passe" ;; # Fran??ais
    pl_* ) TEXT="Podaj has??o" ;; # Polish
esac

scrot -z "$IMAGE"
ICON="$SCRIPTPATH/lock.png"
PARAM=(--insidecolor=373445ff --ringcolor=ffffffff --line-uses-inside \
  --keyhlcolor=d23c3dff --bshlcolor=d23c3dff --separatorcolor=00000000 \
  --insidevercolor=fecf4dff --insidewrongcolor=d23c3dff \
  --ringvercolor=ffffffff --ringwrongcolor=ffffffff \
  --veriftext="" --wrongtext="" --noinputtext="" \
  --indpos="x+"$ring_screen_x":y+"$ring_screen_y"" \
  --radius=10 --ring-width=5)

LOCK=()
while read LINE
do
    if [[ "$LINE" =~ ([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+) ]]; then
        W=${BASH_REMATCH[1]}
        H=${BASH_REMATCH[2]}
        Xoff=${BASH_REMATCH[3]}
        Yoff=${BASH_REMATCH[4]}
        MIDXi=$(($W / 2 + $Xoff - 60  / 2))
        MIDYi=$(($H / 2 + $Yoff - 60  / 2))
        MIDXt=$(($W / 2 + $Xoff - 285 / 2))
        MIDYt=$(($H / 2 + $Yoff + 320 / 2))
        LOCK+=(-font $FONT -pointsize 26 -fill lightgrey -stroke grey10 \
               -strokewidth 2 -annotate +$MIDXt+$MIDYt "$TEXT" \
               -fill lightgrey -stroke lightgrey -strokewidth 1 -annotate +$MIDXt+$MIDYt "$TEXT" \
               $ICON -geometry +$MIDXi+$MIDYi -composite)
    fi
done <<<"$(xrandr)"

convert "$IMAGE" "${HUE[@]}" "${EFFECT[@]}" "${LOCK[@]}" "$IMAGE"

# try to use a forked version of i3lock with prepared parameters
if ! i3lock -n "${PARAM[@]}" -i "$IMAGE" > /dev/null 2>&1; then
    # We have failed, lets get back to stock one
    i3lock -n -i "$IMAGE"
fi
