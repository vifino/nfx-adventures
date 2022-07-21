{ pkgs, lib, ... }:

with lib;

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };

    # Set VM disk size (in MB)
    #virtualisation.diskSize = 1024 * 1024 * 8;

    boot.growPartition = true;
    boot.kernelParams = [ "console=ttyS0" "mitigations=off" ];
    boot.loader.grub.device = "/dev/vda";
    boot.loader.timeout = 0;

    i18n.defaultLocale = "en_DK.UTF-8";
    time.timeZone = "Europe/Amsterdam";

    # User config.
    users.extraUsers.root.password = "";
    users.mutableUsers = false;

    users.users.root = {
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBy+EhCiRTcHgltaagVozgnROBy5Mi6Qslb3oWavDLSh vifino@tschunk"
      ];
    };

    # Essential services.
    services = {
      openssh = {
        enable = true;
        permitRootLogin = "yes";
      };
    };

    # Essential programs.
    environment.systemPackages = with pkgs; [
      # Essential tools
      curl nmap socat 
    ];
    programs.mtr.enable = true;
  };
}
