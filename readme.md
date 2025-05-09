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
chmod +x ice-status.sh
```

---

## ▶️ Usage

### Standard (zeigt Kassel-Wilhelmshöhe):

```bash
watch -n 30 ./ice-status.sh
```

### Mit Wunschbahnhof (z.B. Fulda):

```bash
watch -n 30 ./ice-status.sh "Fulda"
```

---

## 📸 Beispielausgabe

```
+----------------------------------------------------------+
| ICE 685 – 2025-05-03
+----------------------------------------------------------+
| 📍 Letzter Halt      : Hannover Hbf
| ⏭️  Nächster Halt     : Göttingen
| 🕓 Ankunft (soll/ist): 21:24 (+24)
| 🕒 Abfahrt (soll/ist): 21:26 (+24)
| 🚬 Aufenthalt        : 2 min
| 🏁 Endstation        : München Hbf
| 💨 Geschwindigkeit   :  70 km/h
| 🔴 Grund Verspätung  : Verspätung eines vorausfahrenden Zuges
+----------------------------------------------------------+
🥤 Krombacher Spezi ist VERFÜGBAR!
📌 Kassel-Wilhelmshöhe: Ankunft geplant um 21:42 (+23)
```

---

## 📜 Lizenz

MIT.  
Benutzung auf eigene Gefahr – besonders im Raucherbereich.
