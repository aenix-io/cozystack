#!/bin/sh
set -e

if [ -e $1 ]; then
  echo "Please pass version in the first argument"
  echo "Example: $0 v0.0.2"
  exit 1
fi

version=$1
talos_version=$(awk '/^version:/ {print $2}' packages/core/installer/images/talos/profiles/installer.yaml)

set -x

sed -i "s|\(ghcr.io/aenix-io/cozystack/matchbox:\)v[^ ]\+|\1${talos_version}|g" README.md
sed -i "s|\(ghcr.io/aenix-io/cozystack/talos:\)v[^ ]\+|\1${talos_version}|g" README.md

sed -i "/^TAG / s|=.*|= ${version}|" \
  packages/apps/http-cache/Makefile \
  packages/apps/kubernetes/Makefile \
  packages/core/installer/Makefile \
  packages/system/dashboard/Makefile
