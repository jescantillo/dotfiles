#!/bin/bash

# Verify if path were given
if [ -z "$1" ]; then
  echo "Uso: $0 <ruta-de-carpeta>"
  exit 1
fi

# Initial Path
BASE_DIR="$1"

# Find folder depth sort to avoid rename conclicts
find "$BASE_DIR" -depth -type d | while read -r DIR; do
  # Parent folder
  PARENT="$(dirname "$DIR")"
  # Current folder name 
  BASENAME="$(basename "$DIR")"
  # Switch to lower and replace space by - 
  NEWNAME="$(echo "$BASENAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')"

  # If current folder name changed then rename
  if [ "$BASENAME" != "$NEWNAME" ]; then
    mv -v "$DIR" "$PARENT/$NEWNAME"
  fi
done

