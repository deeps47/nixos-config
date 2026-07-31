{ pkgs, inputs, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.beta
    # Import the complex configurations here
    ./zen/settings.nix
    ./zen/policies.nix
    ./zen/extensions.nix
    ./zen/search.nix
    ./zen/extra-config.nix
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  programs.brave = {
    enable = true;
  };
}
