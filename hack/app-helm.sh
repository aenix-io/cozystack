#!/bin/sh
set -e

ensure_namespace() {
  if ! nsSecLabel=$(kubectl get "namespace/$namespace" -o jsonpath="{ .metadata.labels['pod-security\.kubernetes\.io/enforce'] }"); then
    if [ "$createNamespace" = true ]; then
    (set -x; kubectl create namespace "$namespace")
    fi
  fi
  if [ "$nsSecLabel" != privileged ] && [ "$privilegedNamespace" = true ]; then
    (set -x; kubectl label namespace "$namespace" pod-security.kubernetes.io/enforce=privileged --overwrite)
  fi
  if [ "$nsSecLabel" = privileged ] && [ "$privilegedNamespace" != true ]; then
    (set -x; kubectl label namespace "$namespace" pod-security.kubernetes.io/enforce- --overwrite)
  fi
}

ensure_crds() {
  if [ "$crdsPolicy" != "CreateReplace" ]; then
    return
  fi
  crds=$(mktemp)
  "$0" show | yq e "select(.kind|downcase == \"customresourcedefinition\")
  | .metadata.annotations.\"meta.helm.sh/release-name\"=\"$name\"
  | .metadata.annotations.\"meta.helm.sh/release-namespace\"=\"$namespace\"
  | .metadata.labels.\"app.kubernetes.io/managed-by\"=\"Helm\"
  " > "$crds"
  # We use kubectl create+replace instead of apply to avoid having last-applied configuration
  if [ -s "$crds" ]; then
    if [ "$crdsPolicy" = "CreateReplace" ]; then
      (set -x; kubectl apply --server-side -f "$crds" --force-conflicts)
    fi
  fi
  rm -f "$crds"
}

name=$(yq eval-all '[._helm.name].0' values.yaml)
namespace=$(yq eval-all '[._helm.namespace].0' values.yaml)
createNamespace=$(yq eval-all '[._helm.createNamespace].0' values.yaml)
privilegedNamespace=$(yq eval-all '[._helm.privilegedNamespace].0' values.yaml)
crdsPolicy=$(yq eval-all '[._helm.crds].0' values.yaml)
case null in
  $name|$namespace)
    echo "$envFile has no '_helm.name' or '_helm.namespace' fields" >&2
    exit 1
  ;;
esac

case "$1" in
  show)
    set -x
    helm template "$name" -n "$namespace" . --include-crds
  ;;
  diff)
    set -x
    helm diff upgrade --allow-unreleased "$name" -n "$namespace" . --show-secrets
  ;;
  apply)
    ensure_namespace
    ensure_crds
    crdflag=
    if [ "$crdsPolicy" != "Create" ]; then
      crdflag=--skip-crds
    fi
    (set -x; helm upgrade -i "$name" -n "$namespace" . $crdflag)
  ;;
  delete)
    (set -x; helm uninstall "$name" -n "$namespace")
  ;;
  *)
    echo "Command "$1" is not implented!" >&2
    exit 1
  ;;
esac
