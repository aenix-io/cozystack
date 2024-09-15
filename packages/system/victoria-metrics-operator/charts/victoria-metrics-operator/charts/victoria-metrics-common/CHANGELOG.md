# CHANGELOG for `victoria-metrics-common` helm-chart

## Next release

- TODO

## 0.0.5

**Release date:** 2024-08-26

![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Fixed `vm.enterprise.only` template to check if at least one of both global.licence.eula and .Values.license.eula are defined
- Convert `vm.args` bool `true` values to flags without values

## 0.0.4

**Release date:** 2024-08-26

![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Updated `vm.probe.*` templates to remove Helm 3.14 restriction.
- Added `vm.args` template for cmd args generation

## 0.0.3

**Release date:** 2024-08-25

![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Moved license templates from other charts `vm.license.volume`, `vm.license.mount`, `vm.license.flag`
- Moved `vm.compatibility.renderSecurityContext` template
- Fixed a case, when null is passed to a `.Values.global`. See [this issue](https://github.com/VictoriaMetrics/helm-charts/issues/1296)

## 0.0.2

**Release date:** 2024-08-23

![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Added `vm.port.from.flag` template to extract port from cmd flag listen address.

## 0.0.1

**Release date:** 2024-08-15

![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Added `vm.enterprise.only` template to fail rendering if required license arguments weren't set.
- Added `vm.image` template that introduces common chart logic of how to build image name from application variables.
- Added `vm.ingress.port` template to render properly tngress port configuration depending on args type.
- Added `vm.probe.*` templates to render probes params consistently across all templates.
