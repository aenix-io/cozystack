NAME=seaweedfs-system

include ../../../scripts/package.mk

update:
	rm -rf charts
	mkdir -p charts
	curl -sSL https://github.com/seaweedfs/seaweedfs/archive/refs/heads/master.tar.gz | \
	tar xzvf - --strip 3 -C charts seaweedfs-master/k8s/charts/seaweedfs
	patch --no-backup-if-mismatch -p4 < patches/retention-policy-delete.yaml
	patch --no-backup-if-mismatch -p4 < patches/resize-api-server-annotation.diff
