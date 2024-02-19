#!/bin/sh
set -o pipefail
set -e

run_migrations() {
  return 0
}

flux_is_ok() {
  kubectl wait --for=condition=available -n cozy-fluxcd deploy/source-controller deploy/helm-controller --timeout=10s 
}

install_basic_charts() {
  make -C packages/system/cilium apply
  make -C packages/system/kubeovn apply
  make -C packages/system/fluxcd apply
}

cd "$(dirname "$0")/.."

# Install namespaces
make -C packages/core/platform namespaces-apply

# Install basic system charts
if ! flux_is_ok; then
  install_basic_charts
fi

# Run migrations
run_migrations

# Reconcile Helm repositories
kubectl annotate helmrepositories.source.toolkit.fluxcd.io -A -l cozystack.io/repository reconcile.fluxcd.io/requestedAt=$(date +"%Y-%m-%dT%H:%M:%SZ") --overwrite

# Install platform chart
make -C packages/core/platform apply

# Reconcile platform chart
trap 'exit' INT TERM
while true; do
  sleep 60 & wait
  make -C packages/core/platform apply
done
