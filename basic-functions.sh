#! /bin/bash
#
function fullupgrade() {
    apt -y update && apt -y  upgrade && apt -y autoremove --purge
}
#
function cleanupstale() {
    apt -y clean
    apt -y autoremove --purge
    dpkg -l | grep '^rc' | awk '{print $2;}' | xargs  apt -y purge
}
#
function removeunusedpkg() {
    #
    # The split into these lists is at present arbitrary.
    # It might be useful in the future to define targets like: tunnel, vpn, etc...
    extrapkgs=$1
    standardpkgs="libreoffice* wolfram* minecraft-pi sonic-pi scratch nuscratch"
    additionalpkgs="remove idle3 smartsim python-minecraftpi python3-minecraftpi bluej nodered claws-mail claws-mail-i18n python-pygame"
    specialpkgs="java-common openjdk-11-jre-headless"
    #
    # Now we merge them together. Consider running splitted apt remove if the list gets too long
    allpkgs="$extrapkgs $standardpkgs $additionalpkgs $specialpkgs"
    apt -y remove "$allpkgs"
    #
    # Clean up again
    cleanupstale
}
#
function sethostname() {
    # /etc/hosts
    myhost=$1
    if [ "a$1" == "a" ]; then
	echo "Missing host in function sethostname()"
	exit 1
    fi
    
    cat /etc/hosts > /tmp/x.$$.setup-bastion.hosts
    sed "s/raspberrypi/${myhost}/" /tmp/x.$$.setup-bastion.hosts > /etc/hosts
    rm /tmp/x.$$.setup-bastion.hosts
    #
    # /etc/hostname
    echo "${myhost}" > /etc/hostname
}
#
function adduserwithgroups() {
    myuser=$1
    if [ "a$1" == "a" ]; then
	echo "Missing user in function adduserwithgroups()"
	exit 1
    fi
    # Add the new use to most groups (To be updated)
    mygroups="sudo adm dialout cdrom audio video plugdev users input netdev spi i2c gpio"
    #
    # Add the new user
    # useradd -d /home/"${myuser}" -m -U -s /bin/false "${myuser}"
    useradd -d /home/"${myuser}" -m -U "${myuser}"
    for gg in ${mygroups}; do
	adduser "${myuser}" "${gg}"
    done
}
#
function addsshpublickey() {
    myuser=$1
    if [ "a$1" == "a" ]; then
	echo "Missing user in function addsshpublickey()"
	exit 1
    fi
    mykey=$2
    if [ "a$2" == "a" ]; then
	echo "Missing key in function addsshpublickey()"
	exit 1
    fi
    #
    if [ ! -d /home/"${myuser}"/.ssh ]; then
	mkdir /home/"${myuser}"/.ssh
	chown "${myuser}"."${myuser}" /home/"${myuser}"/.ssh
	chmod 700 /home/"${myuser}"/.ssh
    fi
    #
    echo "${mykey}" >> /home/"${myuser}"/.ssh/authorized_keys
    chown "${myuser}"."${myuser}" /home/"${myuser}"/.ssh/authorized_keys
    chmod 640 /home/"${myuser}"/.ssh/authorized_keys
    #   
    # lock out password access
    passwd -l "${myuser}"
}
#
function setupsudo() {
    myuser=$1
    if [ "a$1" == "a" ]; then
	echo "Missing user in function setupsudo()"
	exit 1
    fi
    #
    if [ ! -d /etc/sudoers.d ]; then
	echo "no sudoers.d folder. Something odd?"
	exit 1;
    fi
    #
    echo "${myuser} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/010_"${myuser}"-nopasswd
}
#
function setupufw() {
    apt install ufw
    ufw allow ssh
    # cross fingers ;)
    ufw enable
    ufw status
}
#
function setupfail2ban() {
    apt install fail2ban
    echo "WARN: fail2ban installed but left inconfigured"
    # From this link: https://www.raspberrypi.org/documentation/configuration/security.md
    # You can get the set up for the fail2ban
}
#
function lockpiuser() {
    passwd -l pi
}
