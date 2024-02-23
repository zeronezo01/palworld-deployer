#!/bin/bash


VERSION=$(date +"%Y%m%d%H%M%S")

NAME_CONTAINER="palworld"
NAME_IMAGE="ipalworld"

PATH_PWSETTINGS_DIR=/etc/palworld
NAME_PWSETTINGS=PalWorldSettings.ini
PATH_DEFAULT_PWSETTINGS=/home/steam/Steam/steamapps/common/PalServer/DefaultPalWorldSettings.ini
PATH_RUNNING_PWSETTINGS_DIR=/home/steam/Steam/steamapps/common/PalServer/Pal/Saved/Config/LinuxServer

PORT_SERVER=8211

function usage()
{
    echo "Usage: bash deploy.sh COMMAND [OPTIONS]"
    echo ""
    echo "A script to create|update|destroy palworld server container"
    echo ""
    echo "Common Commands:"
    echo -e "\tcreate:        create a new image&container with whole environment, base on ubuntu 20.04\n"
    echo -e "\tupdate:        update container to newer server version\n"
    echo -e "\tdestroy:       remove whole environment\n"
}

function existing_id()
{
    id_quote=$(docker ps --format json | jq "select(.Names == \"${NAME_CONTAINER}\").ID")
    id=${id_quote//\"/}
    echo ${id}
}

function usage_create()
{
    echo "Usage: bash deploy.sh create [OPTIONS]"
    echo ""
    echo "Create a whole new palworld server container"
    echo ""
    echo "Options:"
    echo -e "\t-p [PORT]       host port map to 8211/udp in palworld server\n"
}

function create()
{
    port=8211
    while getopts ":p:" opt
    do
        case $opt in
            p)
                port=$OPTARG
                ;;
            *)
                usage_create
                exit 1
                ;;
        esac
    done
    
    # remove existing container
    container=$(existing_id)
    if [ "${container}" != "" ]
    then
        docker stop ${container}
        docker rm ${container}
    fi

    # start build palworld image
    pushd docker
    docker build -t ${NAME_IMAGE}:${VERSION} .
    popd

    # start a temp container to copy settings file
    temp_id=$(docker run -d ${NAME_IMAGE}:${VERSION})
    mkdir -p ${PATH_PWSETTINGS_DIR}
    docker cp ${temp_id}:${PATH_DEFAULT_PWSETTINGS} ${PATH_PWSETTINGS_DIR}/${NAME_PWSETTINGS}
    docker stop ${temp_id}
    docker rm ${temp_id}

    # start running container
    docker run -d --restart=always --name ${NAME_CONTAINER} -p ${port}:${PORT_SERVER}/udp -v ${PATH_PWSETTINGS_DIR}/${NAME_PWSETTINGS}:${PATH_RUNNING_PWSETTINGS_DIR}/${NAME_PWSETTINGS} ${NAME_IMAGE}:${VERSION}
}

#function update()
#{
#}

#function destroy()
#{
#}

case $1 in
    create)
        args=${@//create/}
        create $args
        ;;
    update)
        args=${@//update/}
        update $args
        ;;
    destroy)
        args=${@//destroy/}
        destroy $args
        ;;
    *)
        usage;;
esac
