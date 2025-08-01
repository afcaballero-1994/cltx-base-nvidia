#!/bin/bash

set -ouex pipefail

dnf update -y

dnf install epel-release -y
dnf config-manager --set-enabled crb -y


dnf install -y \
    wget pkgconf-pkg-config libstdc++\
    kernel-devel kernel-devel-matched\
    kernel-headers \
    dkms xorg-x11-proto-devel\
    vulkan libglvnd libglvnd-devel libglvnd-egl\
    vulkan-tools \
    vulkan-headers \
    vulkan-loader-devel xorg-x11-server-Xwayland


touch \
    /etc/modprobe.d/nouveau-blacklist.conf

echo "blacklist nouveau" | tee \
    /etc/modprobe.d/nouveau-blacklist.conf

echo "options nouveau modeset=0" | tee -a \
    /etc/modprobe.d/nouveau-blacklist.conf


kver=$(cd /usr/lib/modules && echo * | awk '{print $NF}')

dracut -f --kver=$kver --reproducible --zstd --no-hostonly /usr/lib/modules/$kver/initramfs.img $kver

NVIDIA_DRIVER_VERSION="575.51.02"

wget \
    https://us.download.nvidia.com/XFree86/Linux-x86_64/$NVIDIA_DRIVER_VERSION/NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION.run

chmod +x NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION.run


/NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION.run\
    --silent --run-nvidia-xconfig --dkms \
    --kernel-source-path /usr/src/kernels/$kver \
    --kernel-module-type=proprietary \
    --kernel-name=$kver

rm -f /NVIDIA-Linux-x86_64-$NVIDIA_DRIVER_VERSION.run
dracut -vf --kver=$kver --reproducible --zstd --no-hostonly /usr/lib/modules/$kver/initramfs.img $kver

dnf remove $(dnf repoquery --installonly --latest-limit=-1 -q) -y
