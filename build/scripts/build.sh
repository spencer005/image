#!/usr/bin/env bash
# Main build script for Universal-Blue image
# =========================================
set -o errexit -o nounset -o pipefail
set -o xtrace

# ── 0 · Silence gpg warnings ───────────────────────────────
export GNUPGHOME=/tmp/gnupg
install -d -m700 "$GNUPGHOME"

# ── 1 · Helpers & config ───────────────────────────────────
script_dir="$(dirname "$(realpath "$0")")"
source "${script_dir}/functions.sh"
source "${script_dir}/config.sh"

# ── 2 · Prepare base env ───────────────────────────────────
section "Setting up build environment"
remove_cliwrap
section_end

# ── 3 · Enable COPRs + RPM Fusion ──────────────────────────
section "Enabling COPR repositories"
copr enable "${coprs[@]}"
section_end

dnf install "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
dnf install "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# ── 4 · Build & install Phonon-mpv (Qt 6) ──────────────────
section "Building Phonon-mpv backend"

build_deps=(
  gcc cmake ninja-build extra-cmake-modules
  mpv-devel qt6-qtbase-devel phonon-qt6-devel
)

dnf install \
    --allowerasing \
    --exclude=vlc*,vlc-plugins-*,phonon-qt6-backend-vlc* \
    --setopt=install_weak_deps=False \
    "${build_deps[@]}"

git clone --depth 1 https://github.com/OpenProgger/phonon-mpv /tmp/phonon-mpv
cmake -S /tmp/phonon-mpv -B /tmp/phonon-mpv/build -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DPHONON_BUILD_QT5=OFF \
      -DPHONON_BUILD_QT6=ON
cmake --build    /tmp/phonon-mpv/build
cmake --install  /tmp/phonon-mpv/build

dnf remove "${build_deps[@]}"
rm -rf /tmp/phonon-mpv
section_end

# ── 5 · Kernel housekeeping ────────────────────────────────
rpm --erase --nodeps -- "${kernel_pkgs[@]}"

# ── 6 · Main package transaction ───────────────────────────
section "Installing and configuring packages"

dnf install \
    --allowerasing \
    --exclude=vlc*,vlc-plugins-*,phonon-qt6-backend-vlc* \
    --setopt=install_weak_deps=False \
    --setopt=group_package_types=mandatory,default \
    "${install[@]}"

dnf swap wpa_supplicant iwd --allowerasing
dnf swap phonon-qt6-backend-vlc phonon-qt6-backend-mpv --allowerasing || true
dnf remove "${remove[@]}"
section_end

# ── 7 · Disable COPRs & clean cache ────────────────────────
section "Cleaning up repositories"
copr disable "${coprs[@]}"
dnf clean all
section_end

# ── 8 · System configuration ───────────────────────────────
section "Generating initramfs with dracut"
generate_initramfs "$kernel"
section_end

section "Configuring system services"
enable_units "${units[@]}"
section_end

echo "✅ Build completed successfully"
