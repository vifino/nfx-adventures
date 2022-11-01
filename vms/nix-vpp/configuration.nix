{ config, modulesPath, pkgs, lib, ... }:
{
  imports = [
    # We run under QEMU.
    (modulesPath + "/profiles/qemu-guest.nix")
    
    ./vpp.nix
  ];

  boot = {
    consoleLogLevel = lib.mkDefault 7;
    growPartition = true;

    # REMOVE THIS AFTER INSTALL.
    postBootCommands = ''
      cp ${./configuration.nix} /etc/nixos/configuration.nix
      cp ${./vpp.nix} /etc/nixos/vpp.nix
    '';
  };

  i18n.defaultLocale = "en_DK.UTF-8";
  time.timeZone = "Europe/Amsterdam";

  # Configure users.
  users.users.root = {
    extraGroups = [ "wheel" ];
    initialPassword = "hunter2";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBy+EhCiRTcHgltaagVozgnROBy5Mi6Qslb3oWavDLSh vifino@tschunk"
    ];
  };

  # Networking
  networking.hostName = "pfaffix";
  networking.useDHCP = false;
  #networking.interfaces.enp0s5.useDHCP = true;

  # Essential services.
  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  # Essential programs.
  environment.systemPackages = with pkgs; [
    # Essential tools
    curl nmap socat iperf3
  ];
  programs.mtr.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
