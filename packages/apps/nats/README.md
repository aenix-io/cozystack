# Managed NATS Service

## Parameters

### Common parameters

| Name                | Description                                        | Value   |
| ------------------- | -------------------------------------------------- | ------- |
| `external`          | Enable external access from outside the cluster    | `false` |
| `replicas`          | Persistent Volume size for NATS                    | `2`     |
| `storageClass`      | StorageClass used to store the data                | `""`    |
| `users`             | Users configuration                                | `{}`    |
| `jetstream.size`    | Jetstream persistent storage size                  | `10Gi`  |
| `jetstream.enabled` | Enable or disable Jetstream                        | `true`  |
| `config.merge`      | Additional configuration to merge into NATS config | `{}`    |
| `config.resolver`   | Additional configuration to merge into NATS config | `{}`    |
