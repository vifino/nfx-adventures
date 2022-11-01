#!/bin/sh
IMAGE=$(nix-shell -p nixos-generators --run "nixos-generate -f raw -c configuration.nix")
rm -f nix-vpp.qcow2
qemu-img convert -O qcow2 "$IMAGE" -cp nix-vpp.qcow2
nix-store --delete "$(dirname "$IMAGE")"
