# Managed NATS Service

## Parameters

### Common parameters

| Name           | Description                                                                                               | Value  |
| -------------- | --------------------------------------------------------------------------------------------------------- | ------ |
| `host`         | The hostname used to access the grafana externally (defaults to 'grafana' subdomain for the tenant host). | `""`   |
| `replicas`     | Persistent Volume size for NATS                                                                           | `2`    |
| `size`         | Persistent Volume size                                                                                    | `10Gi` |
| `storageClass` | StorageClass used to store the data                                                                       | `""`   |

