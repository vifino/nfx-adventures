# nix-build '<nixpkgs/nixos>' -A vm --arg configuration "{ imports = [ ./vm.nix ]; }"
# see https://search.nix.gsc.io/?q=system.build.vm%20%3D&i=nope&files=&repos=
# nix-build '<nixpkgs/nixos>' -A vm -I nixos-config=vm.nix
# ./result/bin/run-nixos-vm
# or nixos-generate -f vm -c vm.nix --run
# nixos-generate --help
# nixos-generate --list
{ config, lib, pkgs, ... }:

with lib;

{
  imports =
    [ <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
      ./vm-basics.nix
      ./router.nix
    ];

  system.build.qemuvmImage = import <nixpkgs/nixos/lib/make-disk-image.nix> {
    inherit lib config;
    pkgs = import <nixpkgs/nixos> { inherit (pkgs) system; }; # ensure we use the regular qemu-kvm package
    diskSize = 8192;
    format = "qcow2";
    configFile = pkgs.writeText "configuration.nix"
      ''
        {
          imports = [ <./vm-basics.nix> <./router.nix> ];
        }
      '';
    };
}
