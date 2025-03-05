#!/bin/bash
set -e

terminate() {
  echo "Caught signal, terminating"
  exit 0
}

trap terminate SIGINT SIGTERM

echo "Running Linstor per-satellite plunger:"
cat "${0}"

while true; do
  # timeout at the start of the loop to give a chance for the fresh linstor-satellite instance to cleanup itself
  sleep 1m

  # Detect orphaned loop devices and detach them
  # the `/` path could not be a backing file for a loop device, so it's a good indicator of a stuck loop device
  # TODO describe the issue in more detail
  losetup --json \
  | jq -r '.[][] | select(."back-file" == "/ (deleted)") | "losetup --detach \(.name)"' \
  | sh -x
done
