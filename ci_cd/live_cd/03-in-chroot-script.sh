#!/usr/bin/env sh
set -x

ENTRUSTED_VERSION=$(cat /etc/entrusted_release | head -1)
ENTRUSTED_ARCH=$(cat /etc/entrusted_arch | head -1)

echo "Setting up hostname"
echo "entrusted-livecd" > /etc/hostname

echo "Installing default packages"
export DEBIAN_FRONTEND=noninteractive

apt update && \
    apt install -y --no-install-recommends \
    linux-image-${ENTRUSTED_ARCH} \
    auditd \
    iptables-persistent \
    doas \
    uidmap \
    dbus-user-session \
    slirp4netns \
    fuse-overlayfs \
    ca-certificates \
    curl \
    wget \
    locales \
    network-manager \
    net-tools \
    mg \
    openssh-sftp-server \
    openssh-server \
    podman \
    live-boot \
    syslinux-efi \
    grub-efi-${ENTRUSTED_ARCH}-bin \
    systemd-sysv

apt clean

echo "Setting up system files"
cp /files/etc/iptables/rules.v4 /etc/iptables/
cp /files/etc/doas.conf /etc/ && chmod 400 /etc/doas.conf
cp /files/etc/systemd/system/entrusted-webserver.service /etc/systemd/system/

echo "Creating entrusted user"
useradd -ms /bin/bash entrusted
usermod -G sudo entrusted

echo "Creating entrusted user files and pulling container image"
runuser -l entrusted -c "/files/04-user-chroot-script.sh ${ENTRUSTED_VERSION}"

echo "Copying entrusted binaries"
mv /files/entrusted-webserver /files/entrusted-cli /usr/local/bin
cp /files/usr/local/bin/entrusted-fw-enable /usr/local/bin/entrusted-fw-enable
cp /files/usr/local/bin/entrusted-fw-disable /usr/local/bin/entrusted-fw-disable
chmod +x /usr/local/bin/entrusted-*

echo "Updating default screen messages"
cp /files/etc/motd /etc/motd
cp /files/etc/issue /etc/issue
cp /files/usr/share/containers/containers.conf /usr/share/containers/containers.conf

echo "Updating passwords"
echo 'root:root' | /usr/sbin/chpasswd
echo 'entrusted:entrusted' | /usr/sbin/chpasswd

echo "Enabling default services"
systemctl enable ssh
systemctl enable NetworkManager
systemctl enable netfilter-persistent
systemctl enable systemd-networkd
systemctl enable entrusted-webserver

rm -rf /files

echo "apm power_off=1" >> /etc/modules

# See https://madaidans-insecurities.github.io/guides/linux-hardening.html
echo "Hardening system"

echo "kernel.kptr_restrict=2" >> /etc/sysctl.conf
echo "kernel.dmesg_restrict=1" >> /etc/sysctl.conf
echo "kernel.unprivileged_bpf_disabled=1" >> /etc/sysctl.conf
echo "net.core.bpf_jit_harden=2" >> /etc/sysctl.conf
echo "kernel.kexec_load_disabled=1" >> /etc/sysctl.conf
echo "vm.unprivileged_userfaultfd=0" >> /etc/sysctl.conf
echo "kernel.sysrq=4" >> /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf

echo "net.ipv4.tcp_rfc1337=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=1" >> /etc/sysctl.conf
echo "net.ipv4.icmp_echo_ignore_all=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_source_route=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route=0" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_source_route=0" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_source_route=0" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_ra=0" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_ra=0" >> /etc/sysctl.conf
echo "net.ipv4.tcp_sack=0" >> /etc/sysctl.conf
echo "net.ipv4.tcp_dsack=0" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fack=0" >> /etc/sysctl.conf

echo "kernel.yama.ptrace_scope=2" >> /etc/sysctl.conf
echo "vm.mmap_rnd_bits=32" >> /etc/sysctl.conf
echo "vm.mmap_rnd_compat_bits=16" >> /etc/sysctl.conf
echo "fs.protected_symlinks=1" >> /etc/sysctl.conf
echo "fs.protected_hardlinks=1" >> /etc/sysctl.conf
echo "fs.protected_fifos=2" >> /etc/sysctl.conf
echo "fs.protected_regular=2" >> /etc/sysctl.conf

echo "Trim filesystem"
rm -rf /usr/share/man/* /usr/share/doc/* /usr/share/info/*

exit
