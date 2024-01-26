#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash git coreutils gptfdisk util-linux nixUnstable

set -euo pipefail

is_user_root() { [ "${EUID:-$(id -u)}" -eq 0 ]; }

disk::ask() {
  readarray -t disks < <(lsblk -d -n -p -l -o NAME,SIZE,MODEL)
  echo "Which disk do you want to install to?"
  for i in "${!disks[@]}"; do
    echo "$i) ${disks[$i]}"
  done
  read -r disk_index
  disk="$(echo "${disks[$disk_index]}" | cut -d' ' -f1)"
  echo "Installing to ${disk}"
  read -rsn1 -p"Press any key to continue"; echo
}

disk::check() {
  [ -b "${disk}" ] || {
    echo "Disk ${disk} does not exist"
    exit 1
  } >&2
}

disk::format() {
  disk::check
  echo "Do you want to format ${disk}? (y/n)"
  read -rsn1 answer
  [ "${answer}" = "y" ] || exit 1

  echo "Wiping disk"
  sgdisk --zap-all "${disk}"
  wipefs --all "${disk}"

  echo "Creating partitions"
  sgdisk --new=1:0:+512M "${disk}"
  sgdisk --new=2:0:0 "${disk}"

  echo "Setting partition types"
  sgdisk --typecode=1:ef00 "${disk}"
  sgdisk --typecode=2:8300 "${disk}"

  echo "Formatting partitions"
  mkfs.vfat -F32 "${disk}1"
  mkfs.ext4 "${disk}2"
}

disk::mount() {
  disk::check
  echo "Mounting partitions"

  mount | grep -vq "${disk}1" || umount "${disk}1"
  mount | grep -vq "${disk}2" || umount "${disk}2"

  mount "${disk}2" /mnt
  mkdir -p /mnt/boot
  mount "${disk}1" /mnt/boot
}

nixos::dots() {
  echo "Cloning nixdots"

  mkdir -p /mnt/etc
  rm -rf /mnt/etc/nixos
  git clone https:://github.com/fentas/nixdots /mnt/etc/nixos
}

nixos::generate() {
  echo "Generating configuration"

  rm -f /mnt/etc/nixos/hosts/fentas/hardware-configuration.nix
  nixos-generate-config --root /mnt

  rm /mnt/etc/nixos/configuration.nix
  mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hosts/fentas
}

nixos::install() {
  echo "Installing NixOS"

  cd /mnt/etc/nixos
  nixos-install --flake '.#fentas'
}

main() {
  is_user_root || {
    echo "Please run as root"
    exit 1
  } >&2

  local disk
  disk::ask
  disk::format || :
  disk::mount

  nixos::dots
  inxos::generate
  nixos::install

}

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || main "${@}"