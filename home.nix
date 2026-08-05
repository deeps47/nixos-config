{ config, pkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  configs = {
    hypr = "hypr";
    nvim = "nvim";
    foot = "foot";
    noctalia = "noctalia";
  };
in
{
  imports = [
    ./modules/theme.nix
    ./modules/web-apps.nix
    ./git.nix
    ./noctaliahm.nix
    ./neovim.nix
    ./testing-packages.nix
    ./overrides/tribler.nix
    ./programs/browsers/default.nix
  ];

  home.username = "goku";
  home.homeDirectory = "/home/goku";
  home.stateVersion = "26.05";
  programs.bash = {
    enable = true;
    initExtra = ''
      if [ -f ~/nixos-dotfiles/config/aliases.sh ]; then
        . ~/nixos-dotfiles/config/aliases.sh
      fi
    '';
  };

  home.packages = with pkgs; [
    nitch
    xdg-utils
    quickshell
    vscodium
    yazi
    discord
  ];

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

}
