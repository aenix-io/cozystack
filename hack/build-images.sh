#!/usr/bin/env bash

set -o pipefail
set -e

REGISTRY=$1
NAME=$2
TYPE=$3
PUSH=$4
LOAD=$5

# an example for packages/system/capi-operator, native image and transformed one
# registry.k8s.io/capi-operator/cluster-api-operator:v0.8.1
# ghcr.io/aenix-io/cozystack/system/capi-operator/cluster-api-operator:v0.8.1

find images -mindepth 1 -maxdepth 1 -type d | \
    while read dockerfile_path; do
        image_name=$(echo $dockerfile_path | awk -F/ '{print $2}')
        tag=$(egrep -o "FROM .*$image_name.*" $dockerfile_path/Dockerfile | awk -F: '{print $NF}')
        docker buildx build $dockerfile_path \
            --provenance=false \
            --tag=$REGISTRY/$TYPE/$image_name:$tag \
            --cache-from=type=registry,ref=$REGISTRY/$TYPE/$image_name:latest \
            --cache-to=type=inline \
            --push=$PUSH \
            --load=$LOAD
    done

