{ config, pkgs, ... }:

{
  users.users.ctf = {
    isNormalUser = true;
    description = "CTF User";
    home = "/home/ctf";

    extraGroups = [
      "video"
      "render"
      "podman"
    ];

    shell = pkgs.bashInteractive;
  };

  environment.systemPackages = with pkgs; [
    acl
    direnv
  ];

  systemd.tmpfiles.rules = [
    "d /home/ctf/share 0775 ctf users -"
  ];

  systemd.services.ctf-flake-permissions = {
    description = "Allow CTF user access to CTF flake";

    wantedBy = [ "multi-user.target" ];

    script = ''
      if [ -d /home/alice/dotfiles/ctf-devshell ]; then
        ${pkgs.acl}/bin/setfacl -m u:ctf:--x /home/goku
        ${pkgs.acl}/bin/setfacl -m u:ctf:--x /home/goku/nixos-dotfiles
        ${pkgs.acl}/bin/setfacl -R -m u:ctf:rX /home/goku/nixos-dotfiles/ctf-config
      fi
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
