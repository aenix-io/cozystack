# Managed PostgreSQL Service

PostgreSQL is currently the leading choice among relational databases, known for its robust features and performance. Our Managed PostgreSQL Service takes advantage of platform-side implementation to provide a self-healing replicated cluster. This cluster is efficiently managed using the highly acclaimed CloudNativePG operator, which has gained popularity within the community.

## Deployment Details

This managed service is controlled by the CloudNativePG operator, ensuring efficient management and seamless operation.

- Docs: https://cloudnative-pg.io/documentation/
- Github: https://github.com/cloudnative-pg/cloudnative-pg

## HowTos

### How to switch master/slave replica

See:
- https://cloudnative-pg.io/documentation/1.15/rolling_update/#manual-updates-supervised

### How to restore backup:

find snapshot:
```
restic -r s3:s3.example.org/postgres-backups/database_name snapshots
```

restore:
```
restic -r s3:s3.example.org/postgres-backups/database_name restore latest --target /tmp/
```

more details:
- https://itnext.io/restic-effective-backup-from-stdin-4bc1e8f083c1
