#!/bin/bash

# Endpunkte
TRIP_ENDPOINT="https://iceportal.de/api1/rs/tripInfo/trip"
STATUS_ENDPOINT="https://iceportal.de/api1/rs/status"

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

# Anzeige
echo ""
echo "+----------------------------------------------------------+"
printf "| ICE %s – %s\n" "$train" "$date"
echo "+----------------------------------------------------------+"
printf "| 📍 Letzter Halt      : %-30s |\n" "$lastStopName"
printf "| ⏭️  Nächster Halt     : %-30s |\n" "$nextName"
printf "| 🕓 Ankunft (soll/ist): %-20s %-5s |\n" "$arrTime" "$arrDelay"
printf "| 🕒 Abfahrt (soll/ist): %-20s %-5s |\n" "$depTime" "$depDelay"
printf "| 🚬 Aufenthalt        : %-30s |\n" "${standMin} min"
printf "| 🏁 Endstation        : %-30s |\n" "$final"
printf "| 💨 Geschwindigkeit   : %3s km/h                      |\n" "$speed"
if [[ -n "$delayReason" ]]; then
  printf "| 🔴 Grund Verspätung  : %-30s |\n" "$delayReason"
fi
echo "+----------------------------------------------------------+"
# --- Sonderanzeige für Kassel-Wilhelmshöhe ---
kw_stop=$(echo "$trip" | jq -r '.trip.stops[] | select(.station.name == "Kassel-Wilhelmshöhe")')

if [[ -n "$kw_stop" ]]; then
  kw_arr=$(echo "$kw_stop" | jq -r '.timetable.actualArrivalTime')
  kw_delay=$(echo "$kw_stop" | jq -r '.timetable.arrivalDelay // ""')
  kw_time=$(date -r $((kw_arr / 1000)) +"%H:%M")
  echo ""
  echo "📌 Kassel-Wilhelmshöhe: Ankunft geplant um $kw_time ${kw_delay:+($kw_delay)}"
fi

# --- Spezi-Verfügbarkeitsanzeige ---
products=$(curl -s https://iceportal.de/bap/api/products)

spezi_status=$(echo "$products" | jq -r '.[] | select(.ecmId == 13294226) | .available')

if [[ "$spezi_status" == "true" ]]; then
  echo "🥤 Krombacher Spezi ist VERFÜGBAR!"
else
  echo "❌ Krombacher Spezi leider nicht verfügbar."
fi

echo ""
