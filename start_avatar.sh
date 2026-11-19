#!/usr/bin/env bash
# Startet den Avatar als eigenes Fenster (für OBS-Fenstererfassung)
cd "$(dirname "$0")"

PORT=8765
SIZE=720
URL="http://localhost:$PORT/index.html?clean"

# Browser suchen
for b in google-chrome google-chrome-stable chromium chromium-browser \
         "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
         "/Applications/Chromium.app/Contents/MacOS/Chromium"; do
  if command -v "$b" >/dev/null 2>&1 || [ -x "$b" ]; then BROWSER="$b"; break; fi
done
[ -z "$BROWSER" ] && { echo "Chrome oder Chromium nicht gefunden."; exit 1; }

# Server starten und beim Beenden wieder stoppen
python3 -m http.server "$PORT" >/dev/null 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null' EXIT
sleep 1

# Eigenes Profil: Die Kamera-Erlaubnis bleibt gespeichert,
# und dein normaler Browser wird nicht gestört.
PROFILE="$HOME/.face-avatar-profile"

"$BROWSER" \
  --user-data-dir="$PROFILE" \
  --app="$URL" \
  --window-size=$SIZE,$SIZE \
  --window-position=100,100 \
  --no-first-run \
  --no-default-browser-check \
  --disable-features=Translate \
  --autoplay-policy=no-user-gesture-required

echo "Avatar beendet."
