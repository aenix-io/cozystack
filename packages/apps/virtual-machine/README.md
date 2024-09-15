# Virtual Machine

A Virtual Machine (VM) simulates computer hardware, enabling various operating systems and applications to run in an isolated environment.

## Deployment Details

The virtual machine is managed and hosted through KubeVirt, allowing you to harness the benefits of virtualization within your Kubernetes ecosystem.

- Docs: [KubeVirt User Guide](https://kubevirt.io/user-guide/)
- GitHub: [KubeVirt Repository](https://github.com/kubevirt/kubevirt)

## Accessing virtual machine

You can access the virtual machine using the virtctl tool:
- [KubeVirt User Guide - Virtctl Client Tool](https://kubevirt.io/user-guide/user_workloads/virtctl_client_tool/)

To access the serial console:

```
virtctl console <vm>
```

To access the VM using VNC:

```
virtctl vnc <vm>
```

To SSH into the VM:

```
virtctl ssh <user>@<vm>
```

## Parameters

### Common parameters

| Name               | Description                                                                                                | Value            |
| ------------------ | ---------------------------------------------------------------------------------------------------------- | ---------------- |
| `external`         | Enable external access from outside the cluster                                                            | `false`          |
| `externalPorts`    | Specify ports to forward from outside the cluster                                                          | `[]`             |
| `running`          | Determines if the virtual machine should be running                                                        | `true`           |
| `image`            | The base image for the virtual machine. Allowed values: `ubuntu`, `cirros`, `alpine`, `fedora` and `talos` | `ubuntu`         |
| `storageClass`     | StorageClass used to store the data                                                                        | `replicated`     |
| `resources.cpu`    | The number of CPU cores allocated to the virtual machine                                                   | `1`              |
| `resources.memory` | The amount of memory allocated to the virtual machine                                                      | `1024M`          |
| `resources.disk`   | The size of the disk allocated for the virtual machine                                                     | `5Gi`            |
| `sshKeys`          | List of SSH public keys for authentication. Can be a single key or a list of keys.                         | `[]`             |
| `cloudInit`        | cloud-init user data config. See cloud-init documentation for more details.                                | `#cloud-config
` |

You can customize the exposed ports by specifying them under `service.ports` in the `values.yaml` file.

## Example virtual machine:

```yaml
running: true
image: fedora
storageClass: replicated
resources:
  cpu: 1
  memory: 1024M
  disk: 10Gi

sshKeys:
- ssh-rsa ...

cloudInit: |
  #cloud-config
  user: fedora
  password: fedora
  chpasswd: { expire: False }
  ssh_pwauth: True
```
