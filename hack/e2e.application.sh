#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'
YELLOW='\033[0;33m'


ROOT_NS="tenant-root"
TEST_TENANT="tenant-e2e"

values_base_path="/hack/testdata/"
checks_base_path="/hack/testdata/"

function delete_hr() {
    local release_name="$1"
    local namespace="$2"

    if [[ -z "$release_name" ]]; then
        echo -e "${RED}Error: Release name is required.${RESET}"
        exit 1
    fi

    if [[ -z "$namespace" ]]; then
        echo -e "${RED}Error: Namespace name is required.${RESET}"
        exit 1
    fi

    if [[ "$release_name" == "tenant-e2e" ]]; then
        echo -e "${YELLOW}Skipping deletion for release tenant-e2e.${RESET}"
        return 0
    fi

    kubectl delete helmrelease $release_name -n $namespace
}

function install_helmrelease() {
    local release_name="$1"
    local namespace="$2"
    local chart_path="$3"
    local repo_name="$4"
    local repo_ns="$5"
    local values_file="$6"

    if [[ -z "$release_name" ]]; then
        echo -e "${RED}Error: Release name is required.${RESET}"
        exit 1
    fi

    if [[ -z "$namespace" ]]; then
        echo -e "${RED}Error: Namespace name is required.${RESET}"
        exit 1
    fi

    if [[ -z "$chart_path" ]]; then
        echo -e "${RED}Error: Chart path name is required.${RESET}"
        exit 1
    fi

    if [[ -n "$values_file" && -f "$values_file" ]]; then
        local values_section
        values_section=$(echo "  values:" && sed 's/^/    /' "$values_file")
    fi

    local helmrelease_file=$(mktemp /tmp/HelmRelease.XXXXXX.yaml)
    {
        echo "apiVersion: helm.toolkit.fluxcd.io/v2"
        echo "kind: HelmRelease"
        echo "metadata:"
        echo "  labels:"
        echo "    cozystack.io/ui: \"true\""
        echo "  name: \"$release_name\""
        echo "  namespace: \"$namespace\""
        echo "spec:"
        echo "  chart:"
        echo "    spec:"
        echo "      chart: \"$chart_path\""
        echo "      reconcileStrategy: Revision"
        echo "      sourceRef:"
        echo "        kind: HelmRepository"
        echo "        name: \"$repo_name\""
        echo "        namespace: \"$repo_ns\""
        echo "      version: '*'"
        echo "  interval: 1m0s"
        echo "  timeout: 5m0s"
        [[ -n "$values_section" ]] && echo "$values_section"
    } > "$helmrelease_file"

    kubectl apply -f "$helmrelease_file"

    rm -f "$helmrelease_file"
}

function install_tenant (){
    local release_name="$1"
    local namespace="$2"
    local values_file="${values_base_path}tenant/values.yaml"
    local repo_name="cozystack-apps"
    local repo_ns="cozy-public"
    install_helmrelease "$release_name" "$namespace" "tenant" "$repo_name" "$repo_ns" "$values_file"
}

function make_extra_checks(){
    local checks_file="$1"
    echo "after exec make $checks_file"
    if [[ -n "$checks_file" && -f "$checks_file" ]]; then
        echo -e "${YELLOW}Start extra checks with file: ${checks_file}${RESET}"

    fi
}

function check_helmrelease_status() {
    local release_name="$1"
    local namespace="$2"
    local checks_file="$3"
    local timeout=300  # Timeout in seconds
    local interval=5   # Interval between checks in seconds
    local elapsed=0


    while [[ $elapsed -lt $timeout ]]; do
        local status_output
        status_output=$(kubectl get helmrelease "$release_name" -n "$namespace" -o json | jq -r '.status.conditions[-1].reason')

        if [[ "$status_output" == "InstallSucceeded" || "$status_output" == "UpgradeSucceeded" ]]; then
            echo -e "${GREEN}Helm release '$release_name' is ready.${RESET}"
            make_extra_checks "$checks_file"
            delete_hr $release_name $namespace
            return 0
        elif [[ "$status_output" == "InstallFailed" ]]; then
          echo -e "${RED}Helm release '$release_name': InstallFailed${RESET}"
          exit 1
        else
            echo -e "${YELLOW}Helm release '$release_name' is not ready. Current status: $status_output${RESET}"
        fi

        sleep "$interval"
        elapsed=$((elapsed + interval))
    done

    echo -e "${RED}Timeout reached. Helm release '$release_name' is still not ready after $timeout seconds.${RESET}"
    exit 1
}

chart_name="$1"

if [ -z "$chart_name" ]; then
    echo -e "${RED}No chart name provided. Exiting...${RESET}"
    exit 1
fi


checks_file="${checks_base_path}${chart_name}/check.sh"
repo_name="cozystack-apps"
repo_ns="cozy-public"
release_name="$chart_name-e2e"
values_file="${values_base_path}${chart_name}/values.yaml"

install_tenant $TEST_TENANT $ROOT_NS
check_helmrelease_status $TEST_TENANT $ROOT_NS "${checks_base_path}tenant/check.sh"

echo -e "${YELLOW}Running tests for chart: $chart_name${RESET}"

install_helmrelease $release_name $TEST_TENANT $chart_name $repo_name $repo_ns $values_file
check_helmrelease_status $release_name $TEST_TENANT $checks_file
