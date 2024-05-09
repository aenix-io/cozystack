# Monitoring Hub

## Parameters

### Common parameters

| Name              | Description                                                                                               | Value   |
| ----------------- | --------------------------------------------------------------------------------------------------------- | ------- |
| `host`            | The hostname used to access the grafana externally (defaults to 'grafana' subdomain for the tenant host). | `""`    |
| `metricsStorages` | Configuration of metrics storage instances                                                                | `[]`    |
| `oncall.enabled`  | Enable Grafana OnCall                                                                                     | `false` |
