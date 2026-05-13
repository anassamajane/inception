#!/bin/bash

useradd -m $FTP_USER

echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

mkdir -p /home/$FTP_USER/wordpress

chown -R $FTP_USER:$FTP_USER /home/$FTP_USER

# to fix issue 500 OOPS
mkdir -p /var/run/vsftpd/empty

exec vsftpd /etc/vsftpd.conf
