#!/bin/sh
set -o pipefail
set -e

run_migrations() {
  return 0
}

flux_is_ok() {
  kubectl wait --for=condition=available -n cozy-fluxcd deploy/source-controller deploy/helm-controller --timeout=10s 
}


install_core_charts() {
  make -C /cozystack/packages/core/namespaces apply
  make -C /cozystack/packages/core/cilium apply
  make -C /cozystack/packages/core/kubeovn apply
  make -C /cozystack/packages/core/fluxcd apply
}

if ! flux_is_ok; then
  install_core_charts
fi

run_migrations
make -C /cozystack/packages/core/fluxcd-releases apply

tail -f /dev/null &
wait
