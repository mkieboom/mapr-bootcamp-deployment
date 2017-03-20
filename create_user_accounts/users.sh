#!/bin/bash

# Script to create or remove users for the bootcamp
# usage: ./users.sh <create/remove> <amount_of_users> <password>
#
# examples
#
# create 30 users with username user01..user30 and password m@prr0cks!:
# ./users.sh create 30 m@prr0cks!
#
# remove 30 users:
# ./users.sh remove 30
#
uname="user"
uid="90"
gid=$(id -g mapr 2>&1)


if [ $(echo "$1" |tr [:upper:] [:lower:]) = "create" ]; then
	for i in `eval echo {01..$2}`
	do
	    # Just print this for debugging
	    printf "\tCreating user: %s%s\n" $uname$i
	    printf "\tuserid: %s\n" $uid$i

	    # Create the user with adduser
	    useradd $uname$i --gid $gid --uid $uid$i -p $(openssl passwd -crypt $3)
	    usermod -a -G root $uname$i
	    /opt/mapr/bin/maprcli acl edit -type cluster -user $uname$i:fc
	done
fi

if [ $(echo "$1" |tr [:upper:] [:lower:]) = "remove" ]; then
	for i in `eval echo {01..$2}`
	do
	    printf "\tRemoving user: %s%s\n" $uname$i
	    userdel -r $uname$i
	done
fi
