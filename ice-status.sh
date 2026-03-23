#!/bin/bash

# Endpunkte
TRIP_ENDPOINT="https://iceportal.de/api1/rs/tripInfo/trip"
STATUS_ENDPOINT="https://iceportal.de/api1/rs/status"

ZIEL_BAHNHOF="${1:-Kassel-Wilhelmshöhe}"

# JSON holen
trip=$(curl -s "$TRIP_ENDPOINT")
status=$(curl -s "$STATUS_ENDPOINT")

# Variablen extrahieren
train=$(echo "$trip" | jq -r '.trip.vzn')
date=$(echo "$trip" | jq -r '.trip.tripDate')
final=$(echo "$trip" | jq -r '.trip.stopInfo.finalStationName')
nextEva=$(echo "$trip" | jq -r '.trip.stopInfo.actualNext')
lastEva=$(echo "$trip" | jq -r '.trip.stopInfo.actualLast')
speed=$(echo "$status" | jq '.speed // 0' | awk '{printf("%.0f", $1)}')

# Nächster Halt finden
nextStop=$(echo "$trip" | jq -r --arg eva "$nextEva" '.trip.stops[] | select(.station.evaNr == $eva)')
nextName=$(echo "$nextStop" | jq -r '.station.name')
arrEpoch=$(echo "$nextStop" | jq -r '.timetable.actualArrivalTime')
depEpoch=$(echo "$nextStop" | jq -r '.timetable.actualDepartureTime')
arrDelay=$(echo "$nextStop" | jq -r '.timetable.arrivalDelay // ""')
depDelay=$(echo "$nextStop" | jq -r '.timetable.departureDelay // ""')
delayReason=$(echo "$nextStop" | jq -r '.delayReasons[0].text // ""')

# Zeiten formatieren
arrTime=$(date -r $((arrEpoch / 1000)) +"%H:%M")
depTime=$(date -r $((depEpoch / 1000)) +"%H:%M")

# Letzter Halt
lastStopName=$(echo "$trip" | jq -r --arg eva "$lastEva" '.trip.stops[] | select(.station.evaNr == $eva) | .station.name')

# Aufenthalt berechnen
standMin=$(( (depEpoch - arrEpoch) / 60000 ))

# Wunschbahnhof
fav_stop=$(echo "$trip" | jq -r --arg name "$ZIEL_BAHNHOF" '.trip.stops[] | select(.station.name == $name)')

# Spezi-Verfügbarkeit
products=$(curl -s https://iceportal.de/bap/api/products)
spezi_status=$(echo "$products" | jq -r '.[] | select(.ecmId == 13294226) | .available')

# Bahn Expert URL
bahn_expert_url="https://bahn.expert/details/$(echo "$train" | sed 's/ /%20/')/"

# --- Ausgabe ---
SEP="+----------------------------------------------------------+"

box() {
  local content="$1"
  local vis
  vis=$(printf '%s' "$content" | python3 -c "
import unicodedata, sys
def w(c):
    cp = ord(c)
    if cp == 0xFE0F: return 0                                    # Variation Selector-16
    if unicodedata.category(c).startswith('M'): return 0         # Combining marks (e.g. decomposed umlauts)
    if unicodedata.east_asian_width(c) in ('W', 'F'): return 2
    if 0x2300 <= cp <= 0x2BFF or 0x1F000 <= cp <= 0x1FFFF: return 2
    return 1
text = unicodedata.normalize('NFC', sys.stdin.read())            # normalise ü/ö/ä to single code points
print(sum(w(c) for c in text))
")
  local pad=$(( 56 - vis ))
  (( pad < 0 )) && pad=0
  printf "| %s%-${pad}s |\n" "$content" ""
}

echo ""
echo "$SEP"
box "🚆 ICE $train  –  $date"
echo "$SEP"
box "📍 Letzter Halt      : $lastStopName"
box "⏭️  Nächster Halt     : $nextName"
box "🕓 Ankunft (soll/ist): $arrTime${arrDelay:+ ($arrDelay)}"
box "🕒 Abfahrt (soll/ist): $depTime${depDelay:+ ($depDelay)}"
box "🚬 Aufenthalt        : ${standMin} min"
box "🏁 Endstation        : $final"
box "💨 Geschwindigkeit   : $speed km/h"
[[ -n "$delayReason" ]] && box "🔴 Grund Verspätung  : $delayReason"
echo "$SEP"
box "🔗 Bahn Expert: $bahn_expert_url"
echo "$SEP"
if [[ -n "$fav_stop" ]]; then
  fav_arr=$(echo "$fav_stop" | jq -r '.timetable.actualArrivalTime')
  fav_delay=$(echo "$fav_stop" | jq -r '.timetable.arrivalDelay // ""')
  fav_time=$(date -r $((fav_arr / 1000)) +"%H:%M")
  box "📌 $ZIEL_BAHNHOF: Ankunft $fav_time${fav_delay:+ ($fav_delay)}"
fi
if [[ "$spezi_status" == "true" ]]; then
  box "🥤 Krombacher Spezi ist VERFÜGBAR!"
else
  box "❌ Krombacher Spezi leider nicht verfügbar."
fi
echo "$SEP"
echo ""
