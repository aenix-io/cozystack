# Virtual Machine

A Virtual Machine (VM) simulates computer hardware, enabling various operating systems and applications to run in an isolated environment.

## Deployment Details

The virtual machine is managed and hosted through KubeVirt, allowing you to harness the benefits of virtualization within your Kubernetes ecosystem.

- Docs: https://kubevirt.io/user-guide/
- GitHub: https://github.com/kubevirt/kubevirt

## Parameters

### Common parameters

| Name               | Description                                                                                       | Value    |
| ------------------ | ------------------------------------------------------------------------------------------------- | -------- |
| `external`         | Enable external access from outside the cluster                                                   | `false`  |
| `running`          | Determines if the virtual machine should be running                                               | `true`   |
| `password`         | The default password for the virtual machine                                                      | `hackme` |
| `image`            | The base image for the virtual machine. Allowed values: `ubuntu`, `cirros`, `alpine` and `fedora` | `ubuntu` |
| `disk`             | The size of the disk allocated for the virtual machine                                            | `5Gi`    |
| `resources.cpu`    | The number of CPU cores allocated to the virtual machine                                          | `1`      |
| `resources.memory` | The amount of memory allocated to the virtual machine                                             | `1024M`  |
