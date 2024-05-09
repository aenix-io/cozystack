# Managed Kafka Service

## Parameters

### Common parameters

| Name                 | Description                                     | Value   |
| -------------------- | ----------------------------------------------- | ------- |
| `external`           | Enable external access from outside the cluster | `false` |
| `kafka.size`         | Persistent Volume size for Kafka                | `10Gi`  |
| `kafka.replicas`     | Number of Kafka replicas                        | `3`     |
| `zookeeper.size`     | Persistent Volume size for ZooKeeper            | `5Gi`   |
| `zookeeper.replicas` | Number of ZooKeeper replicas                    | `3`     |

### Configuration parameters

| Name     | Description          | Value |
| -------- | -------------------- | ----- |
| `topics` | Topics configuration | `[]`  |
