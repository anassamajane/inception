
# FTP Service Explanation (vsftpd)

## What is vsftpd?

vsftpd stands for:

> Very Secure FTP Daemon

It is an FTP server used to:

* upload files
* download files
* manage remote files

In this project, the FTP container shares the same WordPress volume used by:

* WordPress
* Nginx

This allows uploaded files to instantly appear on the website.

---

# vsftpd Configuration Explained

## listen=YES

```conf
listen=YES
```

This tells vsftpd to:

* run in standalone mode
* directly listen for FTP connections itself

Without this, vsftpd may expect another service like:

* inetd
* xinetd

Inside Docker, standalone mode is preferred because:

* the container usually runs one main process only

Flow:

```text
Client ---> vsftpd directly
```

---

## anonymous_enable=NO

```conf
anonymous_enable=NO
```

FTP supports anonymous login.

Without authentication, users could connect like:

```bash
ftp website.com
Name: anonymous
```

This line disables anonymous access.

Only authenticated users can connect.

---

## local_enable=YES

```conf
local_enable=YES
```

This allows Linux system users to login through FTP.

Example Linux user:

```bash
useradd ftpuser
```

Without this option:

* local Linux users cannot login

---

## write_enable=YES

```conf
write_enable=YES
```

This enables write operations:

* upload files
* delete files
* rename files
* modify files

Without this:

* FTP becomes read-only

---

## local_umask=022

```conf
local_umask=022
```

Controls permissions of uploaded files.

Linux uses:

```text
final permissions = default permissions - umask
```

Example:

```text
666 - 022 = 644
```

Result:

```text
rw-r--r--
```

Meaning:

* owner can read/write
* others can only read

This is the standard safe configuration.

---

## pasv_enable=YES

```conf
pasv_enable=YES
```

FTP uses two connections:

1. command connection
2. data connection

Passive mode allows the client to connect to server data ports correctly.

This is extremely important in:

* Docker
* NAT
* firewalls

Without passive mode:

* uploads
* downloads
* ls command

often fail.

Example during FTP session:

```text
229 Entering Extended Passive Mode (|||10073|)
```

This means:

* server opened port 10073
* client connected there for data transfer

---

## chroot_local_user=YES

```conf
chroot_local_user=YES
```

This locks users inside their home directory.

Without it, users could navigate outside their area:

```text
/etc
/var
/home
```

With chroot enabled:

```text
/home/ftpuser/wordpress
```

becomes the user's root directory.

The user cannot escape this directory.

This acts like a jail.

---

## allow_writeable_chroot=YES

```conf
allow_writeable_chroot=YES
```

vsftpd normally refuses:

* writable home directory
* combined with chroot

because older FTP systems considered it unsafe.

Without this option, errors like this appear:

```text
500 OOPS: vsftpd: refusing to run with writable root inside chroot()
```

This line disables that restriction.

It is required because:

* the WordPress volume must be writable

---

## user_sub_token=$USER

```conf
user_sub_token=$USER
```

This creates a variable placeholder.

Example:

If logged user is:

```text
ftpuser
```

then:

```text
$USER -> ftpuser
```

---

## local_root=/home/$USER/wordpress

```conf
local_root=/home/$USER/wordpress
```

Defines the directory users enter after login.

Example:

```text
/home/ftpuser/wordpress
```

This directory is connected to the shared WordPress volume.

Therefore:

* uploaded files directly affect the website files

---

## pasv_min_port / pasv_max_port

```conf
pasv_min_port=10000
pasv_max_port=10100
```

FTP passive mode dynamically opens ports.

These lines restrict passive ports to:

```text
10000 → 10100
```

instead of random ports.

This is important for:

* Docker
* firewalls
* predictable networking

Docker must expose these ports:

```yaml
ports:
  - "10000-10100:10000-10100"
```

---

# FTP Startup Script Explained

## useradd -m $FTP_USER

```bash
useradd -m $FTP_USER
```

Creates a Linux user.

`-m` creates the home directory automatically.

Example:

```text
/home/ftpuser
```

vsftpd authenticates against Linux users.

---

## echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

```bash
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
```

Sets the user's password automatically.

Equivalent to:

```bash
passwd ftpuser
```

---

## mkdir -p /home/$FTP_USER/wordpress

```bash
mkdir -p /home/$FTP_USER/wordpress
```

Creates the FTP working directory.

Example:

```text
/home/ftpuser/wordpress
```

This becomes the FTP root directory.

---

## chown -R $FTP_USER:$FTP_USER /home/$FTP_USER

```bash
chown -R $FTP_USER:$FTP_USER /home/$FTP_USER
```

Changes ownership of files/directories.

Without proper ownership:

* FTP uploads may fail

This gives the FTP user permission to modify files.

---

## mkdir -p /var/run/vsftpd/empty

```bash
mkdir -p /var/run/vsftpd/empty
```

Creates a secure empty directory required internally by vsftpd.

Without it, vsftpd may fail with:

```text
500 OOPS
```

---

## exec vsftpd /etc/vsftpd.conf

```bash
exec vsftpd /etc/vsftpd.conf
```

Starts the FTP server using the configuration file.

`exec` replaces the shell process.

This makes:

```text
vsftpd = PID 1
```

which is the correct Docker behavior.

---

# How FTP File Transfer Works

Flow:

```text
Host machine
    ↓
FTP client
    ↓
vsftpd container
    ↓
shared WordPress volume
    ↓
Nginx serves files from same volume
```

This is why uploaded files instantly appear on the website.

---

# FTP Commands

## Connect

```bash
ftp anaamaja.42.fr
```

Opens FTP session.

---

## Upload File

```bash
put file.txt
```

Uploads:

* client → server

---

## Download File

```bash
get file.txt
```

Downloads:

* server → client

---

## List Files

```bash
ls
```

Shows remote directory contents.

---

## Delete File

```bash
delete file.txt
```

Deletes remote file.

---

## Rename File

```bash
rename old.txt new.txt
```

Renames remote file.

---

# Important Concept

FTP does NOT serve websites.

FTP only transfers files.

Nginx serves the website.

The FTP container modifies files inside the shared WordPress volume, and Nginx immediately serves those updated files.
