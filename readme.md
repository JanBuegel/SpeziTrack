# 🧊 SpeziTrack

**Real-time ICE CLI Dashboard für Menschen mit Vertrauen in `curl`, `jq` – und einem tiefen Bedürfnis nach `Krombacher Spezi`.**

---

## 🚄 Was ist das?

`SpeziTrack` ist ein absurd praktisches Terminal-Tool, das:

- deinen aktuellen **ICE-Zugstatus** live anzeigt  
- den **nächsten Halt** + Ankunfts- & Abfahrtszeiten listet  
- daraus automatisch **Raucherpausen** ableitet 🚬  
- prüft, ob es aktuell **Krombacher Spezi** im Bordbistro gibt 🥤

Weil was bringt dir 300 km/h, wenn du mit Cola Zero fährst?

---

## 📦 Anforderungen

- `bash` oder `zsh`
- `curl`
- `jq` (>= 1.6)
- ein Internetzugang über das ICE-WLAN (`WIFIonICE`)

---

## 🛠 Installation

```bash
git clone https://github.com/JanBuegel/SpeziTrack.git
cd spezitrack
chmod +x ice-status.sh'''

## Usage
watch -n 30 "./ice-status.sh '{Zielbahnhof}'"
