{ config, pkgs, pkgs-stable, ... }:

{

  users.users.goku.extraGroups = [ "audio" "video" ];

  hardware.enableAllFirmware = true;

  # Enable sound with pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    #wireplumber.enable = true; # ← REQUIRED
    wireplumber = {
      enable = true;
      package = pkgs-stable.wireplumber;
    };

    extraConfig = {
      pipewire."99-silent-bell.conf" = {
        "context.properties" = {
          "module.x11.bell" = false;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
    easyeffects
  ];
}
