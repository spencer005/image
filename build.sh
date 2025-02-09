#!/bin/bash
set -ouex pipefail

dnf5() { command dnf5 -y "$@"; }

# https://github.com/ublue-os/bluefin/blob/main/build_files/shared/build-base.sh
echo "::group:: Remove CLI Wrap"

# there is no 'rpm-ostree cliwrap uninstall-from-root', but this is close enough. See:
# https://github.com/coreos/rpm-ostree/blob/6d2548ddb2bfa8f4e9bafe5c6e717cf9531d8001/rust/src/cliwrap.rs#L25-L32
if [ -d /usr/libexec/rpm-ostree/wrapped ]; then
    # binaries which could be created if they did not exist thus may not be in wrapped dir
    rm -f \
        /usr/bin/yum \
        /usr/bin/dnf \
        /usr/bin/kernel-install
    # binaries which were wrapped
    mv -f /usr/libexec/rpm-ostree/wrapped/* /usr/bin
    rm -fr /usr/libexec/rpm-ostree
fi

echo "::endgroup::"

dnf5 copr enable ublue/os-akmods
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

dnf5 install kernel-cachyos-lto kernel-cachyos-lto-devel-matched

dnf5 copr disable ublue/os-akmods
dnf5 copr disable bieszczaders/kernel-cachyos
dnf5 copr disable bieszczaders/kernel-cachyos-addons
dnf5 copr disable bieszczaders/kernel-cachyos-lto
dnf5 copr disable solopasha/plasma-unstable

dnf5 clean all

systemctl enable podman.socket
