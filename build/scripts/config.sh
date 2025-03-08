#!/bin/bash
# Configuration file for build.sh
# Contains package lists and settings for the image build

# Third-party repositories
coprs=(
    "ublue-os/akmods"
    "bieszczaders/kernel-cachyos"
    "bieszczaders/kernel-cachyos-lto"
    "bieszczaders/kernel-cachyos-addons"
    "solopasha/plasma-unstable"
    "gmaglione/podman-bootc"
)

# Kernel configuration
# Package for initramfs
kernel="kernel-cachyos-lto"
# Base kernel packages to remove
kernel_pkgs=(
    "kernel"
    "kernel-core"
    "kernel-modules"
    "kernel-modules-core"
    "kernel-modules-extra"
)

# Package management
install=(
    # Desktop environment
    "@kde-desktop"
    
    # Terminal and shell
    "zsh"
    "foot"
    
    # CLI utilities
    "eza"
    "bat"
    "helix"
    "ripgrep"
    "fd-find"
    
    # Development libraries
    "libcap-ng-devel"
    "procps-ng-devel"
    
    # CachyOS packages
    "cachyos-ksm-settings"
    "scx-scheds"
    "cachyos-settings"
    "kernel-cachyos-lto"
    "kernel-cachyos-lto-devel-matched"
    
    # Container tools
    "podman-bootc"
)

remove=(
    "dolphin"
    "firefox"
    "toolbox"
    "filelight"
    "konsole"
    "ark"
    "vim"
)

# Enable systemd units
units=(
    "podman.socket"
)