#!/bin/bash
set -ouex pipefail

echo "::group::setup and remove cliwrap"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/functions.sh"
source "${SCRIPT_DIR}/config.sh"
remove_cliwrap
echo "::endgroup::"

echo "::group::Enable COPRs"
copr enable "${coprs[@]}"
echo "::endgroup::"

echo "::group::DNF"
rpm --erase --nodeps -- "${kernel[@]}"
dnf install --allowerasing "${install[@]}"
dnf swap wpa_supplicant iwd
dnf remove "${remove[@]}"
echo "::endgroup::"

echo "::group::Disable COPRs"
copr disable "${coprs[@]}"
echo "::endgroup::"

echo "::group::Clean DNF Cache"
dnf clean all
echo "::endgroup::"

echo "::group::Generate initramfs with dracut"
KERNEL_VERSION=$(rpm -q kernel-cachyos-lto --qf "%{version}-%{release}.%{arch}\n" | head -n1)

/usr/bin/dracut \
    --no-hostonly \
    --kver $KERNEL_VERSION \
    --reproducible \
    -v \
    --add ostree \
    -f "/lib/modules/$KERNEL_VERSION/initramfs.img"

echo "::endgroup::"

systemctl enable podman.socket
