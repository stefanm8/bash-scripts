#!/bin/bash

if [ $EUID -ne 0 ]
then
    echo "Script must be run as root"
else
    echo "Installing docker"
    sh -c "$(curl -fsSL https://get.docker.com)" 
fi

