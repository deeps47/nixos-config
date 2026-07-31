{ config, pkgs, inputs, ... }:

{
  # Import the module from the flake input
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
  };
}
