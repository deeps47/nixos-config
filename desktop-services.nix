{ pkgs, ... }:

{
  # 1. Core Authentication Security
  security.polkit.enable = true;

  # 2. GNOME Keyring daemon support to securely remember application credentials
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # 3. Core system and utility packages
  environment.systemPackages = with pkgs; [
    hyprpolkitagent # Native Qt/QML authentication prompt
    libsecret # Allows applications to securely query gnome-keyring
  ];

  # 4. XDG Portals for critical Wayland integrations (Screen sharing, File pickers)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    # Sets fallback logic to avoid long application launch delays
    config.common.default = [ "gtk" ];
  };

  # 5. Display Manager layout definition using greetd and tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start hyprland-uwsm.desktop'";
        user = "greeter";
      };
    };
  };
}
