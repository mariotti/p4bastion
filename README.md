# p4bastion

Setup a bastion, eventually secured, with a raspberry pi

## An initial script

This script is a POC for an actual bastion set up. At present it helps me
in keeping an up to date bastions for my home network and for some offices ...

The most relevant info and documentation come from:

https://www.raspberrypi.org/documentation/configuration/security.md

Which is about securing a pi.

It was tested only on few machines and does not grant any extra security.

## How to run the script

First copy it on any confortable location in your raspberry. Eventually:

    chmod +x <theLocation>/setup-bastion.sh
    cd <theLocation>

You do need to be root (be on the root account). Rus as:

    ./setup-bastion.sh <yourUserName> <hisHostName> -k '<yourPublicKey>'

Example:

    ./setup-bastion.sh mariobros mariobastion -k 'ssh-rsa ABAAB3NzbC2.............................'

As running the script might lock you out of the raspberry, I commented this like:

    #REMOVEME passwd -l pi

You might want to put it back.

If in the -k '<>publicKey' you did put the right thing, you should be able to connect
with simply:

    ssh mariobros@<usualIP>

Or in some lucky cases:

    ssh mariobros@mariobastion.local


## What it does

 - removes some packages
 - it tryes hard to cleanup old configurations
 - assign an hostname to your pi
 - creates a new user
 - activate a fiewall

# The bastion

The above thing, script does not do anything except trying to secure that machine.

You do need port forwarding or anything close to that witihn your network.

More about this on a later time.