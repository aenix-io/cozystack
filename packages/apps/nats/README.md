# Managed NATS Service

## Parameters

### Common parameters

| Name           | Description                                     | Value   |
| -------------- | ----------------------------------------------- | ------- |
| `external`     | Enable external access from outside the cluster | `false` |
| `replicas`     | Persistent Volume size for NATS                 | `2`     |
| `storageClass` | StorageClass used to store the data             | `""`    |

### Configuration parameters

| Name        | Description             | Value |
| ----------- | ----------------------- | ----- |
| `users`     | Users configuration     | `{}`  |
