{ pkgs, config, ... }: {

#  imports = [ ./config.nix ];

  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    });
    systemd.enable = true;
    settings = import ./config.nix { inherit pkgs; };
    style = import ./style.nix { inherit config; };
  };

}
