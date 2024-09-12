# Managed Clickhouse Service

## Parameters

### Common parameters

| Name           | Description                         | Value  |
| -------------- | ----------------------------------- | ------ |
| `size`         | Persistent Volume size              | `10Gi` |
| `shards`       | Number of Clickhouse replicas       | `1`    |
| `replicas`     | Number of Clickhouse shards         | `2`    |
| `storageClass` | StorageClass used to store the data | `""`   |

### Configuration parameters

| Name                     | Description                                    | Value                                                  |
| ------------------------ | ---------------------------------------------- | ------------------------------------------------------ |
| `users`                  | Users configuration                            | `{}`                                                   |
| `backup.enabled`         | Enable pereiodic backups                       | `false`                                                |
| `backup.s3Region`        | The AWS S3 region where backups are stored     | `us-east-1`                                            |
| `backup.s3Bucket`        | The S3 bucket used for storing backups         | `s3.example.org/clickhouse-backups`                    |
| `backup.schedule`        | Cron schedule for automated backups            | `0 2 * * *`                                            |
| `backup.cleanupStrategy` | The strategy for cleaning up old backups       | `--keep-last=3 --keep-daily=3 --keep-within-weekly=1m` |
| `backup.s3AccessKey`     | The access key for S3, used for authentication | `oobaiRus9pah8PhohL1ThaeTa4UVa7gu`                     |
| `backup.s3SecretKey`     | The secret key for S3, used for authentication | `ju3eum4dekeich9ahM1te8waeGai0oog`                     |
| `backup.resticPassword`  | The password for Restic backup encryption      | `ChaXoveekoh6eigh4siesheeda2quai0`                     |
