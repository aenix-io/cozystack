#!/bin/bash

function install_tenant (){
    local release_name="$1"
    local namespace="$2"
    local values_file="${3:-tenant.yaml}"
    local repo_name="cozystack-apps"
    local repo_ns="cozy-public"

    install_helmrelease "$release_name" "$namespace" "tenant" "$repo_name" "$repo_ns" "$values_file"
}
