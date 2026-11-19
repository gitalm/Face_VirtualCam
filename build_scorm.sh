#!/usr/bin/env bash
# Erzeugt face-avatar-scorm.zip (ohne .git, Skripte und ZIPs)
set -e
cd "$(dirname "$0")"

# Figurenliste aktualisieren
if [ -d assets ]; then
  ls -1 assets/*.svg | xargs -n1 basename | sort | jq -R . | jq -s . > assets/figures.json
fi

rm -f face-avatar-scorm.zip
zip -r face-avatar-scorm.zip \
  imsmanifest.xml index.html assets vendor models \
  -x "*.map" -x "*.DS_Store"

echo "Fertig: face-avatar-scorm.zip"
