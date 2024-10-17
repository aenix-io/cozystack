#!/bin/bash

function install_tenant (){
    local release_name="$1"
    local namespace="$2"
    local gitrepo_name="$3"
    local flux_ns="$4"
    local values_file="${5:-tenant.yaml}"

    install_helmrelease "$release_name" "$namespace" "../../packages/apps/tenant" "$gitrepo_name" "$flux_ns" "$values_file"
}
