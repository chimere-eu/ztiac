#!/bin/bash

install_debian() {
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    chmod o+r /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install caddy
}

install_redhat() {
    dnf install 'dnf-command(copr)'
    dnf copr enable @caddy/caddy
    dnf install caddy
    sudo systemctl enable --now caddy
}

install_redhat_7 () {
    yum install yum-plugin-copr
    yum copr enable @caddy/caddy
    yum install caddy
    sudo systemctl enable --now caddy
}


# Function to read OS info from /etc/os-release
get_os_info() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID=$${ID,,}                   # lowercase
        OS_VERSION_ID=$VERSION_ID
        OS_ID_LIKE=$${ID_LIKE,,}         # lowercase
    elif [ -f /etc/redhat-release ]; then
        OS_ID="rhel"
        OS_VERSION_ID=$(awk '{print $NF}' /etc/redhat-release)
        OS_ID_LIKE="rhel"
    else
        echo "Unsupported or unknown distribution"
        exit 1
    fi
}

get_os_info

# Function to match ID or ID_LIKE
matches_like() {
    [[ "$OS_ID" == "$1" || "$OS_ID_LIKE" == *"$1"* ]]
}

# Determine OS family
if matches_like "debian"; then
    echo "Debian-based system detected: $OS_ID $OS_VERSION_ID"
    install_debian
elif matches_like "rhel" || matches_like "fedora"; then
    echo "Red Hat-based system detected: $OS_ID $OS_VERSION_ID"
    if [[ "$OS_VERSION_ID" == 7* ]]; then
        echo "This is RHEL/CentOS version 7"
        install_redhat_7
    else
        install_redhat
    fi
else
    echo "Unknown or unsupported distribution: $OS_ID (like: $OS_ID_LIKE) $OS_VERSION_ID"
fi

cat > /etc/caddy/Caddyfile <<EOL
${CADDYFILE}
EOL

sudo systemctl reload caddy