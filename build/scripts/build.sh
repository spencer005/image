#!/bin/bash
# Main build script for image creation

# Force script to exit on error, undefined variables, and pipe failures
set -ouex pipefail

# Load supporting scripts
script_dir="$(dirname "$(realpath "$0")")"
source "${script_dir}/functions.sh"
source "${script_dir}/config.sh"

# 1. Setup environment
section "Setting up build environment"
remove_cliwrap
section_end

# 2. Package management
section "Enabling COPR repositories"
copr enable "${coprs[@]}"
section_end

dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

section "Installing and configuring packages"
# Remove existing kernel packages
rpm --erase --nodeps -- "${kernel_pkgs[@]}"

# Install new packages
dnf install --allowerasing "${install[@]}"

# Swap specific packages
dnf swap wpa_supplicant iwd

# Remove unwanted packages
dnf remove "${remove[@]}"
section_end

section "Cleaning up repositories"
copr disable "${coprs[@]}"
dnf clean all
section_end

# 3. System configuration
section "Generating initramfs with dracut"
generate_initramfs "$kernel"
section_end

section "Configuring system services"
enable_units "${units[@]}"
section_end

echo "✅ Build completed successfully"
