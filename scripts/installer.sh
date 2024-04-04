#!/bin/sh
VERSION=2
set -o pipefail
set -e

run_migrations() {
  if ! kubectl get configmap -n cozy-system cozystack-version; then
    kubectl create configmap -n cozy-system cozystack-version --from-literal=version="$VERSION" --dry-run=client -o yaml | kubectl create -f-
  fi
  current_version=$(kubectl get configmap -n cozy-system cozystack-version -o jsonpath='{.data.version}') || true
  until [ "$current_version" = "$VERSION" ]; do
    echo "run migration: $current_version --> $VERSION"
    scripts/migrations/$current_version
    current_version=$(kubectl get configmap -n cozy-system cozystack-version -o jsonpath='{.data.version}')
  done
}

flux_is_ok() {
  kubectl wait --for=condition=available -n cozy-fluxcd deploy/source-controller deploy/helm-controller --timeout=10s 
}

install_basic_charts() {
  bundle=$(kubectl get configmap -n cozy-system cozystack -o 'go-template={{index .data "bundle-name"}}')
  if [ "$bundle" = "full-paas" ] || [ "$bundle" = "full-distro" ]; then
  make -C packages/system/cilium apply
  fi
  if [ "$bundle" = "full-paas" ]; then
    make -C packages/system/kubeovn apply
  fi
}

cd "$(dirname "$0")/.."

# Run migrations
run_migrations

# Install namespaces
make -C packages/core/platform namespaces-apply

# Install fluxcd
make -C packages/core/fluxcd apply

# Reconcile Helm repositories
kubectl annotate helmrepositories.source.toolkit.fluxcd.io -A -l cozystack.io/repository reconcile.fluxcd.io/requestedAt=$(date +"%Y-%m-%dT%H:%M:%SZ") --overwrite

# Install platform chart
make -C packages/core/platform apply

# Install basic system charts (should be after platform chart applied)
if ! flux_is_ok; then
  install_basic_charts
fi

# Reconcile platform chart
trap 'exit' INT TERM
while true; do
  sleep 60 & wait
  make -C packages/core/platform apply
done
