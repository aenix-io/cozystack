NAMESPACE=cozy-installer
NAME=installer

show:
	helm template -n $(NAMESPACE) $(NAME) .

apply:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl apply -f -

diff:
	helm template -n $(NAMESPACE) $(NAME) . | kubectl diff -f -

image:
	docker build -f images/installer/Dockerfile ../../..
