#!/bin/bash
set -ouex pipefail

dnf5() { command dnf5 -y "$@"; }

dnf5 copr enable ublue-os/akmods
dnf5 copr enable bieszczaders/kernel-cachyos
dnf5 copr enable bieszczaders/kernel-cachyos-lto
dnf5 copr enable bieszczaders/kernel-cachyos-addons
dnf5 copr enable solopasha/plasma-unstable

install=(
    "@kde-desktop"
    "zsh"
    "foot"
    "eza"
    "bat"
    "helix"
    "ripgrep"
    "fd-find"
    "libcap-ng-devel"
    "procps-ng-devel"
    "cachyos-ksm-settings"
    "scx-scheds"
    "cachyos-settings"
)

dnf5 install --allowerasing "${install[@]}"

dnf5 swap wpa_supplicant iwd

rm /etc/dnf/protected.d/sudo.conf

remove=(
    "toolbox"
    "firefox"
    "sudo"
    "vlc-libs"
    "vim-minimal"
    "clang"
)

dnf5 remove "${remove[@]}"

# remove kernel packages
kernel=(
    "kernel"
    "kernel-core"
    "kernel-modules"
    "kernel-modules-core"
    "kernel-modules-extra"
    "kernel-tools"
    "kernel-tools-libs"
)

rpm --erase --nodeps -- "${kernel[@]}"

dnf install kernel-cachyos-lto kernel-cachyos-lto-devel-matched

dnf5 copr disable ublue-os/akmods
dnf5 copr disable bieszczaders/kernel-cachyos
dnf5 copr disable bieszczaders/kernel-cachyos-addons
dnf5 copr disable bieszczaders/kernel-cachyos-lto
dnf5 copr disable solopasha/plasma-unstable

dnf5 clean all

systemctl enable podman.socket
