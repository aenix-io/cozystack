### Changed

- Updated _ExternalDNS_ OCI image version to [v0.15.0](https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.15.0). ([#xxxx](https://github.com/kubernetes-sigs/external-dns/pull/xxxx)) _@stevehipwell_

### Fixed

- Fixed `provider.webhook.resources` behavior to correctly leverage resource limits. ([#4560](https://github.com/kubernetes-sigs/external-dns/pull/4560)) _@crutonjohn_
- Fixed `provider.webhook.imagePullPolicy` behavior to correctly leverage pull policy. ([#4643](https://github.com/kubernetes-sigs/external-dns/pull/4643)) _@kimsondrup_
- Fixed to add correct webhook metric port to `Service` and `ServiceMonitor`. ([#4643](https://github.com/kubernetes-sigs/external-dns/pull/4643)) _@kimsondrup_
- Fixed to no longer require the unauthenticated webhook provider port to be exposed for health probes. ([#4691](https://github.com/kubernetes-sigs/external-dns/pull/4691)) _@kimsondrup_ & _@hatrx_
