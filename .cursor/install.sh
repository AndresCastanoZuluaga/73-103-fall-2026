#!/usr/bin/env bash
# Idempotent setup for the 73-103 Quarto website.
# Installs the Quarto CLI (the only build dependency) if it is not already
# present. The site contains no executable R/Python/Julia cells, so no
# additional language runtimes are required.
set -euo pipefail

QUARTO_VERSION="1.10.18"

if command -v quarto >/dev/null 2>&1 && [ "$(quarto --version)" = "${QUARTO_VERSION}" ]; then
  echo "Quarto ${QUARTO_VERSION} already installed; skipping download."
else
  echo "Installing Quarto ${QUARTO_VERSION}..."
  tmp_deb="$(mktemp --suffix=.deb)"
  curl -fsSL -o "${tmp_deb}" \
    "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb"
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends "${tmp_deb}"
  rm -f "${tmp_deb}"
fi

quarto --version
quarto check
