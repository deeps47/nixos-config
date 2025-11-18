#!/usr/bin/env bash

# JUST A REALLY REALLY BAD SCRIPT TO DO ABSOLUTE NOTHING

echo "[+] Starting NixOS flake deployment..."

mkdir -p /mnt
mkdir -p /boot
mkdir -p /etc/nixos/nixos-dotfiles

cd /etc/nixos

# Run nixos-generate-config command
sudo nixos-generate-config || { echo "Failed to generate hardware configuration"; exit 1; }

rm /etc/nixos/configuration.nix

mv nixos-config/* /etc/nixos/nixos-dotfiles

# Rebuild NixOS configuration
sudo nixos-rebuild switch --flake /etc/nixos#nixos-btw || { echo "Failed to rebuild NixOS configuration"; exit 1; }

echo "Script completed successfully."