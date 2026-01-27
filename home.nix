{ config, pkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  configs = {
    hypr = "hypr";
    nvim = "nvim";
    rofi = "rofi";
    foot = "foot";
    waybar = "waybar";
    noctalia = "noctalia";
  };
in
{
  imports = [
    ./modules/theme.nix
    ./git.nix
    ./noctaliahm.nix
  ];

  home.username = "goku";
  home.homeDirectory = "/home/goku";
  home.stateVersion = "25.11";
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos btw";
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos-btw";
      vim = "nvim";
    };
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
          exec hyprland
      fi
    '';
  };

  home.packages = with pkgs; [
    neovim
    ripgrep
    nil
    nixpkgs-fmt
    nitch
    rofi
    pcmanfm
    gcc
    xdg-utils
    quickshell
    wtype
    brave
    vscodium
  ];

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

}
