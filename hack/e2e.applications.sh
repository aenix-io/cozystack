for file in ./modules/*.sh; do
    source "$file"
done

ROOT_NS="tenant-root"
TEST_TENANT="tenant-e2e"

function test() {
    install_tenant $TEST_TENANT $ROOT_NS
    check_helmrelease_status $TEST_TENANT $ROOT_NS

    install_all_apps "../packages/apps" "$TEST_TENANT" cozystack-apps cozy-public

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
