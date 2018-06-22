#!/bin/bash
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker pi
rm first-boot.bash
