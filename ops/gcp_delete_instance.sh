#!/bin/bash

NAME=$1

usage() {
    cat <<EOF 

    @Deletes all the gcloud compute instances within the current project

    sh $0 [name] || all

    name - optional arg, in case is provided it will delete only instances that contains the name
           if no arg is provided it will delete all instances
EOF
}


main() {

    case $NAME in
    *"help"*)
        usage
        exit 0;;
    esac

    if [[ -z $NAME ]]
    then
        echo "WARNING: It will delete all gcloud compute instances"
    fi


    cat <<EOF
WARNING: This script will delete your gcloud compute instances if this is not what you intend
    You may press Ctrl+C now to abort this script.
EOF
    set -x
    sleep 20

    for i in $(gcloud compute instances list | awk 'FNR>1{print $1}')
    do 
        if [[ $i == *"$NAME"* ]]
        then
            echo "DELETING: instance $i"
            gcloud compute instances delete $i &
        fi
    done
}

main

