#!/bin/bash

echo "Installing the Chimere Agent..."

curl -fsSL https://raw.githubusercontent.com/chimere-eu/connectors-installation-scripts/refs/heads/main/scripts/install-transfer-agent.sh | bash

$PKG_MGR install -y jq

# Loop over chimeres
%{ for chimere in CHIMERE ~}
REGISTRATION_KEY=$(curl --silent --header "X-Vault-Token: ${chimere.vault_token}" \
    "${chimere.secret_url}" | jq -r .data.data.registration_key)
chimere-service -a ${chimere.name} -p ${chimere.address}:${chimere.port} -k $REGISTRATION_KEY -u ${join(",", chimere.urls)}
chimere-service -s ${chimere.name}
%{ endfor ~}

# Your other static commands
echo "Chimere Service installation complete✅."
