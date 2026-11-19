#!/usr/bin/env bash
# Erzeugt assets/figures.json aus allen SVG-Dateien im Ordner assets/
set -e
cd "$(dirname "$0")"

OUT="assets/figures.json"
first=1

echo "[" > "$OUT"
for f in assets/*.svg; do
  [ -e "$f" ] || continue
  name=$(basename "$f")
  if [ $first -eq 0 ]; then echo "," >> "$OUT"; fi
  printf '  "%s"' "$name" >> "$OUT"
  first=0
done
printf '\n]\n' >> "$OUT"

echo "Fertig: $OUT"
cat "$OUT"
