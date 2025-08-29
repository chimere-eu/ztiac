#!/bin/bash

curl -OLs https://raw.githubusercontent.com/openpubkey/opkssh/main/scripts/install-linux.sh
bash install-linux.sh

if ${USE_PROVIDERS_FILE}; then
  echo "${PROVIDERS}" >> /etc/opk/providers
fi

if ${USE_AUTH_ID_FILE}; then
  echo "${AUTH_ID}" >> /etc/opk/auth_id
fi
echo -e "✅ OpenPubkey SSH installed"
