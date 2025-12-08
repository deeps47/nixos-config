#!/usr/bin/env bash

# JUST A REALLY REALLY BAD SCRIPT TO DO ABSOLUTE NOTHING

echo "[+] Starting NixOS flake deployment..."

mkdir -p /mnt
mkdir -p /boot

# Run nixos-generate-config command
sudo nixos-generate-config || { echo "Failed to generate hardware configuration"; exit 1; }

sudo cp /etc/nixos/hardware-configuration.nix .

# Rebuild NixOS configuration
sudo nixos-rebuild switch --flake .#nixos-btw || { echo "Failed to rebuild NixOS configuration"; exit 1; }

echo "Script completed successfully."