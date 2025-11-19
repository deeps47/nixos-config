#!/usr/bin/env bash

# JUST A REALLY REALLY BAD SCRIPT TO DO ABSOLUTE NOTHING

echo "[+] Starting NixOS flake deployment..."

mkdir -p /mnt
mkdir -p /boot
mkdir -p /home/goku/nixos-dotfiles

# Run nixos-generate-config command
sudo nixos-generate-config || { echo "Failed to generate hardware configuration"; exit 1; }

sudo rm /etc/nixos/configuration.nix

sudo mv nixos-dotfiles/* /etc/nixos/

# Rebuild NixOS configuration
sudo nixos-rebuild switch --flake /etc/nixos#nixos-btw || { echo "Failed to rebuild NixOS configuration"; exit 1; }

sudo mv /etc/nixos/* /home/goku/nixos-dotfiles/

echo "Script completed successfully."