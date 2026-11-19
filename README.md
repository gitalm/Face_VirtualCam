# Face-Tracking-Avatar

Eine SVG-Figur, die per Webcam deine Mimik nachmacht: Blinzeln, Blick, Brauen, Mund, Zunge, Nase, Kopfbewegung und Schultern.
Alles läuft **lokal im Browser**. Es werden keine Videos oder Bilder hochgeladen oder gespeichert.

## Start

```bash
./start-avatar.sh     # eigenes Fenster ohne Rahmen, für OBS
npx serve             # oder normal: http://localhost:3000
```

Die Kamera funktioniert nur über `https://` oder `http://localhost`.

## Bedienung

- **Kamera starten**, Zugriff erlauben, gerade in die Kamera schauen.
- **R**: Haltung und Abstand neu kalibrieren
- **T** (gedrückt): Zunge testen
- **Greenscreen-Ansicht**: nur die Figur. Beenden mit **Esc** oder Doppelklick. Direkt per `?clean` in der URL.
- **Hintergrund**: Grün, Blau oder Magenta. Bei grünen Figuren Blau oder Magenta wählen.

## OBS

Fenstererfassung auf das Avatar-Fenster, Filter **Chroma Key**.
Die OBS-Browserquelle bekommt meist keinen Kamerazugriff.

## Struktur

```text
index.html            Seite und Logik
assets/*.svg          Figuren
assets/figures.json   Figurenliste (GitHub Action oder update-figures.sh)
vendor/, models/      MediaPipe und Modell (lokal)
start-avatar.sh       Einzelfenster für OBS
build-scorm.sh        SCORM-Paket (mit imsmanifest.xml)
```

## Neue Figur

1. SVG als `assets/NAME.svg` speichern.
2. `git push` (die Action aktualisiert `figures.json`) oder `./update-figures.sh`.
3. Seite mit **Strg + F5** neu laden.

## Figurenformat

`viewBox="0 0 720 720"`, transparent, kein Hintergrund.

| ID | Element | Das Skript verändert |
|----|---------|----------------------|
| `head` | `<g>` | `style.transform` |
| `irisL`, `irisR` | `<g>` in `<g clip-path>` | `transform` |
| `pupilL`, `pupilR` | `<circle>` | nichts |
| `lidL`, `lidR` | `<rect height="0">` in Hautfarbe | `height` |
| `browL`, `browL2`, `browR`, `browR2` | `<line>` | `y1`, `y2` |
| `mouthFill`, `mouthLine` | `<path>` | `d` |
| `nose` (optional) | `<path>` oder `<g>` | `transform` |
| `body`, `shoulderL`, `shoulderR` (optional) | `<g>` | `style.transform` |

Die **Zunge** erzeugt das Skript selbst. Sie wird ans Ende von `head` gehängt.

Optionale Werte im `<svg>`-Tag:

```xml
data-fig='{"mouth":{"cx":360,"cy":450,"halfW":50,"openMax":70},"lid":90,"lookX":18,"lookY":9,"brow":{"inner":190,"outer":198,"up":25},"noseLift":10,"noseShift":0.8}'
```

ID-Test in der Konsole (F12), leere Liste `[]` ist gut:

```javascript
["head","irisL","irisR","pupilL","pupilR","lidL","lidR","browL","browL2",
 "browR","browR2","mouthFill","mouthLine"]
  .filter(id => !document.querySelector("#avatar #" + id))
```

## Prompt für neue Figuren (ChatGPT o. Ä.)

Eckige Klammern durch eigene Angaben ersetzen.

````markdown
Du bist ein erfahrener SVG-Illustrator. Zeichne eine neue Figur als einzelnes SVG:
[BESCHREIBUNG, z. B. "freundliche Katze mit Schnurrhaaren"]
Stil: [z. B. Comic mit dunklen Konturen und leichten Farbverläufen]
Ausschnitt: [Kopf und Schultern / nur Kopf]

Die Figur wird per Face Tracking im Browser animiert. Halte dich an diese Regeln:

# Format
- `viewBox="0 0 720 720"`, `xmlns="http://www.w3.org/2000/svg"`, transparenter Hintergrund (kein vollflächiges Rechteck).
- Nur ein SVG, ohne `<?xml ?>`, ohne Skripte, externe Bilder, Schriftarten oder `<style>`-Blöcke. Verläufe, `clipPath` und höchstens 2 Filter sind erlaubt.

# Pflicht-IDs (jeweils genau einmal)
`head`, `irisL`, `irisR`, `pupilL`, `pupilR`, `lidL`, `lidR`, `browL`, `browL2`, `browR`, `browR2`, `mouthFill`, `mouthLine`
Optional: `nose`, `body`, `shoulderL`, `shoulderR` (nur mit Oberkörper)

# Elemente
- `head`: `<g>` mit Gesicht, Haaren, Ohren, Augen, Brauen, Nase, Mund und Kopf-Accessoires. `style="transform-origin: Xpx Ypx"` am Hals.
- `body`: `<g>` mit Oberkörper und Hals, `style="transform-origin: 360px 720px"`.
- `shoulderL` (links im Bild), `shoulderR` (rechts): `<g>` in `body`, jeweils mit eigenem `transform-origin` an der Schulter.
- `irisL`, `irisR`: `<g>` mit Iris, Pupille (`pupilL`/`pupilR` als `<circle>`) und Glanzpunkten. Sie steckt in einer äußeren `<g clip-path="url(#…)">`. Kein `transform` und kein `clip-path` an der Iris-Gruppe selbst.
- `lidL`, `lidR`: `<rect height="0">` in exakt der Haut- oder Fellfarbe. Oben am Augenrand beginnend, breiter als das Auge. Bei maximaler Höhe wird das Auge ganz verdeckt.
- Brauen: je Braue zwei `<line>` (`browL`/`browR` = dicker dunkler Umriss, `browL2`/`browR2` = Füllung).
  - `browL`, `browL2`: links im Bild, `x1` außen, `x2` innen.
  - `browR`, `browR2`: rechts im Bild, `x1` innen, `x2` außen.
  - Ohne sichtbare Brauen: Linien mit `stroke-opacity="0"`.
- `mouthFill`: `<path d="">` mit Füllfarbe (z. B. dunkelrot). `mouthLine`: `<path>` mit `fill="none"`, `stroke`, `stroke-linecap="round"` und sichtbarer Startform (leichtes Lächeln). Das Skript überschreibt `d`. Die Mundmitte liegt bei der Figurenmitte.
- `nose`: `<path>` oder `<g>`. Nasenrücken, Flügel, Löcher, Schatten und Lichter gehören hinein. Darunter liegt eine größere Grundfläche in Hautfarbe, die nicht Teil von `nose` ist.

# Keine Lücken beim Bewegen
- Unter Lidern, Nase und Brauen liegt eine geschlossene Fläche in passender Farbe.
- Haare, Ohren, Bart und Accessoires überlappen das Gesicht um mindestens 6 Einheiten.
- Der Hals reicht mindestens 30 Einheiten unter den Kopf.
- Körper und Schultern sind nach unten und zur Seite so weit gezeichnet, dass eine Verschiebung um 20 Einheiten keine Kante zeigt.
- Der Mund liegt im Gesicht so, dass eine Zunge nach unten herausgestreckt werden kann.

# Reihenfolge (hinten nach vorn)
Körper, Hals, Haare hinten, Ohren, Gesicht samt Grundfläche, Wangen und Schatten, Augenweiß, Iris, Lider, Nase, Brauen, Mund, Bart oder Schnauze, Haare vorn, Accessoires.

# Positionen
Augen bei y = 230–300, Mund bei y = 350–480, Kopfmitte bei x = 360, Brauen 40–60 Einheiten über den Augen.

# Ausgabe
1. Zwei Sätze Beschreibung.
2. Das vollständige SVG in einem Codeblock, ohne Auslassungen. Das `<svg>`-Tag enthält bereits `data-fig='{"mouth":{"cx":…,"cy":…,"halfW":…,"openMax":…},"lid":…,"lookX":…,"lookY":…,"brow":{"inner":…,"outer":…,"up":…},"noseLift":…,"noseShift":…}'` mit passenden Zahlen:
   - `mouth`: Mitte, halbe Breite, maximale Öffnung
   - `lid`: Höhe für komplett geschlossenes Auge
   - `lookX`, `lookY`: maximale Pupillenbewegung
   - `brow.inner`, `brow.outer`: y der Brauenenden in Ruhe, `brow.up`: maximaler Hub
   - `noseLift`: Hub der Nase, `noseShift`: Versatz pro Grad Kopfdrehung
3. Checkliste: jede Pflicht-ID mit Elementtyp.
4. Dateiname-Vorschlag (klein, ohne Leerzeichen, z. B. `katze.svg`).

Passt eine Regel nicht zur Figur (z. B. Brauen beim Roboter), baue das Element unsichtbar ein und erkläre es kurz.
````

## Tipps

- Je genauer die Beschreibung (Farben, Kleidung, Accessoires), desto besser das Ergebnis.
- Nachbessern: „Die Lider verdecken das Auge nicht ganz. Alle Regeln bleiben gültig, gib das vollständige SVG aus."
- Mund sitzt falsch: Werte unter `mouth` in `data-fig` anpassen.

## Datenschutz

Die Videoverarbeitung findet nur im Browser statt. Es werden keine Daten gesendet oder gespeichert. Im Unterricht ist die Kameranutzung freiwillig.

## Lizenz

Eigener Code: MIT (Datei `LICENSE` ergänzen). [MediaPipe](https://github.com/google-ai-edge/mediapipe): Apache License 2.0.
