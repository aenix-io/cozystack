#!/bin/sh
# The script reacts to changes in the number of IP addresses for master nodes, and then starts reconciliation.

get_ips() {
  kubectl get nodes -lnode-role.kubernetes.io/control-plane -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
}

reconcile() {
  kubectl apply -f namespaces.yaml
  kubectl label node -lnode-role.kubernetes.io/control-plane kube-ovn/role=master --overwrite
  
  MASTER_NODES=$(kubectl get nodes -lnode-role.kubernetes.io/control-plane -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}' | tr ' ' ',')
  MASTER_COUNT=$(echo "$MASTER_NODES" | awk -F, '{ print NF }')
  
  echo "kube-ovn:
    MASTER_NODES: \"${MASTER_NODES}\"
    replicaCount: ${MASTER_COUNT}" > kubeovn/values-runtime.yaml
  
  helmwave --log-format text up --build || exit $?
}

wait_for_new_ips() {
  OLD_MASTER_NODES="$MASTER_NODES"
  MASTER_NODES=$(get_ips | tr ' ' ',')
  if [ "$MASTER_NODES" != "$MASTER_NODES" ]; then
    return
  fi
  kubectl get nodes --watch-only=true -w -lnode-role.kubernetes.io/control-plane -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}{"\n"}' | \
    while read address; do
      if [ -n "$address" ] && ! echo ",$MASTER_NODES," | grep -q ",$address,"; then
        return
      fi
    done
}

reconcile
while wait_for_new_ips; do
  reconcile
done
