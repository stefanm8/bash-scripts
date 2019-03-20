#!/bin/bash

gcp_region="europe-west1"
gcp_zone="europe-west1-b"
machine="n1-standard-2"
image="ubuntu-1804-lts"
INSTANCE_NAME=$1
NO_OF_MINIONS=$2
NO_OF_MANAGERS=$3



usage() {
    cat <<EOF

    @Provisions gcp instances

    sh $0 [name] [number_of_minions] [number_of_managers] <flags>

    name - Name of the cluster all instances name will have as a prefix this param
    number_of_instances - How many instances should be provisioned

    --image="ubuntu" Image that should installed on the machines
    --machine="n1-standard-1" GCP machine type 

EOF
}


parse_flags() {
    if [ -z $INSTANCE_NAME ] || [ -z $NO_OF_MINIONS ] || [ -z $NO_OF_MANAGERS ] 
    then
        echo "You must provide name and number of instances"
        usage
        exit 1
    fi

    for flag in "--image" "--machine"
    do 

        flag_val="$(echo "$@" | awk -v flag="$flag" '{for(i=0;i<=NF;i++)if($i==flag)print $(i+1)}')" 

        case "$@" in
        *"$flag"*)
            eval ""$(echo $flag | tr -d '\-')=$flag_val"";;
        esac
        
    done
}

create_addresses() {
    for i in $(seq 1 $NO_OF_MANAGERS);
    do 
        set +x
        gcloud compute addresses create "$INSTANCE_NAME-$i" --region $gcp_region
        set -x
    done
        

}


create_instances() {

    for i in $(seq 1 $NO_OF_MINIONS)
    do
        inst_name="$INSTANCE_NAME-minion-$i"
        echo "Creating instance $inst_name"
        set +x
        gcloud compute instances create "$inst_name" \
        --can-ip-forward  \
        --machine-type "$machine" \
        --image-family "$image" \
        --boot-disk-size "20gb" --image-project "ubuntu-os-cloud" 
        set -x

    done

    for i in $(seq 1 $NO_OF_MANAGERS)
    do
        ip_addr=$(gcloud compute addresses list | grep "$INSTANCE_NAME\-$i" | awk '{print $2}')
        inst_name="$INSTANCE_NAME-controller-$i"
        echo "Creating instance $inst_name"
        set +x
        gcloud compute instances create "$inst_name" \
        --can-ip-forward  \
        --machine-type "$machine" \
        --image-family "$image" \
        --address "$ip_addr" \
        --boot-disk-size "20gb" --image-project "ubuntu-os-cloud"  
        set -x

    done

}

error() {
    echo "$1"
    exit 1
}

init() {
    if [ $EUID -ne 0 ]
    then
        error  "Script must be run as root"
    fi
    if [ -z $(which gcloud) ]
    then
        error "You must have installed gcloud suite"
    fi

    parse_flags $@
    create_addresses
    create_instances
    echo $NO_OF_MANAGERS

}

init


