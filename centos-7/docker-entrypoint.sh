#!/bin/bash
#
# Inspired by https://github.com/kwart/dockerfiles/tree/master/alpine-ext

set -e

echo
echo "Starting CentOS 7 with SSH server"
echo "=============================================="
echo
echo "User 'root' config"
echo "BROOKLYN_ROOT_PASSWORD           ${BROOKLYN_ROOT_PASSWORD:+*****}"
echo "BROOKLYN_ROOT_AUTHORIZED_KEY     ${BROOKLYN_ROOT_AUTHORIZED_KEY:0:20}"

if [ ! -f "/root/SSH_INITIALIZED_MARKER" ]; then
    echo
    echo "Configuring SSH" 

    touch /root/SSH_INITIALIZED_MARKER

    # set root password
    if [ -n "$BROOKLYN_ROOT_PASSWORD" ]; then
        echo
        echo "Changing root's password" 
        echo "root:$BROOKLYN_ROOT_PASSWORD" | chpasswd
    elif [ -n "$BROOKLYN_ROOT_AUTHORIZED_KEY" ]; then
        echo "Generating and changing root's password"
        PWPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
        echo "root:$PWPASS" | chpasswd
    else
        echo "Not changing root password"
    fi;

    # set root's authorized_keys
    if [ -n "$BROOKLYN_ROOT_AUTHORIZED_KEY" ]; then
        echo
        echo "Adding entry to /root/.ssh/authorized_keys"
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh/
        echo "$BROOKLYN_ROOT_AUTHORIZED_KEY" | tee /root/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys
    else
        echo "Not adding authorized ssh key"
    fi

else
    echo
    echo "Marked file /root/SSH_INITIALIZED_MARKER exists, so skipping initialisation"
fi

# Run sshd
/usr/sbin/sshd -D
