# Release notes for version 0.0.5

**Release date:** 2024-08-26

![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

- Fixed `vm.enterprise.only` template to check if at least one of both global.licence.eula and .Values.license.eula are defined
- Convert `vm.args` bool `true` values to flags without values

