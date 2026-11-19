# Face-Tracking-Avatar

Eine SVG-Figur, die per Webcam deine Mimik nachmacht: Blinzeln, Blickrichtung,
Augenbrauen, Mund, Nase, Kopfneigung und Schultern.

Alles läuft **lokal im Browser**. Es werden keine Videos oder Bilder hochgeladen
oder gespeichert. Bibliothek und Modell liegen im Repository, es gibt keine
Anfragen an externe Server.

## Demo

https://DEIN-NUTZERNAME.github.io/REPO-NAME/

## Bedienung

1. Seite öffnen und **Kamera starten** klicken, Zugriff erlauben.
2. Unter **Figur** eine Figur wählen.
3. Unter **Hintergrund** eine Farbe wählen (Greenscreen, Bluescreen, Magenta …).
4. **Greenscreen-Ansicht** blendet alles außer der Figur aus.
   Beenden mit **Esc** oder **Doppelklick**.
5. Direktlink für die Greenscreen-Ansicht: `?clean` an die URL hängen.

## Lokal starten

Die Kamera funktioniert nur über `https://` oder `http://localhost`.

```bash
npx serve
# danach http://localhost:3000 öffnen
```

## Projektstruktur

```text
├── index.html                    Seite und Logik
├── assets/
│   ├── philosoph.svg             Figuren
│   ├── smiley.svg
│   └── figures.json              Liste der Figuren (automatisch erzeugt)
├── vendor/
│   ├── vision_bundle.mjs         MediaPipe Tasks Vision
│   └── wasm/                     WebAssembly-Dateien
├── models/
│   └── face_landmarker.task      Face-Landmarker-Modell
├── update-figures.sh             Figurenliste erzeugen (Linux/macOS)
├── update-figures.ps1            Figurenliste erzeugen (Windows)
└── .github/workflows/
    └── update-figures.yml        GitHub Action
```

## Neue Figur hinzufügen

1. SVG als `assets/NAME.svg` speichern (Format siehe unten).
2. Liste aktualisieren:
   - **Automatisch:** `git push`. Die GitHub Action erzeugt `assets/figures.json`.
   - **Lokal:** `./update-figures.sh` bzw. `update-figures.ps1`
3. Seite mit **Strg + F5** neu laden.

Auf GitHub Pages kann ein Browser keinen Ordner auflisten. Deshalb wird
`assets/figures.json` gebraucht. Lokal funktioniert auch die Verzeichnisliste
des Servers.

## Figurenformat

`viewBox="0 0 720 720"`, kein Hintergrund (transparent).

### Pflicht-IDs (jeweils genau einmal)

| ID | Element | Das Skript verändert |
|----|---------|----------------------|
| `head` | `<g>` | `style.transform` (Drehen, Verschieben) |
| `irisL`, `irisR` | `<g>` in einer `<g clip-path>` | `transform="translate(x y)"` |
| `pupilL`, `pupilR` | `<circle>` | nichts (nur Kennung) |
| `lidL`, `lidR` | `<rect height="0">` in Hautfarbe | `height` |
| `browL`, `browL2`, `browR`, `browR2` | `<line>` (Umriss + Füllung) | `y1`, `y2` |
| `mouthFill`, `mouthLine` | `<path>` | `d` (komplett) |

### Optionale IDs

| ID | Element | Das Skript verändert |
|----|---------|----------------------|
| `nose` | `<path>` oder `<g>` | `transform` (verschieben, drehen, skalieren) |
| `body` | `<g>` | `style.transform` (Atmen, Mitbewegen) |
| `shoulderL`, `shoulderR` | `<g>` in `body` | `style.transform` (Schulterzucken) |

Fehlende optionale Elemente werden übersprungen.

### Konfiguration per `data-fig`

Positionen und Stärken der Bewegung lassen sich im `<svg>`-Tag festlegen:

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 720"
     data-fig='{"mouth":{"cx":360,"cy":450,"halfW":50,"openMax":70},"lid":90,"lookX":18,"lookY":9,"brow":{"inner":190,"outer":198,"up":25},"noseLift":10,"noseShift":0.8}'>
```

| Wert | Bedeutung |
|------|-----------|
| `mouth.cx`, `mouth.cy` | Mitte des Mundes |
| `mouth.halfW` | halbe Mundbreite |
| `mouth.openMax` | maximale Öffnungshöhe |
| `lid` | Höhe, bei der das Auge komplett verdeckt ist |
| `lookX`, `lookY` | maximale Pupillenbewegung |
| `brow.inner`, `brow.outer` | y-Wert der Brauenenden in Ruhe |
| `brow.up` | maximaler Hub der Brauen |
| `noseLift` | Hub der Nase |
| `noseShift` | Verschiebung der Nase pro Grad Kopfdrehung |

### ID-Test in der Browser-Konsole (F12)

```javascript
["head","irisL","irisR","pupilL","pupilR","lidL","lidR","browL","browL2",
 "browR","browR2","mouthFill","mouthLine"]
  .filter(id => !document.querySelector("#avatar #" + id))
```

Eine leere Liste `[]` bedeutet: Alle Pflicht-IDs sind vorhanden.

## Prompt: neue Figur mit ChatGPT erstellen

Die eckigen Klammern im Prompt durch eigene Angaben ersetzen.

````markdown
Du bist ein erfahrener SVG-Illustrator und Frontend-Entwickler.

# Aufgabe
Zeichne eine **neue Figur als einzelnes SVG**: [FIGUR BESCHREIBEN, z. B. "freundliche Katze mit Schnurrhaaren", "Roboter mit Antenne", "Pirat mit Hut", "Astronautin mit Helm"].
Stil: [z. B. Comic mit dunklen Konturen, flächig mit leichten Farbverläufen].
Ausschnitt: [z. B. "Kopf und Schultern" oder "nur Kopf"].

Die Figur wird im Browser per JavaScript animiert (Face Tracking: Blinzeln, Blick, Augenbrauen, Mund, Kopfneigung, Nase, Schultern). Damit das funktioniert, musst du dich an die folgenden Regeln halten.

# Harte Regeln

1. **Format:** `viewBox="0 0 720 720"`, `xmlns="http://www.w3.org/2000/svg"`, kein Hintergrund (transparent), kein vollflächiges `<rect>`. Nur ein SVG-Dokument, ohne `<?xml ?>`-Zeile. Keine Skripte, keine externen Bilder oder Schriftarten, keine `<style>`-Blöcke. Nur Attribute und Inline-Styles. Farbverläufe, Filter und `clipPath` in `<defs>` sind erlaubt.

2. **Pflicht-IDs**, jeweils genau einmal:
   `head`, `irisL`, `irisR`, `pupilL`, `pupilR`, `lidL`, `lidR`, `browL`, `browL2`, `browR`, `browR2`, `mouthFill`, `mouthLine`
   **Optional**, aber gewünscht: `nose`, `body`, `shoulderL`, `shoulderR`
   (`body`, `shoulderL`, `shoulderR` nur bei Figuren mit Oberkörper.)

3. **Elementtypen und Verhalten** (das Skript verändert genau diese Attribute):
   - `head`: `<g>` mit allem, was zum Kopf gehört (Gesicht, Haare, Ohren, Hut, Accessoires, Augen, Brauen, Nase, Mund). Setze `style="transform-origin: Xpx Ypx"` auf die Mitte des Halses bzw. Kopfes.
   - `body`: `<g>` mit Oberkörper und Hals, mit `style="transform-origin: 360px 720px"`.
   - `shoulderL`, `shoulderR`: `<g>` innerhalb von `body`, jeweils mit eigenem `style="transform-origin: …"` an der Schulter. `shoulderL` liegt links im Bild, `shoulderR` rechts.
   - `irisL`, `irisR`: `<g>` mit Iris, Pupille (`pupilL`/`pupilR` als `<circle>`) und Glanzpunkten. Das Skript setzt `transform="translate(x y)"` an dieser Gruppe. Die Gruppe steckt in einer **äußeren** `<g clip-path="url(#...)">`, damit die Iris im Auge bleibt.
   - `lidL`, `lidR`: `<rect>` mit `height="0"`, gefüllt mit **exakt der Hautfarbe bzw. Fellfarbe** der Fläche um das Auge. Das Skript vergrößert nur `height` (nach unten). Das Rechteck muss oben am oberen Augenrand beginnen und breiter als das Auge sein. Bei maximaler Höhe muss es das Auge komplett verdecken.
   - `browL`, `browL2`, `browR`, `browR2`: `<line>` mit `x1,y1,x2,y2`. Das Skript verändert nur `y1` und `y2`. Je Braue zwei Linien (`browL` = Umriss, dicker und dunkel; `browL2` = Füllung, dünner). Bei Figuren ohne sichtbare Brauen: dünne Linien in der Fellfarbe oder `stroke-opacity="0"`, aber vorhanden.
     - `browL`/`browL2`: **links im Bild**, `x1` = außen, `x2` = innen (zur Nase).
     - `browR`/`browR2`: **rechts im Bild**, `x1` = innen, `x2` = außen.
   - `mouthFill`, `mouthLine`: `<path>`. Das Skript überschreibt `d` komplett. `mouthFill` im Ruhezustand `d=""` und mit Füllfarbe (z. B. dunkelrot). `mouthLine` mit `fill="none"`, `stroke`, `stroke-linecap="round"` und einer **sichtbaren Startform** (leichtes Lächeln). Der Mund ist immer eine symmetrische Form, die über der Mundmitte liegt (Mundmitte bei `x` = Mitte der Figur).
   - `nose`: `<path>` oder `<g>`. Das Skript verschiebt (`translate`), dreht (`rotate`) und skaliert (`scale`) es um seine Mitte. Baue Nasenrücken, Nasenflügel, Nasenlöcher, Schatten und Lichter **innerhalb** dieses Elements, damit alles mitwandert. Unter der Nase liegt eine **Grundfläche in Haut- oder Fellfarbe**, die nicht Teil von `nose` ist und größer als die Nase ist, damit beim Bewegen keine Lücke entsteht.

4. **Reihenfolge von hinten nach vorn:**
   Körper → Hals → Haare/Fell hinten → Ohren → Gesicht samt Grundfläche → Wangen/Schatten → Augenweiß → Iris-Gruppen → Lider → Nase → Brauen → Mund → Bart/Schnurrbart/Schnauze → Haare vorn → Accessoires.

5. **Keine Lücken beim Bewegen:**
   - Unter allem, was sich bewegt (Lider, Nase, Brauen), liegt eine geschlossene Fläche in der passenden Farbe.
   - Haare, Ohren, Bart und Accessoires **überlappen** das Gesicht um mindestens 6 Einheiten.
   - Der Hals reicht mindestens 30 Einheiten unter den Kopf.
   - `body` und die Schultern sind nach unten und zur Seite so weit gezeichnet, dass bei einer Verschiebung um 20 Einheiten keine Kante sichtbar wird.

6. **Positionen:** Zeichne die Figur so, dass sie die Fläche gut füllt. Augen etwa bei y = 230–300, Mund etwa bei y = 350–480, Kopfmitte bei x = 360. Brauen etwa 40–60 Einheiten über den Augen. **Notiere die Positionen am Ende** (siehe Ausgabe).

7. **Stil und Details:** Einheitliche Konturstärke, Schattierungen und Lichter mit Farbverläufen, Glanzpunkte in den Augen, Wangen, feine Details (Fell- oder Haarstruktur, Stoffalten, Nähte, Schrauben usw.). Wenig `filter`, damit die Darstellung flüssig bleibt (höchstens 2 Filter).

# Ausgabe

1. Eine **kurze Beschreibung** der Figur (2 Sätze).
2. Das **vollständige SVG** in einem Codeblock (```xml), ohne Auslassungen wie „…“.
3. **Konfigurationswerte** als `data-fig`-Attribut für das `<svg>`-Tag, fertig eingetragen, nach diesem Schema:
   `data-fig='{"mouth":{"cx":360,"cy":450,"halfW":50,"openMax":70},"lid":90,"lookX":18,"lookY":9,"brow":{"inner":190,"outer":198,"up":25},"noseLift":10,"noseShift":0.8}'`
   - `mouth.cx`/`cy`: Mitte des Mundes
   - `mouth.halfW`: halbe Mundbreite
   - `mouth.openMax`: maximale Öffnungshöhe
   - `lid`: Höhe, bei der das Auge komplett verdeckt ist
   - `lookX`/`lookY`: maximale Pupillenbewegung
   - `brow.inner`/`outer`: y-Wert der Brauenenden im Ruhezustand (innen/außen)
   - `brow.up`: maximaler Hub der Brauen
   - `noseLift`: Hub der Nase in Einheiten
   - `noseShift`: Verschiebung der Nase pro Grad Kopfdrehung
   Das `<svg>`-Tag im Codeblock soll dieses Attribut **bereits enthalten**.
4. Eine **Checkliste** mit jeder Pflicht-ID und ihrem Elementtyp.
5. Einen **Dateinamen-Vorschlag** (klein, ohne Leerzeichen, z. B. `katze.svg`).

Wenn eine Regel für die Figur nicht sinnvoll ist (z. B. keine Brauen bei einem Roboter), baue das Element trotzdem unsichtbar ein und schreibe es kurz dazu.
````

## Tipps

- **Figur genau beschreiben:** Farben, Kleidung, Accessoires und Stimmung verbessern das Ergebnis.
- **Nachbessern:** z. B. „Die Lider verdecken das Auge nicht ganz. Mach das Rechteck größer. Alle Regeln bleiben gültig, gib wieder das vollständige SVG aus."
- **Mund sitzt falsch:** Werte unter `mouth` in `data-fig` anpassen.
- **Greenscreen:** Bei grünen Figuren Blau oder Magenta als Hintergrund wählen.

## Datenschutz

- Die Videoverarbeitung findet ausschließlich im Browser statt.
- Es werden keine Daten an Server gesendet oder gespeichert.
- Im Unterricht sollte die Nutzung der Kamera freiwillig sein.

## Lizenz und Danksagung

- Code dieses Projekts: MIT-Lizenz (Datei `LICENSE` ergänzen)
- [MediaPipe](https://github.com/google-ai-edge/mediapipe) von Google, Apache License 2.0
