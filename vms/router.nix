{ pkgs, lib, ... }:

with lib;

{
  # Make hugetables work.
  boot.kernelParams = [ "hugetablesz=2" ];

  # Make sure DPDK exists.
  environment.systemPackages = with pkgs; [
    bird
    dpdk
  ];
}
