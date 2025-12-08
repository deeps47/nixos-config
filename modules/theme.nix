{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    adwaita-icon-theme
    gnome-themes-extra
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
  
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
    iconTheme.name = "Adwaita-dark";
    cursorTheme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
  
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Adwaita-dark
    gtk-icon-theme-name=Adwaita-dark
    gtk-cursor-theme-name=Adwaita-dark
    gtk-cursor-theme-size=24
    gtk-application-prefer-dark-theme=1
  '';

  xdg.configFile."gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Adwaita-dark
    gtk-icon-theme-name=Adwaita-dark
    gtk-cursor-theme-name=Adwaita-dark
    gtk-cursor-theme-size=24
    gtk-application-prefer-dark-theme=1
  '';

  home.sessionVariables = {
    XCURSOR_THEME = "Adwaita-dark";
    XCURSOR_SIZE = "24";
  };
}

