#!/bin/sh
set -e

if [ -e $1 ]; then
  echo "Please pass version in the first argument"
  echo "Example: $0 0.2.0"
  exit 1
fi

version=$1
talos_version=$(awk '/^version:/ {print $2}' packages/core/installer/images/talos/profiles/installer.yaml)

set -x

sed -i "/^TAG / s|=.*|= v${version}|" \
  packages/apps/http-cache/Makefile \
  packages/apps/kubernetes/Makefile \
  packages/core/installer/Makefile \
  packages/system/dashboard/Makefile

sed -i "/^VERSION / s|=.*|= ${version}|" \
  packages/core/Makefile \
  packages/system/Makefile
make -C packages/core fix-chartnames
make -C packages/system fix-chartnames
