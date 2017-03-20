#!/bin/bash

uname="user"
uid="90"
gid=$(id -g mapr 2>&1)

for i in {01..$1}; do
    # Just print this for debugging
    printf "\tCreating user: %s%s\n" $uname$i
    printf "\tuserid: %s\n" $uid$i

    # Create the user with adduser
    useradd $uname$i --gid $gid --uid $uid$i -p $(openssl passwd -crypt $2)
    usermod -a -G root $uname$i
    /opt/mapr/bin/maprcli acl edit -type cluster -user $uname$i:fc
done