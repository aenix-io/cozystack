update:
	export RELEASE=$$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt) && \
	wget https://github.com/kubevirt/kubevirt/releases/download/$${RELEASE}/kubevirt-operator.yaml -O kubevirt-operator.yaml && \
	wget https://github.com/kubevirt/kubevirt/releases/download/$${RELEASE}/kubevirt-cr.yaml -O kubevirt-cr.yaml
	sed -i 's/namespace: kubevirt/namespace: cozy-kubevirt/g' kubevirt-cr.yaml kubevirt-operator.yaml
	sed -i '1,9 s/name: kubevirt/name: cozy-kubevirt/' kubevirt-operator.yaml

apply:
	kubectl apply -f kubevirt-operator.yaml
	kubectl apply -f kubevirt-cr.yaml
