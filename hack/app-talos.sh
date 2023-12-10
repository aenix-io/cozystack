#!/bin/sh
set -e
export TALOSCONFIG=talosconfig

usage() {
  echo "Usage:"
  echo "    make <init|gen|clean|members|diff|dashboard> SERVER=https://xxx:6443 [NODE=127.0.0.1]"
  exit 1
}

if [ "$1" != clean ] && [ -z "$SERVER" ]; then
  usage
fi

patches=""
if [ -f patch.yaml ]; then
  patches="$patches --config-patch=@patch.yaml"
fi
if [ -f patch-control-plane.yaml ]; then
  patches="$patches --config-patch-control-plane=@patch-control-plane.yaml"
fi
if [ -f patch-worker.yaml ]; then
  patches="$patches --config-patch-worker=@patch-worker.yaml"
fi

nodes_control=$(echo $NODES_CONTROL | tr ' ' ,)
nodes_workers=$(echo $NODES_WORKERS | tr ' ' ,)

case "$1" in
  init)
    set -x
    talosctl gen secrets -o secrets.yaml
    sops --encrypt -i secrets.yaml || rm -f secrets.yaml
  ;;
  gen)
    name="$(basename "${PWD}")"
    set -x
    sops -d secrets.yaml | talosctl gen config "$name" "$SERVER" --with-secrets /dev/stdin --with-docs=false $patches --force
    talosctl --talosconfig talosconfig config endpoint ${ENDPOINT:-127.0.0.1}
    talosctl --talosconfig talosconfig config node $NODE
  ;;
  clean)
    set -x
    rm -f controlplane.yaml worker.yaml talosconfig kubeconfig
  ;;
  members)
    nodes=$(echo $NODES_CONTROL | tr ' ' ,)
    set -x
	  talosctl etcd members -n "$nodes"
    ;;
  diff)
    if [ -n "$nodes_control" ]; then
      (set -x; talosctl apply-config -n "$nodes_control" -f controlplane.yaml --dry-run)
    fi
    if [ -n "$nodes_workers" ]; then
      (set -x; talosctl apply-config -n "$nodes_workers" -f worker.yaml --dry-run)
    fi
    ;;
  apply)
    nodes=$(echo $NODES_CONTROL | tr ' ' ,)
    if [ -n "$nodes_control" ]; then
      (set -x; talosctl apply-config -n "$nodes_control" -f controlplane.yaml)
    fi
    nodes=$(echo $NODES_WORKERS | tr ' ' ,)
    if [ -n "$nodes_workers" ]; then
      (set -x; talosctl apply-config -n "$nodes_workers" -f worker.yaml)
    fi
    ;;
  dashboard)
    (set -x; talosctl dashboard)
    ;;
  *)
    usage
  ;;
esac
