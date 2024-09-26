# Monitoring Hub

## Parameters

### Common parameters

| Name                            | Description                                                                                               | Value                                            |
| ------------------------------- | --------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `host`                          | The hostname used to access the grafana externally (defaults to 'grafana' subdomain for the tenant host). | `""`                                             |
| `metricsStorages`               | Configuration of metrics storage instances                                                                | `[]`                                             |
| `logsStorages`                  | Configuration of logs storage instances                                                                   | `[]`                                             |
| `alerta.storage`                | Persistent Volume size for alerta database                                                                | `10Gi`                                           |
| `alerta.storageClassName`       | StorageClass used to store the data                                                                       | `""`                                             |
| `alerta.alerts.telegram.token`  | telegram token for your bot                                                                               | `7262461387:AAGtwq16iwuVtWtzoN6TUEMpF00fpC9Xz34` |
| `alerta.alerts.telegram.chatID` | specify multiple ID's separated by comma. Get yours in https://t.me/chatid_echo_bot                       | `-4520856007`                                    |
