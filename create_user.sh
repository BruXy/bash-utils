#!/bin/bash
#
# Run as root
#

USER="$1"
KEY="$(cat $2)"

useradd -m $USER
mkdir /home/$USER/.ssh
echo "$KEY" > /home/$USER/.ssh/authorized_keys
echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER
chsh -s /bin/bash $USER
chown -R ${USER}. /home/$USER/.ssh/
chmod 600 /home/$USER/.ssh/authorized_keys

