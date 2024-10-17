#!/bin/bash

source ./modules/colors.sh

function check_helmrelease_status() {
    local release_name="$1"
    local namespace="$2"
    local timeout=300  # Timeout in seconds
    local interval=5   # Interval between checks in seconds
    local elapsed=0

    while [[ $elapsed -lt $timeout ]]; do
        local status_output
        status_output=$(kubectl get helmrelease "$release_name" -n "$namespace" -o json | jq -r '.status.conditions[-1].reason')

        if [[ "$status_output" == "InstallSucceeded" ]]; then
            echo -e "${GREEN}Helm release '$release_name' is ready.${RESET}"
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
