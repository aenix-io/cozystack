# Piraeus Operator

Deploys the [Piraeus Operator](https://github.com/piraeusdatastore/piraeus-operator) which deploys and manages a simple
and resilient storage solution for Kubernetes.

The main deployment method for Piraeus Operator switched to [`kustomize`](../../docs/tutorial)
in release `v2.0.0`. This chart is intended for users who want to continue using Helm.

This chart **only** configures the Operator, but does not create the `LinstorCluster` resource creating the actual
storage system. Refer to the existing [tutorials](../../docs/tutorial)
and [how-to guides](../../docs/how-to).

## Deploying Piraeus Operator

To deploy Piraeus Operator with Helm, clone this repository and deploy the chart:

```
$ git clone --branch v2 https://github.com/piraeusdatastore/piraeus-operator
$ cd piraeus-operator
$ helm install piraeus-operator charts/piraeus-operator --create-namespace -n piraeus-datastore
```

Follow the instructions printed by Helm to create your storage cluster:

```
$ kubectl apply -f - <<EOF
apiVersion: piraeus.io/v1
kind: LinstorCluster
metadata:
  name: linstorcluster
spec: {}
EOF
```

Check out our [documentation](../../docs) for more information.
