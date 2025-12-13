{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    # Use the git package that has libsecret support
    package = pkgs.git.override { withLibsecret = true; };
    settings = {
      credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
    };
  };
}

