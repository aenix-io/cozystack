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
