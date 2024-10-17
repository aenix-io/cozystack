#!/bin/bash

function create_git_repo() {
    local repo_name="$1"
    local namespace="$2"
    local branch="$3"

    if [[ -z "$repo_name" || -z "$namespace" || -z "$branch" ]]; then
        echo "Usage: create_git_repo <repo_name> <namespace> <branch>"
        return 1
    fi

    local gitrepo_file=$(mktemp /tmp/GitRepository.XXXXXX.yaml)
    {
        echo "apiVersion: source.toolkit.fluxcd.io/v1"
        echo "kind: GitRepository"
        echo "metadata:"
        echo "  name: \"$repo_name\""
        echo "  namespace: \"$namespace\""
        echo "spec:"
        echo "  interval: 1m"
        echo "  url: https://github.com/aenix-io/cozystack"
        echo "  ref:"
        echo "    branch: \"$branch\""
        echo "  ignore: |"
        echo "    !/packages/apps/ "

    } > "$gitrepo_file"

    kubectl apply -f "$gitrepo_file"

    rm -f "$gitrepo_file"
}
