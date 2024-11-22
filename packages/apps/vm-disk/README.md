# Virtual Machine Disk

A Virtual Machine Disk

## Parameters

### Common parameters

| Name           | Description                                            | Value        |
| -------------- | ------------------------------------------------------ | ------------ |
| `source`       | The source image location used to create a disk        | `{}`         |
| `optical`      | Defines is disk should be considered as optical        | `false`      |
| `storage`      | The size of the disk allocated for the virtual machine | `5Gi`        |
| `storageClass` | StorageClass used to store the data                    | `replicated` |
