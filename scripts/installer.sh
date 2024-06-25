#!/bin/sh
set -o pipefail
set -e

BUNDLE=$(set -x; kubectl get configmap -n cozy-system cozystack -o 'go-template={{index .data "bundle-name"}}')
VERSION=5

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
  kubectl wait --for=condition=available -n cozy-fluxcd deploy/fluxcd-flux-operator --timeout=10s
}

flux_controllers_ok() {
  if timeout 60 sh -c 'until kubectl get -n cozy-fluxcd deploy/source-controller deploy/helm-controller; do sleep 1; done'; then
    kubectl wait --for=condition=available -n cozy-fluxcd deploy/source-controller deploy/helm-controller --timeout=10s 
  fi
}

flux_crds_ok() {
  timeout 60 sh -c 'until kubectl get crd helmrepositories.source.toolkit.fluxcd.io helmcharts.source.toolkit.fluxcd.io; do sleep 1; done'
}

install_basic_charts() {
  if [ "$BUNDLE" = "paas-full" ] || [ "$BUNDLE" = "distro-full" ]; then
  make -C packages/system/cilium apply resume
  fi
  if [ "$BUNDLE" = "paas-full" ]; then
    make -C packages/system/kubeovn apply resume
  fi
  make -C packages/system/fluxcd apply
}

cd "$(dirname "$0")/.."

# Run migrations
run_migrations

# Install namespaces
make -C packages/core/platform namespaces-apply

# Install fluxcd-operator
if ! flux_operator_is_ok; then
  make -C packages/system/fluxcd-operator apply-locally
fi

# Wait for CRDs
if ! flux_crds_ok; then
  echo "Flux CRDs are not ready" >&2
  exit 1
fi

# Install platform chart
make -C packages/core/platform apply

# Reconcile Helm repositories
kubectl annotate helmrepositories.source.toolkit.fluxcd.io -A -l cozystack.io/repository reconcile.fluxcd.io/requestedAt=$(date +"%Y-%m-%dT%H:%M:%SZ") --overwrite

# Reconcile platform chart
trap 'exit' INT TERM
while true; do
  sleep 60 & wait
  make -C packages/core/platform apply
done
