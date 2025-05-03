#!/bin/bash

endpoint="https://iceportal.de/api1/rs/status"

# Terminal vorbereiten
tput civis # Cursor unsichtbar
trap "tput cnorm; exit" INT

draw_tacho() {
  local speed="$1"

  # Begrenzung
  max=300
  step=5
  width=$(( max / step ))

  # Position des Zeigers berechnen
  pos=$(( speed / step ))
  [ $pos -gt $width ] && pos=$width

  # Linie generieren
  line=""
  for ((i=0; i<=$width; i++)); do
    if [ $i -eq $pos ]; then
      line+="^"
    else
      line+="-"
    fi
  done

  # Achsenbeschriftung
  echo "0     50    100   150   200   250   300"
  echo "$line"
  printf "%*s\n" $((pos + 1)) "${speed} km/h"
}

while true; do
  # Cursor nach oben setzen (3 Zeilen)
  tput cuu 3 >/dev/null 2>&1

  data=$(curl -s "$endpoint")

  speed=$(echo "$data" | jq '.speed // 0' | awk '{printf("%.0f", $1)}')

  draw_tacho "$speed"

  sleep 1
done
