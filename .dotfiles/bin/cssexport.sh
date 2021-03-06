#!/bin/sh

# Exports the .Xresources colors to a CSS file format (used with UserChrome.css or Stylish),



CSS=$HOME/.cache/homepage/colors.css



# grab colors from .Xresources

bg=$(xrdb -query | awk '/\*.background/ {print $2}')

fg=$(xrdb -query | awk '/\*.foreground/ {print $2}')

color0=$(xrdb -query | awk '/color0:/  {print $2}')

color1=$(xrdb -query | awk '/color1:/  {print $2}')

color2=$(xrdb -query | awk '/color2:/  {print $2}')

color3=$(xrdb -query | awk '/color3:/  {print $2}')

color4=$(xrdb -query | awk '/color4:/  {print $2}')

color5=$(xrdb -query | awk '/color5:/  {print $2}')

color6=$(xrdb -query | awk '/color6:/  {print $2}')

color7=$(xrdb -query | awk '/color7:/  {print $2}')

color8=$(xrdb -query | awk '/color8:/  {print $2}')

color9=$(xrdb -query | awk '/color9:/  {print $2}')

color10=$(xrdb -query | awk '/color10:/  {print $2}')

color11=$(xrdb -query | awk '/color11:/  {print $2}')

color12=$(xrdb -query | awk '/color12:/  {print $2}')

color13=$(xrdb -query | awk '/color13:/  {print $2}')

color14=$(xrdb -query | awk '/color14:/  {print $2}')

color15=$(xrdb -query | awk '/color15:/  {print $2}')



# FIREFOX CSS

cat > $CSS <<-EOCFG

:root {

  --bg: $bg;

  --fg: $fg;

  --blk: $color0;

  --red: $color1;

  --grn: $color2;

  --ylw: $color3;

  --blu: $color4;

  --mag: $color5;

  --cyn: $color6;

  --wht: $color7;

  --bblk: $color8;

  --bred: $color9;

  --bgrn: $color10;

  --bylw: $color11;

  --bblu: $color12;

  --bmag: $color13;

  --bcyn: $color14;

  --bwht: $color15;

} 

EOCFG