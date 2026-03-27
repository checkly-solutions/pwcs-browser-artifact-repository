#!/usr/bin/env bash
#
# Downloads Playwright 1.58.2 browser binaries from the CDN and stores them
# in the local artifact-repo directory structure that Playwright expects
# when PLAYWRIGHT_DOWNLOAD_HOST is set.
#
# The Checkly agent (Ubuntu 24.04) runs `npx playwright install chromium`,
# which installs: chromium, chromium-headless-shell, and ffmpeg.
# We mirror both x64 and arm64 variants so the repo works regardless of
# whether the Docker host is Intel/AMD or Apple Silicon/Graviton.
#
# Usage: ./mirror-browsers.sh
#
set -euo pipefail

MIRROR_DIR="$(cd "$(dirname "$0")" && pwd)/artifact-repo/data"

# Playwright 1.58.2 browser revisions (from browsers.json)
CHROMIUM_VERSION="145.0.7632.6"
CHROMIUM_REVISION="1208"
FFMPEG_REVISION="1011"

# --- x64: Chromium uses Chrome for Testing (CFT) paths ---
CFT_BASE="https://cdn.playwright.dev"
CFT_FILES=(
  "builds/cft/${CHROMIUM_VERSION}/linux64/chrome-linux64.zip"
  "builds/cft/${CHROMIUM_VERSION}/linux64/chrome-headless-shell-linux64.zip"
)

# --- arm64: Chromium uses revision-based paths ---
# --- Both: ffmpeg uses revision-based paths ---
REVISION_BASE="https://cdn.playwright.dev/dbazure/download/playwright"
REVISION_FILES=(
  # Chromium arm64 (revision-based, not CFT)
  "builds/chromium/${CHROMIUM_REVISION}/chromium-linux-arm64.zip"
  # Chromium headless shell arm64
  "builds/chromium/${CHROMIUM_REVISION}/chromium-headless-shell-linux-arm64.zip"
  # FFmpeg (x64 + arm64)
  "builds/ffmpeg/${FFMPEG_REVISION}/ffmpeg-linux.zip"
  "builds/ffmpeg/${FFMPEG_REVISION}/ffmpeg-linux-arm64.zip"
)

echo "==> Mirroring Playwright 1.58.2 browser binaries to ${MIRROR_DIR}"
echo "    (chromium + chromium-headless-shell + ffmpeg, x64 & arm64)"
echo ""

download() {
  local url="$1"
  local dest="$2"

  if [[ -f "$dest" ]]; then
    echo "  [skip] Already exists: $dest"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  echo "  [download] $url"
  if curl -fSL --retry 3 --progress-bar -o "$dest" "$url"; then
    echo "  [ok] $(du -h "$dest" | cut -f1) -> $dest"
  else
    echo "  [WARN] Failed to download: $url (may not exist for this platform)"
    rm -f "$dest"
  fi
}

echo "--- Chrome for Testing (Chromium x64) ---"
for path in "${CFT_FILES[@]}"; do
  download "${CFT_BASE}/${path}" "${MIRROR_DIR}/${path}"
done

echo ""
echo "--- Revision-based (Chromium arm64, FFmpeg) ---"
for path in "${REVISION_FILES[@]}"; do
  download "${REVISION_BASE}/${path}" "${MIRROR_DIR}/${path}"
done

echo ""
echo "==> Mirror complete!"
echo ""
echo "Total size:"
du -sh "${MIRROR_DIR}" 2>/dev/null || echo "  (empty)"
echo ""
echo "Directory structure:"
find "${MIRROR_DIR}" -type f -name "*.zip" | sort | while read -r f; do
  echo "  $(du -h "$f" | cut -f1)  ${f#${MIRROR_DIR}/}"
done
