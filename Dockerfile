#version: 0.0.1
#@edt M06 2018-2019
#host PAM
#----------------------
FROM edtasixm06/exam:latest
LABEL author="@edt ASIX M06 Curs 2018-2019"
LABEL description=" practica PAM SSH LDAP @edt.org "
RUN dnf -y install procps vim less tree nmap mlocate iproute openldap-clients nss-pam-ldapd passwd authconfig 
RUN mkdir /opt/docker
COPY * /opt/docker/
RUN chmod +x /opt/docker/install.sh /opt/docker/startup.sh /opt/docker/authconfig.conf
CMD ["/opt/docker/startup.sh"]
WORKDIR /opt/docker

