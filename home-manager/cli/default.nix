{ pkgs, ... }: {

  imports = [ ./git ./shell ];

  home.packages = with pkgs; [
  kitty
  foot
  rofi-wayland
  wlr-randr
  zip
  unzip
  tree
  neofetch
  vim
  hyprland-autoname-workspaces
  ];

}
