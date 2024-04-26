# Managed Clickhouse Service

## Parameters

### Common parameters

| Name       | Description                   | Value  |
| ---------- | ----------------------------- | ------ |
| `size`     | Persistent Volume size        | `10Gi` |
| `shards`   | Number of Clickhouse replicas | `1`    |
| `replicas` | Number of Clickhouse shards   | `2`    |

### Configuration parameters

| Name    | Description         | Value |
| ------- | ------------------- | ----- |
| `users` | Users configuration | `{}`  |
