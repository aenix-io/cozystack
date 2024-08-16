# Virtual Machine

A Virtual Machine (VM) simulates computer hardware, enabling various operating systems and applications to run in an isolated environment.

## Deployment Details

The virtual machine is managed and hosted through KubeVirt, allowing you to harness the benefits of virtualization within your Kubernetes ecosystem.

- Docs: [KubeVirt User Guide](https://kubevirt.io/user-guide/)
- GitHub: [KubeVirt Repository](https://github.com/kubevirt/kubevirt)

## Parameters

### Common parameters

| Name               | Description                                                                                       | Value                               |
| ------------------ | ------------------------------------------------------------------------------------------------- | ----------------------------------- |
| `external`         | Enable external access from outside the cluster                                                   | `false`                             |
| `running`          | Determines if the virtual machine should be running                                               | `true`                              |
| `image`            | The base image for the virtual machine. Allowed values: `ubuntu`, `cirros`, `alpine` and `fedora` | `ubuntu`                            |
| `storageClass`     | StorageClass used to store the data                                                               | `replicated`                        |
| `resources.cpu`    | The number of CPU cores allocated to the virtual machine                                          | `1`                                 |
| `resources.memory` | The amount of memory allocated to the virtual machine                                             | `1024M`                             |
| `resources.disk`   | The size of the disk allocated for the virtual machine                                            | `5Gi`                               |
| `sshPwauth`        | Enable password authentication for SSH. If set to `true`, users can log in using a password       | `true`                              |
| `disableRoot`      | Disable root login via SSH. If set to `true`, root login will be disabled                         | `true`                              |
| `password`         | The default password for the virtual machine                                                      | `hackme`                            |
| `chpasswdExpire`   | Set whether the password should expire                                                            | `false`                             |
| `sshKeys`          | List of SSH public keys for authentication. Can be a single key or a list of keys                 | `["ssh-rsa ...","ssh-ed25519 ..."]` |

You can customize the exposed ports by specifying them under `service.ports` in the `values.yaml` file.

## Example `values.yaml`

```yaml
external: false
running: true
image: ubuntu
resources:
  cpu: 1
  memory: 1024M
  disk: 5Gi
sshPwauth: true
disableRoot: true
password: hackme
chpasswdExpire: false
sshKeys: 
  - YOUR_SSH_PUB_KEY_HERE
  - ANOTHER_SSH_PUB_KEY_HERE

service:
  ports:
    - name: http
      port: 80
      targetPort: 80
    - name: https
      port: 443
      targetPort: 443
```
