{ pkgs, lib, ... }:

with lib;
let
  nix-geht = import (builtins.fetchTarball "https://github.com/vifino/nix-geht/archive/refs/heads/vpp/module.tar.gz") {};
in {
  imports = [
    nix-geht.modules.vpp
  ];

  # Make sure bird exists.
  environment.systemPackages = with pkgs; [
    bird
  ];

  # VPP and the requirements.
  boot.kernelParams = [
    "transparent_hugepages=never"
    "nmi_watchdog=0"
    "hpet=disable"
    "tsc=reliable"
    "intel_iommu=on"
    "isolcpus=1,3"
    "nohz_full=1,3"
    "rcu_nocbs=1,3"
  ];

  services.vpp = {
    enable = true;
    
    mainCore = 1;

    # We use virtual functions and can't get an iommu, so we kinda have to load the dpdk-kmod one.
    uioDriver = "igb_uio";

    extraConfig = ''
      dpdk {
        no-tx-checksum-offload
        no-multi-seg

        dev 0000:00:05.0 { name hsxe0 }
        dev 0000:00:06.0 { name hsxe1 }
      }
    '';
    bootstrap = ''
      # Gotta have LCP.
      lcp lcp-sync enable
      lcp lcp-auto-subint enable

      # Set up hardware interfaces
      set interface state hsxe0 up
      lcp create hsxe0 host-if hsxe0

      set interface state hsxe1 up
      lcp create hsxe1 host-if hsxe1

      # Set up VLANs for test setup.
      create sub-interfaces hsxe1 10
      set interface state hsxe1.10 up
    '';
  };

  # Enable networking via VPP.
  networking = {
    interfaces."hsxe1.10".ipv4.addresses = [
      { address = "10.20.10.4"; prefixLength = 24; }
    ];
    defaultGateway = "10.20.10.1";
    nameservers = [ "10.20.10.1" ];
  };
}
