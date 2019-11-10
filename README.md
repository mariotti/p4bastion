# p4bastion

Setup a bastion, eventually secured, with a raspberry pi

## An initial script

This script is a POC for an actual bastion set up. At present it helps me
in keeping an up to date bastion for my home network and for some offices ;)

Most relevant info come from:

https://www.raspberrypi.org/documentation/configuration/security.md

Which is more about securing then bastioning ;

It was tested only only on few machines and does not grant extra security.

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

## What it does

 - removes some packages
 - it tryes hard to cleanup old configurations
 - assign an hostname to your pi
 - create a new user
 - activate a fiewall