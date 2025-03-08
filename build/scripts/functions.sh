#!/bin/bash
# Utility functions for build.sh

# Force script to exit on error, undefined variables, and pipe failures
set -ouex pipefail

# Function to print section headers consistently
section() {
    echo "::group::$1"
    echo "▶ $1"
}

section_end() {
    echo "::endgroup::"
    echo
}

# Wrapper for dnf to always use dnf5 with -y flag
dnf() { 
    command dnf5 -y "$@"
}

# Manage COPR repositories
# Usage: copr [enable|disable] repo1 [repo2 ...]
copr() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: copr [enable|disable] repo1 [repo2 ...]" >&2
        return 1
    fi

    local action="$1"
    if [ "$action" != "enable" ] && [ "$action" != "disable" ]; then
        echo "Invalid action: $action. Only 'enable' or 'disable' are supported." >&2
        return 1
    fi
    shift

    for repo in "$@"; do
        echo "COPR: $action $repo"
        dnf copr "$action" "$repo"
    done
}

# Remove rpm-ostree CLI wrappers and restore native binaries
remove_cliwrap() {
    echo "Removing rpm-ostree CLI wrappers..."
    if [ -d /usr/libexec/rpm-ostree/wrapped ]; then
        # binaries which could be created if they did not exist thus may not be in wrapped dir
        rm -f \
            /usr/bin/yum \
            /usr/bin/dnf \
            /usr/bin/kernel-install
        # binaries which were wrapped
        mv -f /usr/libexec/rpm-ostree/wrapped/* /usr/bin
        rm -fr /usr/libexec/rpm-ostree
    else
        echo "No wrappers found, skipping."
    fi
}

# Enable systemd units
enable_units() {
    echo "Enabling systemd units:"
    for unit in "$@"; do
        echo "  - $unit"
        systemctl enable "$unit"
    done
}

# Generate initramfs for specified kernel
generate_initramfs() {
    local KERNEL_PACKAGE=$1
    local KERNEL_VERSION=$(rpm -q $KERNEL_PACKAGE --qf "%{version}-%{release}.%{arch}\n" | head -n1)

    echo "Generating initramfs for kernel version: $KERNEL_VERSION"
    
    /usr/bin/dracut \
        --no-hostonly \
        --kver "$KERNEL_VERSION" \
        --reproducible \
        -v \
        --add ostree \
        -f "/lib/modules/$KERNEL_VERSION/initramfs.img"

}