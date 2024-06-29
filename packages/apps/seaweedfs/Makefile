update:
	rm -rf charts
	helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm
	helm repo update seaweedfs
	helm pull seaweedfs/seaweedfs --untar --untardir charts
