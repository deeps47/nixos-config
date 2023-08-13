{ pkgs, ... }: {

  imports = [ ./git ];

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
  ];

}
