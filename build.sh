#!/bin/bash
set -ouex pipefail

dnf5() { command dnf5 -y "$@"; }
dnf() { command dnf -y "$@"; }

dnf5 copr enable bieszczaders/kernel-cachyos
dnf5 copr enable bieszczaders/kernel-cachyos-lto
dnf5 copr enable bieszczaders/kernel-cachyos-addons
dnf5 copr enable solopasha/plasma-unstable

packages=(
    "@kde-desktop"
    "zsh"
    "foot"
    "eza"
    "bat"
    "helix"
    "ripgrep"
    "fd-find"
    "strace"
    "setools-console"
    "libcap-ng-devel"
    "procps-ng-devel"
    "cachyos-ksm-settings"
    "scx-scheds"
    "cachyos-settings"
)

dnf5 install --allowerasing "${packages[@]}"

dnf5 swap wpa_supplicant iwd

dnf5 remove toolbox firefox

# remove kernel packages
kernel_pkgs=(
    "kernel"
    "kernel-core"
    "kernel-modules"
    "kernel-modules-core"
    "kernel-modules-extra"
    "kernel-tools"
    "kernel-tools-libs"
)

rpm --erase --nodeps -- "${kernel_pkgs[@]}"

# use dnf to make use of replace-kernel from rpm-ostree
dnf install kernel-cachyos-lto kernel-cachyos-lto-devel-matched

dnf5 copr disable bieszczaders/kernel-cachyos
dnf5 copr disable bieszczaders/kernel-cachyos-addons
dnf5 copr disable bieszczaders/kernel-cachyos-lto
dnf5 copr disable solopasha/plasma-unstable

dnf5 clean all

systemctl enable podman.socket
