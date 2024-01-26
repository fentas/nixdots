#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash git coreutils gptfdisk util-linux nixUnstable

set -euo pipefail

is_user_root() { [ "${EUID:-$(id -u)}" -eq 0 ]; }
partition() {
  lsblk -nplo NAME "${1}" | tail -n+2 | grep "${2}$"
}

disk::ask() {
  readarray -t disks < <(lsblk -d -n -p -l -o NAME,SIZE,MODEL)
  echo "Which disk do you want to install to?"
  for i in "${!disks[@]}"; do
    echo "$i) ${disks[$i]}"
  done
  while true; do
    echo -n "[0-$(( ${#disks[@]} - 1 ))]: "
    read -r disk_index
    [[ "${disk_index}" =~ ^[0-9]+$ ]] && [ "${disk_index}" -ge 0 ] && [ "${disk_index}" -lt "${#disks[@]}" ] && break ||
      echo "Invalid input 😕. Make sure to select the correct disk."
  done
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
  mkfs.vfat -F32 "$(partition "${disk}" 1)"
  mkfs.ext4 "$(partition "${disk}" 2)"
}

disk::mount() {
  disk::check
  echo "Mounting partitions"

  local -r p1="$(partition "${disk}" 1)"
  local -r p2="$(partition "${disk}" 2)"

  mount | grep -vq "${p1}" || umount "${p1}"
  mount | grep -vq "${p2}" || umount "${p2}"

  mount "${p2}" /mnt
  mkdir -p /mnt/boot
  mount "${p1}" /mnt/boot
}

nixos::dots() {
  echo "Cloning nixdots"

  mkdir -p /mnt/etc
  rm -rf /mnt/etc/nixos
  git clone https://github.com/fentas/nixdots /mnt/etc/nixos
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