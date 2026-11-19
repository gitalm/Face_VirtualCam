# Face-Tracking-Avatar

Ein SVG-Gesicht, das per Webcam deine Mimik nachmacht: Blinzeln, Blickrichtung,
Augenbrauen, Lächeln, Mundöffnung und Kopfneigung.

Alles läuft **lokal im Browser**. Es werden keine Videos oder Bilder hochgeladen
oder gespeichert. Bibliothek und Modell liegen im Repository, es gibt keine
Anfragen an externe Server.

## Demo

https://DEIN-NUTZERNAME.github.io/face-avatar/

## Verwendung

1. Seite öffnen und auf **Kamera starten** klicken.
2. Kamerazugriff erlauben.
3. Gesicht frontal in die Kamera halten und Mimik ausprobieren.

## Lokal starten

Die Kamera funktioniert nur über `https://` oder `http://localhost`.

```bash
npx serve
# danach http://localhost:3000 öffnen
```

## Projektstruktur

```text
face-avatar/
├── index.html                  Seite, SVG-Gesicht und Logik
├── vendor/
│   ├── vision_bundle.mjs       MediaPipe Tasks Vision
│   └── wasm/                   WebAssembly-Dateien von MediaPipe
└── models/
    └── face_landmarker.task    Face-Landmarker-Modell
```

## Funktionsweise

1. **MediaPipe Face Landmarker** erkennt das Gesicht im Kamerabild und liefert
   52 *Blendshapes* (Werte von 0 bis 1) sowie eine Transformationsmatrix.
2. Die Werte werden geglättet.
3. Sie steuern Attribute der SVG-Elemente, z. B. `ry`, `cx`, `cy`, `d`
   und `transform`.

| Blendshape                          | Wirkung im Avatar      |
|-------------------------------------|------------------------|
| `eyeBlinkLeft` / `eyeBlinkRight`    | Lider schließen        |
| `eyeLook…`                          | Pupillen bewegen       |
| `browInnerUp`, `browDown…`, `browOuterUp…` | Augenbrauen     |
| `jawOpen`                           | Mund öffnen            |
| `mouthSmile…`, `mouthFrown…`        | Lächeln / Traurig      |
| `mouthPucker`                       | Kussmund               |

## Datenschutz

- Die Videoverarbeitung findet ausschließlich im Browser statt.
- Es werden keine Daten an Server gesendet oder gespeichert.
- Im Unterricht sollte die Nutzung der Kamera freiwillig sein.

## Ideen zum Weiterbauen

- Eigene SVG-Figuren zeichnen (Tier, Roboter, Comicfigur)
- Weitere Blendshapes nutzen (Wangen, Nase, Zunge)
- Aufnahme der Animation als Standbild

## Lizenz und Danksagung

- Code dieses Projekts: MIT-Lizenz (Datei `LICENSE` ergänzen)
- [MediaPipe](https://github.com/google-ai-edge/mediapipe) von Google,
  Apache License 2.0
