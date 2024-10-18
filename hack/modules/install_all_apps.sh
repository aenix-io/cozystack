#!/bin/bash

source ./modules/colors.sh

# Function to load ignored charts from a file
function load_ignored_charts() {
    local ignore_file="$1"
    local ignored_charts=()

    if [[ -f "$ignore_file" ]]; then
        while IFS= read -r chart; do
            ignored_charts+=("$chart")
        done < "$ignore_file"
    else
        echo "Ignore file not found: $ignore_file"
    fi

    # Return the array of ignored charts
    echo "${ignored_charts[@]}"
}

# Function to check if a chart is in the ignored list
function is_chart_ignored() {
    local chart_name="$1"
    shift
    local ignored_charts=("$@")

    for ignored_chart in "${ignored_charts[@]}"; do
        if [[ "$ignored_chart" == "$chart_name" ]]; then
            return 0
        fi
    done
    return 1
}

function install_all_apps() {
    local charts_dir="$1"
    local namespace="$2"
    local repo_name="$3"
    local repo_ns="$4"

    local ignore_file="./modules/ignored_charts"
    local ignored_charts
    ignored_charts=($(load_ignored_charts "$ignore_file"))

    for chart_path in "$charts_dir"/*; do
        if [[ -d "$chart_path" ]]; then
            local chart_name
            chart_name=$(basename "$chart_path")
            # Check if the chart is in the ignored list
            if is_chart_ignored "$chart_name" "${ignored_charts[@]}"; then
                echo "Skipping chart: $chart_name (listed in ignored charts)"
                continue
            fi

            release_name="$chart_name-e2e"
            echo "Installing release: $release_name"
            install_helmrelease "$release_name" "$namespace" "$chart_name" "$repo_name" "$repo_ns"

            echo "Checking status for HelmRelease: $release_name"
            check_helmrelease_status "$release_name" "$namespace"
        else
            echo "$chart_path is not a directory. Skipping."
        fi
    done
}
