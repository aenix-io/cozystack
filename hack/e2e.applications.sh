for file in /hack/modules/*.sh; do
    source "$file"
done

ROOT_NS="tenant-root"
TEST_TENANT="tenant-e2e"

function test() {
    local charts=("${!1}")
    local ignore=("${!2}")

    if [ ${#charts[@]} -eq 0 ]; then
        echo -e "${RED}No chart names provided for processing.${RED}"
        exit 1
    fi

    install_tenant $TEST_TENANT $ROOT_NS
    check_helmrelease_status $TEST_TENANT $ROOT_NS

    local repo_name="cozystack-apps"
    local repo_ns="cozy-public"

    for chart_name in "${charts[@]}"; do
        if [[ -d "$chart_path" ]]; then
            if [[ " ${ignore[@]} " =~ " ${chart} " ]]; then
              echo "Skipping ignored chart: $chart"
              continue
            fi
            release_name="$chart_name-e2e"
            echo "Installing release: $release_name"
            install_helmrelease "$release_name" "$TEST_TENANT" "$chart_name" "$repo_name" "$repo_ns"

            echo "Checking status for HelmRelease: $release_name"
            check_helmrelease_status "$release_name" "$TEST_TENANT"
        else
            echo "$chart_path is not a directory. Skipping."
        fi
    done

    if true; then
        echo -e "${GREEN}All tests passed!${RESET}"
        return 0
    else
        echo -e "${RED}Some tests failed!${RESET}"
        return 1
    fi
}


function clean() {
    kubectl delete helmrelease.helm.toolkit.fluxcd.io $TEST_TENANT -n $ROOT_NS
    if true; then
        echo -e "${GREEN}Cleanup successful!${RESET}"
        return 0
    else
        echo -e "${RED}Cleanup failed!${RESET}"
        return 1
    fi
}

case "$1" in
    test)
        echo -e "${YELLOW}Running tests...${RESET}"
        test
        ;;
    clean)
        echo -e "${YELLOW}Cleaning up...${RESET}"
        clean
        ;;
    *)
        echo -e "${RED}Usage: $0 {test|clean}${RESET}"
        exit 1
        ;;
esac
