# Tenant

A tenant is the main unit of security on the platform. The closest analogy would be Linux kernel namespaces.

Tenants can be created recursively and are subject to the following rules:

### Higher-level tenants can access lower-level ones.

Higher-level tenants can view and manage the applications of all their children.

### Each tenant has its own domain

By default (unless otherwise specified), it inherits the domain of its parent with a prefix of its name, for example, if the parent had the domain `example.org`, then `tenant-foo` would get the domain `foo.example.org` by default.

Kubernetes clusters created in this tenant namespace would get domains like: `kubernetes-cluster.foo.example.org`

Example:
```
tenant-root (example.org)
└── tenant-foo (foo.example.org)
    └── kubernetes-cluster1 (kubernetes-cluster1.foo.example.org)
```

### Lower-level tenants can access the cluster services of their parent (provided they do not run their own)

Thus, you can create `tenant-u1` with a set of services like `etcd`, `ingress`, `monitoring`. And create another tenant namespace `tenant-u2` inside of `tenant-u1`.

Let's see what will happen when you run Kubernetes and Postgres under `tenant-u2` namespace.

Since `tenant-u2` does not have its own cluster services like `etcd`, `ingress`, and `monitoring`, the applications will use the cluster services of the parent tenant.  
This in turn means:

- The Kubernetes cluster data will be stored in etcd for `tenant-u1`.
- Access to the cluster will be through the common ingress of `tenant-u1`.
- Essentially, all metrics will be collected in the monitoring from `tenant-u1`, and only it will have access to them.


Example:
```
tenant-u1
├── etcd
├── ingress
├── monitoring
└── tenant-u2
    ├── kubernetes-cluster1
    └── postgres-db1
```

## Parameters

### Common parameters

| Name             | Description                                                                                                                 | Value   |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------- | ------- |
| `host`           | The hostname used to access tenant services (defaults to using the tenant name as a subdomain for it's parent tenant host). | `""`    |
| `etcd`           | Deploy own Etcd cluster                                                                                                     | `false` |
| `monitoring`     | Deploy own Monitoring Stack                                                                                                 | `false` |
| `ingress`        | Deploy own Ingress Controller                                                                                               | `false` |
| `seaweedfs`      | Deploy own SeaweedFS                                                                                                        | `false` |
| `isolated`       | Enforce tenant namespace with network policies                                                                              | `false` |
| `resourceQuotas` | Define resource quotas for the tenant                                                                                       | `{}`    |
