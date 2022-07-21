#!/bin/sh
nix-build '<nixpkgs/nixos>' -A vm -I nixos-config=appliance.nix
