# Managed Kubernetes Service

## Overview

The Managed Kubernetes Service offers a streamlined solution for efficiently managing server workloads. Kubernetes has emerged as the industry standard, providing a unified and accessible API, primarily utilizing YAML for configuration. This means that teams can easily understand and work with Kubernetes, streamlining infrastructure management.

The Kubernetes leverages robust software design patterns, enabling continuous recovery in any scenario through the reconciliation method. Additionally, it ensures seamless scaling across a multitude of servers, addressing the challenges posed by complex and outdated APIs found in traditional virtualization platforms. This managed service eliminates the need for developing custom solutions or modifying source code, saving valuable time and effort.

## Deployment Details

The managed Kubernetes service deploys a standard Kubernetes cluster utilizing the Cluster API, Kamaji as control-plane provicer and the KubeVirt infrastructure provider. This ensures a consistent and reliable setup for workloads.

Within this cluster, users can take advantage of LoadBalancer services and easily provision physical volumes as needed. The control-plane operates within containers, while the worker nodes are deployed as virtual machines, all seamlessly managed by the application.

- Docs: https://github.com/clastix/kamaji
- Docs: https://cluster-api.sigs.k8s.io/
- GitHub: https://github.com/clastix/kamaji
- GitHub: https://github.com/kubernetes-sigs/cluster-api-provider-kubevirt
- GitHub: https://github.com/kubevirt/csi-driver


## How-Tos

How to access to deployed cluster:

```
kubectl get secret -n <namespace> kubernetes-<clusterName>-admin-kubeconfig -o go-template='{{ printf "%s\n" (index .data "super-admin.conf" | base64decode) }}' > test
```

## Parameters

### Common parameters

| Name                    | Description                                                                                                                            | Value        |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| `host`                  | The hostname used to access the Kubernetes cluster externally (defaults to using the cluster name as a subdomain for the tenant host). | `""`         |
| `controlPlane.replicas` | Number of replicas for Kubernetes contorl-plane components                                                                             | `2`          |
| `storageClass`          | StorageClass used to store user data                                                                                                   | `replicated` |
| `nodeGroups`            | nodeGroups configuration                                                                                                               | `{}`         |

### Cluster Addons

| Name                                 | Description                                                                        | Value   |
| ------------------------------------ | ---------------------------------------------------------------------------------- | ------- |
| `addons.certManager.enabled`         | Enables the cert-manager                                                           | `false` |
| `addons.certManager.valuesOverride`  | Custom values to override                                                          | `{}`    |
| `addons.ingressNginx.enabled`        | Enable Ingress-NGINX controller (expect nodes with 'ingress-nginx' role)           | `false` |
| `addons.ingressNginx.valuesOverride` | Custom values to override                                                          | `{}`    |
| `addons.ingressNginx.hosts`          | List of domain names that should be passed through to the cluster by upper cluster | `[]`    |
| `addons.fluxcd.enabled`              | Enables Flux CD                                                                    | `false` |
| `addons.fluxcd.valuesOverride`       | Custom values to override                                                          | `{}`    |

