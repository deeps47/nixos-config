{ config, pkgs, ... }:

{

  # Enable dconf (System Management Tool)
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

  # Add user to libvirtd group
  users.users.goku.extraGroups = [ "libvirtd" "kvm"];

  programs.virt-manager.enable = true;

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    mesa
    mesa-gl-headers
    libGL
    libvirt
    virglrenderer
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    adwaita-icon-theme
    (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
      qemu-system-x86_64 \
        -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
        "$@"
    '')
  ];

  # Manage the virtualisation services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

}

