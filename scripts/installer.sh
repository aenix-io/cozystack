#!/bin/sh
set -o pipefail
set -e

BUNDLE=$(set -x; kubectl get configmap -n cozy-system cozystack -o 'go-template={{index .data "bundle-name"}}')
VERSION=4

run_migrations() {
  if ! kubectl get configmap -n cozy-system cozystack-version; then
    kubectl create configmap -n cozy-system cozystack-version --from-literal=version="$VERSION" --dry-run=client -o yaml | kubectl create -f-
    return
  fi
  current_version=$(kubectl get configmap -n cozy-system cozystack-version -o jsonpath='{.data.version}') || true
  until [ "$current_version" = "$VERSION" ]; do
    echo "run migration: $current_version --> $VERSION"
    scripts/migrations/$current_version
    current_version=$(kubectl get configmap -n cozy-system cozystack-version -o jsonpath='{.data.version}')
  done
}


flux_operator_is_ok() {
  kubectl wait --for=condition=available -n cozy-fluxcd deploy/fluxcd-flux-operator --timeout=1m
}

flux_instance_is_ok() {
  kubectl wait --for=condition=ready -n cozy-fluxcd fluxinstance/flux --timeout=5m
}

flux_controllers_ok() {
  kubectl wait --for=condition=available -n cozy-fluxcd deploy/source-controller deploy/helm-controller --timeout=10s 
}

install_basic_charts() {
  if [ "$BUNDLE" = "paas-full" ] || [ "$BUNDLE" = "distro-full" ]; then
  make -C packages/system/cilium apply resume
  fi
  if [ "$BUNDLE" = "paas-full" ]; then
    make -C packages/system/kubeovn apply resume
  fi
}

cd "$(dirname "$0")/.."

# Run migrations
run_migrations

# Install namespaces
make -C packages/core/platform namespaces-apply

# Install fluxcd
make -C packages/core/fluxcd apply

if flux_operator_is_ok; then
  echo "Flux operator is installed and Flux CRD is ready"
fi

# Install platform chart
make -C packages/core/platform apply

# We should check flux_instance_is_ok, somewhere, but not yet... it won't be ready now

# Install basic system charts (should be after platform chart applied)
if ! flux_controllers_ok; then
  install_basic_charts
fi

# Reconcile Helm repositories
kubectl annotate helmrepositories.source.toolkit.fluxcd.io -A -l cozystack.io/repository reconcile.fluxcd.io/requestedAt=$(date +"%Y-%m-%dT%H:%M:%SZ") --overwrite

# At this point I sure hope flux_instance_is_ok ( 😅 )

# Reconcile platform chart
trap 'exit' INT TERM
while true; do
  sleep 60 & wait
  make -C packages/core/platform apply
done
