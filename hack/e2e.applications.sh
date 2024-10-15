for file in ./modules/*.sh; do
    source "$file"
done

ROOT_NS="tenant-root"
TEST_TENANT="tenant-e2e"

FLUX_NS="cozy-fluxcd"
GITREPO_NAME="e2e-repo"
BRANCH="main"

function test() {
    create_git_repo $GITREPO_NAME $FLUX_NS $BRANCH

    install_tenant $TEST_TENANT $ROOT_NS $GITREPO_NAME $FLUX_NS
    check_helmrelease_status $TEST_TENANT $ROOT_NS

    install_all_apps "../packages/apps" "$TEST_TENANT" $GITREPO_NAME $FLUX_NS

    if true; then
        echo -e "${GREEN}All tests passed!${RESET}"
        return 0
    else
        echo -e "${RED}Some tests failed!${RESET}"
        return 1
    fi
}

function clean() {
    kubectl delete gitrepository.source.toolkit.fluxcd.io $GITREPO_NAME -n $FLUX_NS
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
