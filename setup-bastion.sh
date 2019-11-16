#! /bin/bash
#
# Set defaults and checks.
# This is useful if you want to include this in a startup script without passing options.
# Or just if you need it to clone always the same settings.
user="myme"
host="mybastion"
pubkey="fakekey"
#
if [ "a$1" == "a-h" ]; then
    echo "Run it like this:"
    echo "$0 <user> <host> -k <public-key>"
    exit 0
fi
#
if [ "a$1" != "a" ]; then
    echo "Setting up for user: $1"
    user=$1
    shift;
    if [ "a$1" != "a" ]; then
	echo "Setting up for hostname: $1"
	host=$1
	shift;
    fi
fi
#
#
if [ "a$user" == "amyme" ]; then
    echo "Please edit this file and set a different main user"
    echo ".. or run it like this:"
    echo "$0 <user> <host> -k <public-key>"
    exit 1
fi
#
if [ "a$host" == "amybastion" ]; then
    echo "Please edit this file and set a different hostname"
    echo ".. or run it like this:"
    echo "$0 <user> <host> -k <public-key>"
    exit 1
fi
if [ "a$1" == "a-k" ]; then
    shift;
    pubkey=$1
fi
#
if [ "a$pubkey" == "afakekey" ]; then
    echo "Please edit this file and set a different public key"
    echo ".. or run it like this:"
    echo "$0 <user> <host> -k <public-key>"
    exit 1
fi
#
#
# Make sure you are up to date
apt -y update && apt -y  upgrade && apt -y autoremove --purge
#
# This might require reboot: skipping for now
## apt-get dist-upgrade
#
# Make sure you do not have stale configs
dpkg -l | grep '^rc' | awk '{print $2;}' | xargs  apt -y purge
#
# Remove not really needed packages (this list should grow)
# Maybe we can move this step above to save some time in the upgrade
# from a relatively old dist on the SD
# - 1) Some obvious
apt -y remove libreoffice* wolfram* minecraft-pi sonic-pi scratch nuscratch
apt -y autoremove --purge
# - 2) Others
apt -y remove idle3 smartsim python-minecraftpi python3-minecraftpi bluej nodered claws-mail \
    claws-mail-i18n python-pygame --purge -y
apt -y autoremove --purge
# - 2) Odds
apt -y remove java-common openjdk-11-jre-headless
apt -y autoremove --purge
#
# Iterate once more on cleaning after packages removal (needed?)
apt clean && apt autoremove --purge -y
apt -y update && apt -y upgrade  && apt -y autoremove --purge
dpkg -l | grep '^rc' | awk '{print $2;}' | xargs  apt -y purge
#
# We need to know some iformation.
# The hostname:
#              - default is raspberrypi
#              - The new name would be what you set on top
#
# Set up the hostname
# /etc/hosts
cat /etc/hosts > /tmp/x.$$.setup-bastion.hosts
sed "s/raspberrypi/${host}/" /tmp/x.$$.setup-bastion.hosts > /etc/hosts
rm /tmp/x.$$.setup-bastion.hosts
#
# /etc/hostname
echo "${host}" > /etc/hostname
#
# Add the new use 
# useradd -d /home/"${user}" -m -U -s /bin/false "${user}"
useradd -d /home/"${user}" -m -U "${user}"
# Add the new use to most groups (To be updated)
adduser "${user}" sudo
adduser "${user}" adm
adduser "${user}" dialout
adduser "${user}" cdrom
adduser "${user}" audio
adduser "${user}" video
adduser "${user}" plugdev
adduser "${user}" users
adduser "${user}" input
adduser "${user}" netdev
adduser "${user}" spi
adduser "${user}" i2c
adduser "${user}" gpio
#
if [ ! -d /home/"${user}"/.ssh ]; then
    mkdir /home/"${user}"/.ssh
    chown "${user}"."${user}" /home/"${user}"/.ssh
    chmod 700 /home/"${user}"/.ssh
fi
#
echo "${pubkey}" >> /home/"${user}"/.ssh/authorized_keys
chown "${user}"."${user}" /home/"${user}"/.ssh/authorized_keys
chmod 640 /home/"${user}"/.ssh/authorized_keys
#
# lock out password access
passwd -l "${user}"
#
if [ ! -d /etc/sudoers.d ]; then
    echo "no sudoers.d folder. Something odd?"
    exit 1;
fi
#
# This you need if you want to use ony ${user} as account and you want
# to run maintenance too.
# In principle this lowers the security. But see later if you remove the pi user.
echo "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/010_"${user}"-nopasswd
#
# some installs
apt install ufw
apt install fail2ban
#
ufw allow ssh
#
# cross fingers ;)
ufw enable
ufw status
#
# Remove the pi user. Or lock the pi user to internal su -.
# I do not suggest to remove the pi user completely.
# raspi-config command has some dependencies, which should not matter
# in principle from the user, but for example you cannot run it as root.
# You need a sudo raspi-config run. I suggest to lock it:

#REMOVEME passwd -l pi

# Then you can do from root: sudo su - pi
# A ref is: https://www.raspberrypi.org/documentation/configuration/security.md
# Citing: "... Please note that with the current Raspbian distribution, there are some aspects that require the pi user to be present. If you are unsure whether you will be affected by this, then leave the pi user in place. ..."
#
# From the same link: https://www.raspberrypi.org/documentation/configuration/security.md
# You can get the set up for the fail2ban
