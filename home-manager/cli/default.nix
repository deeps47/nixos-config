{ pkgs, ... }: {

  imports = [ ./git ./shell ./kitty ];

  home.packages = with pkgs; [
 
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
