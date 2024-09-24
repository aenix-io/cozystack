# Release notes for version 0.25.17

**Release date:** 2024-09-20

![AppVersion: v1.102.1](https://img.shields.io/static/v1?label=AppVersion&message=v1.102.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Added VMAuth to k8s stack. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/829)
- Fixed ETCD dashboard
- Use path prefix from args as a default path prefix for ingress. Related [issue](https://github.com/VictoriaMetrics/helm-charts/issues/1260)
- Allow using vmalert without notifiers configuration. Note that it is required to use `.vmalert.spec.extraArgs["notifiers.blackhole"]: true` in order to start vmalert with a blackhole configuration.

