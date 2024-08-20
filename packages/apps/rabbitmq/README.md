# Managed RabbitMQ Service

RabbitMQ is a robust message broker that plays a crucial role in modern distributed systems. Our Managed RabbitMQ Service simplifies the deployment and management of RabbitMQ clusters, ensuring reliability and scalability for your messaging needs.

## Deployment Details

The service utilizes official RabbitMQ operator. This ensures the reliability and seamless operation of your RabbitMQ instances.

- Github: https://github.com/rabbitmq/cluster-operator/
- Docs: https://www.rabbitmq.com/kubernetes/operator/operator-overview.html

## Parameters

### Common parameters

| Name           | Description                                     | Value   |
| -------------- | ----------------------------------------------- | ------- |
| `external`     | Enable external access from outside the cluster | `false` |
| `size`         | Persistent Volume size                          | `10Gi`  |
| `replicas`     | Number of RabbitMQ replicas                     | `3`     |
| `storageClass` | StorageClass used to store the data             | `""`    |
