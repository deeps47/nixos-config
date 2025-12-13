{ config, pkgs, lib, ... }:

{
  # Display manager
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Polkit
  security.polkit.enable = true;

  xdg.portal.enable = true;

  # Install extra portal helpers for GTK/X11 compatibility/fallbacks
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];

  # Optional: prefer gtk for default handler choices when appropriate
  #services.xdg.portal.config.common.default = [ "gtk" ];

  # GNOME Keyring / libsecret available system-wide (PAM unlock from DM)
  environment.systemPackages = with pkgs; [
    gnome-keyring
    libsecret
  ];

  # Integrate keyring with PAM/login manager
  services.gnome.gnome-keyring.enable = true;
}

