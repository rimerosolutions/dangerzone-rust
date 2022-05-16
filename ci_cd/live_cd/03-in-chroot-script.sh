#!/usr/bin/env bash

DANGERZONE_VERSION=$(cat /etc/dangerzone_release | head -1)

echo "Setting up hostname"
echo "dangerzone-livecd" > /etc/hostname

echo "Installing default packages"
export DEBIAN_FRONTEND=noninteractive

apt update && \
    apt install -y \
    linux-image-amd64 \
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
    systemd-sysv

apt clean

echo "Setting up system files"
cp /files/etc/iptables/rules.v4 /etc/iptables/
cp /files/etc/doas.conf /etc/ && chmod 400 /etc/doas.conf
cp /files/etc/systemd/system/dangerzone-httpserver.service /etc/systemd/system/
cp /files/etc/systemd/system/mygarbage.service /etc/systemd/system/

fallocate -l 4G /usr/local/bin/mygarbage

echo "Creating dangerzone user"
useradd -ms /bin/bash dangerzone
usermod -G sudo dangerzone

echo "Creating dangerzone user files and pulling container image"
/usr/sbin/runuser -l dangerzone -c "/files/04-user-chroot-script.sh ${DANGERZONE_VERSION}"

echo "Copying dangerzone binaries"
mv /tmp/dangerzone-linux-amd64-${DANGERZONE_VERSION}/dangerzone-httpserver /tmp/dangerzone-linux-amd64-${DANGERZONE_VERSION}/dangerzone-cli /usr/local/bin
cp /files/usr/local/bin/dangerzone-fw-enable /usr/local/bin/dangerzone-fw-enable
cp /files/usr/local/bin/dangerzone-fw-disable /usr/local/bin/dangerzone-fw-disable
chmod +x /usr/local/bin/dangerzone-*

echo "Updating default screen messages"
cp /files/etc/motd /etc/motd
cp /files/etc/issue /etc/issue

echo "Updating passwords"
echo 'root:root' | /usr/sbin/chpasswd
echo 'dangerzone:dangerzone' | /usr/sbin/chpasswd

echo "Enabling default services"
systemctl enable ssh
systemctl enable NetworkManager
systemctl enable netfilter-persistent
systemctl enable systemd-networkd
systemctl enable dangerzone-httpserver
systemctl enable mygarbage

exit