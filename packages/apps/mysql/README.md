## Managed MariaDB Service

The Managed MariaDB Service offers a powerful and widely used relational database solution. This service allows you to create and manage a replicated MariaDB cluster seamlessly.

## Deployment Details

This managed service is controlled by mariadb-operator, ensuring efficient management and seamless operation.

- Docs: https://mariadb.com/kb/en/documentation/
- GitHub: https://github.com/mariadb-operator/mariadb-operator

## HowTos

### How to switch master/slave replica

```
kubectl edit mariadb <instnace>
```
update:

```
spec:
  replication:
    primary:
      podIndex: 1
```

check status:

```
NAME        READY   STATUS    PRIMARY POD   AGE
<instance>  True    Running   app-db1-1     41d
```

### How to restore backup:

find snapshot:
```
restic -r s3:s3.example.org/mariadb-backups/database_name snapshots
```


restore:
```
restic -r s3:s3.example.org/mariadb-backups/database_name restore latest --target /tmp/
```

more details:
- https://itnext.io/restic-effective-backup-from-stdin-4bc1e8f083c1

### Known issues

- **Replication can't not be finished with various errors**
- **Replication can't be finised in case if binlog purged**
  Until mariadbbackup is not used to bootstrap a node by mariadb-operator (this feature is not inmplemented yet), follow these manual steps to fix it:
  https://github.com/mariadb-operator/mariadb-operator/issues/141#issuecomment-1804760231

- **Corrupted indicies**
  Sometimes some indecies can be corrupted on master replica, you can recover them from slave:

  ```
  mysqldump -h <slave> -P 3306 -u<user> -p<password> --column-statistics=0 <database> <table> ~/tmp/fix-table.sql
  mysql -h <master> -P 3306 -u<user> -p<password> <database> < ~/tmp/fix-table.sql
  ```
