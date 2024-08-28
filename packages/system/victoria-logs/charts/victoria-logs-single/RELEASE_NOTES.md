# Release notes for version 0.6.0

**Release date:** 2024-08-21

![AppVersion: v0.28.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.28.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Update note**: The VictoriaMetrics components image tag template has been updated. This change introduces `.Values.<component>.image.variant` to specify tag suffixes like `-scratch`, `-cluster`, `-enterprise`. Additionally, you can now omit `.Values.<component>.image.tag` to automatically use the version specified in `.Chart.AppVersion`.

**Update note**: main container name was changed to `vlogs`, which will recreate a pod.

- Added `basicAuth` support for `ServiceMonitor`
- Set minimal kubernetes version to `1.25`
- Removed support for `policy/v1beta1/PodDisruptionBudget`
- Updated `.Values.server.readinessProbe` to `.Values.server.probe.readiness`
- Updated `.Values.server.livenessProbe` to `.Values.server.probe.liveness`
- Updated `.Values.server.startupProbe` to `.Values.server.probe.startup`
- Added `.Values.global.imagePullSecrets` and `.Values.global.image.registry`
- Added `.Values.server.emptyDir` to customize default data directory
- Merged headless and non-headless services, removed statefulset service specific variables
- Use static container names in a pod
- Removed `networking.k8s.io/v1beta1/Ingress` and `extensions/v1beta1/Ingress` support
- Added `.Values.server.service.ipFamilies` and `.Values.server.service.ipFamilyPolicy` for service IP family management

