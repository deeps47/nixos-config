{ config, pkgs, ... }:

{

  # Enable dconf for virt-manager connection persistence
  programs.dconf.enable = true;
  programs.dconf.profiles.user = {
    databases = [
      {
        settings = {
          "org/virt-manager/virt-manager/connections" = {
            autoconnect = [ "qemu:///system" ];
            uris = [ "qemu:///system" ];
          };
        };
      }
    ];
  };

  # User groups for VM and Container access
  users.users.goku.extraGroups = [ "libvirtd" "kvm" "video" "render" ];

  programs.virt-manager.enable = true;

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virglrenderer
    virt-viewer
    virtio-win
    adwaita-icon-theme
  ];

  # VM Infrastructure
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        runAsRoot = false;
      };
    };
    spiceUSBRedirection.enable = true;

    # Podman for CTF shells
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true; # Allows 'docker' commands to work via podman
    };

    # Disable Docker daemon unless you specifically need it
    docker.enable = false;
  };

  # Improves compatibility with some Windows guests
  boot.extraModprobeConfig = ''
    options kvm ignore_msrs=1
  '';

  # These are guest services; disable them on the host
  services.qemuGuest.enable = false;
  services.spice-vdagentd.enable = false;
}

