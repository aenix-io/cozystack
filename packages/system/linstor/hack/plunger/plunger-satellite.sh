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

  echo "noop"
done
