#!/bin/bash

######################################################################################
#
# The objective of this script is to:
# 1) make the docker run command easier to use.
# 2) run ansible-galaxy install if required roles are missing.
# 3) print ASCII art.
# 
# Please do not introduce any other logic
# 
######################################################################################
set -e

function printBanner(){
    # fpr info on colors, see https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
    LIGHT_BLUE='\033[1;34m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    WHITE='\033[1;37m'
    NC='\033[0m'

    printf "
    ${RED} _          _          ${LIGHT_BLUE}  ____ ___ ${WHITE}    __${GREEN} ____ ____   \n\
    ${RED}| |    __ _| |__  ___  ${LIGHT_BLUE} / ___|_ _|${WHITE}   / /${GREEN}/ ___|  _ \  \n\
    ${RED}| |   / _' | '  \/ __| ${LIGHT_BLUE}| |    | | ${WHITE}  / /${GREEN}| |   | | | | \n\
    ${RED}| |__| (_| | |_) \__ \ ${LIGHT_BLUE}| |___ | | ${WHITE} / / ${GREEN}| |___| |_| | \n\
    ${RED}|_____\__,_|_.__/|___/ ${LIGHT_BLUE} \____|___|${WHITE}/_/  ${GREEN} \____|____/  \n\
    \n\n${NC}"
}

function executeDocker(){
    docker run --rm -i \
        -v $(pwd):/tmp/src:z \
        -v $HOME/.kube:/root/.kube:z \
        -w "/tmp/src" \
        -t redhatcop/openshift-applier \
        $DOCKER_RUN_COMMAND
}

###########################
# Begin Script            #
###########################
printBanner

ansible-galaxy install -r requirements.yml --roles-path=roles

if [[ "$#" == 0 ]]; then
    printf "\n%s No arguments passed to run.sh!!! You have two options:" '-'
    printf "\n\n\t1) Specify the target you want to run, such as:"
    printf "\n\t\t./run.sh bootstrap"
    printf "\n\t2) Specify a complete ansible command, such as:"
    printf "\n\t\t./run.sh ansible-playbook -i inventory apply.yml -e target=tools -e filter_tags=nexus\n\n"
elif [[ "$#" == 1 ]]; then
    DOCKER_RUN_COMMAND="ansible-playbook -i inventory apply.yml -e target=$@"
    printf "\n%s %s$DOCKER_RUN_COMMAND%s \n\n" '-'
    executeDocker
else
    DOCKER_RUN_COMMAND="$@"
    printf "\n%s %s$DOCKER_RUN_COMMAND%s \n\n" '-'
    executeDocker
fi