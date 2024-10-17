#!/bin/bash

source ./modules/colors.sh

function install_helmrelease() {
    local release_name="$1"
    local namespace="$2"
    local chart_path="$3"
    local gitrepo_name="$4"
    local flux_ns="$5"
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
        echo "        kind: GitRepository"
        echo "        name: \"$gitrepo_name\""
        echo "        namespace: \"$flux_ns\""
        echo "      version: '*'"
        echo "  interval: 1m0s"
        echo "  timeout: 5m0s"

        if [[ -n "$values_file" && -f "$values_file" ]]; then
            echo "  values:"
            cat "$values_file" | sed 's/^/    /'
        fi
    } > "$helmrelease_file"

    kubectl apply -f "$helmrelease_file"

    rm -f "$helmrelease_file"
}
