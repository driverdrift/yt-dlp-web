#!/usr/bin/env bash
set -euo pipefail
trap 'echo "operation is interrupted"; exit 130' INT

REPO_URL="https://github.com/driverdrift/yt-dlp-web/archive/main.tar.gz"
WORKDIR="/tmp/yt-dlp-web"

rm -rf "$WORKDIR" && mkdir -p "$WORKDIR"

echo "Downloading and extracting..."
wget -qO- "$REPO_URL" | tar -xz -C "$WORKDIR" --strip-components=1

cd "$WORKDIR"
echo "Done! Current directory: $(pwd)"

chmod +x main.sh
exec ./main.sh
