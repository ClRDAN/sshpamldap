#! /bin/bash
# @edt ASIX M06 2018-2019
# instalacion cliente PAM examen
# - crear usuarios locales
#----------------------------
cp /opt/docker/system-auth.edt /etc/pam.d/system-auth.edt
cp /opt/docker/pam_mount.conf.xml /etc/security/
cp /opt/docker/nsswitch.conf /etc/
ln -fs /etc/pam.d/system-auth.edt /etc/pam.d/system-auth
./authconfig.conf
cp /opt/docker/sshd_conf /etc/ssh/sshd_config
useradd -g users local01 
useradd -g users local02
useradd -g users local03
echo "local01" | passwd --stdin local01
echo "local02" | passwd --stdin local02
echo "local03" | passwd --stdin local03
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N "" < /dev/null
/usr/sbin/nslcd
/usr/sbin/sshd
