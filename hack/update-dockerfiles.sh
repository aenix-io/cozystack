#!/usr/bin/env bash

set -o pipefail
set -e

function update_dockerfile() {
    local image=$1
    local image_name=$(echo $image | awk -F/ '{print $NF}' | awk -F: '{print $1}')

    [[ -z $image_name ]] && { echo "image_name is empty for image: $image">&2; exit 1; }
    mkdir -p images/$image_name
    if [[ ! -f images/$image_name/Dockerfile ]];
        then
            echo "FROM $image" > images/$image_name/Dockerfile
        else
            sed -i "s|FROM .*$image_name.*|FROM $image|" images/$image_name/Dockerfile
        fi
}


function with_helm() {
    helm template . | awk '/^[ \t"-]*image["]*: [a-zA-Z0-9/:@"\.-]+$/{print $NF}' | sed 's/"//g' | \
        while read image; do
            update_dockerfile $image
        done
}

function with_grep() {
}

[[ -z $1 ]] && with_helm || $1

