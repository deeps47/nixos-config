{ config, lib, pkgs, ... }:

{
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="373b", ATTRS{idProduct}=="103f", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="373b", ATTRS{idProduct}=="103f", MODE="0666"

    KERNEL=="hidraw*", ATTRS{idVendor}=="1d6b", ATTRS{idProduct}=="0002", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1d6b", ATTRS{idProduct}=="0002", MODE="0666"

  '';
}  
