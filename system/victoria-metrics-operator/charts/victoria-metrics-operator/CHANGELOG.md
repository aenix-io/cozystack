# CHANGELOG for `victoria-metrics-operator` helm-chart

## Next release

**Release date:** TBD

![AppVersion: **APP_VERSION**](https://img.shields.io/static/v1?label=AppVersion&message=**APP_VERSION**&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- TODO

## 0.26.0

**Release date:** 2023-08-30

![AppVersion: 0.37.0](https://img.shields.io/static/v1?label=AppVersion&message=0.37.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Bump operator version to [v0.37.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.37.0)
- `psp_auto_creation_enabled` for operator is disabled by default

## 0.25.0

**Release date:** 2023-08-24

![AppVersion: 0.36.0](https://img.shields.io/static/v1?label=AppVersion&message=0.36.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* Added `topologySpreadConstraints` for the operator + a small refactoring (#611)
* Fix vm operator appVersion (#589)
* Fixes operator doc description
* Add `cleanupCRD` option to clean up vm cr resources when uninstalling (#593)
* Bump operator version to [v0.36.0](https://github.com/VictoriaMetrics/operator/releases/tag/v0.36.0)

## 0.24.1

**Release date:** 2023-07-13

![AppVersion: 0.35.](https://img.shields.io/static/v1?label=AppVersion&message=0.35.&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* operator release v0.35.1

## 0.24.0

**Release date:** 2023-07-03

![AppVersion: 0.35.0](https://img.shields.io/static/v1?label=AppVersion&message=0.35.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* updates operator for v0.35.0
* updates for v1.91.1 release

## 0.23.1

**Release date:** 2023-05-29

![AppVersion: 0.34.1](https://img.shields.io/static/v1?label=AppVersion&message=0.34.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* updates operator for v0.34.1 version

## 0.23.0

**Release date:** 2023-05-25

![AppVersion: 0.34.0](https://img.shields.io/static/v1?label=AppVersion&message=0.34.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

* bump operator version
* feat(operator): add PodDisruptionBudget (#546)
