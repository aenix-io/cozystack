PUSH := 1
LOAD := 0

image: image-nginx

image-nginx:
	docker buildx build --platform linux/amd64 --build-arg ARCH=amd64 images/nginx \
		--provenance false \
		--tag ghcr.io/aenix-io/cozystack/nginx-cache:latest \
		--cache-from type=registry,ref=ghcr.io/aenix-io/cozystack/nginx-cache:latest \
		--cache-to type=inline \
		--metadata-file images/nginx.json \
		--push=$(PUSH) \
		--load=$(LOAD)

update:
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/chrislim2888/IP2Location-C-Library | awk -F'[/^]' 'END{print $$3}') && \
	sed -i "/^ARG IP2LOCATION_C_VERSION=/ s/=.*/=$$tag/" images/nginx/Dockerfile
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/ip2location/ip2proxy-c | awk -F'[/^]' 'END{print $$3}') && \
	sed -i "/^ARG IP2PROXY_C_VERSION=/ s/=.*/=$$tag/" images/nginx/Dockerfile
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/ip2location/ip2location-nginx | awk -F'[/^]' 'END{print $$3}') && \
	sed -i "/^ARG IP2LOCATION_NGINX_VERSION=/ s/=.*/=$$tag/" images/nginx/Dockerfile
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/ip2location/ip2proxy-nginx | awk -F'[/^]' 'END{print $$3}') && \
	sed -i "/^ARG IP2PROXY_NGINX_VERSION=/ s/=.*/=$$tag/" images/nginx/Dockerfile
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/nginx/nginx | awk -F'[/^]' 'END{print $$3}' | awk -F- '{print $$2}') && \
	sed -i "/^ARG NGINX_VERSION=/ s/=.*/=$$tag/" images/nginx/Dockerfile
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/nginx-modules/ngx_cache_purge | awk -F'[/^]' 'END{print $$3}') && \
	sed -i "/^ARG NGINX_CACHE_PURGE_VERSION=/ s/=.*/=$$tag/" images/nginx/Dockerfile
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/vozlt/nginx-module-vts | awk -F'[/^]' 'END{print $$3}' | sed 's/^v//') && \
	sed -i "/^ARG NGINX_VTS_VERSION=/ s/=.*/=$$tag/" images/nginx/Dockerfile
	tag=$$(git ls-remote --tags --sort="v:refname" https://github.com/51Degrees/Device-Detection | awk -F'[/^]' 'END{print $$3}' | sed 's/^v//') && \
	sed -i "/^ARG FIFTYONEDEGREES_NGINX_VERSION=/ s/=.*/=$$tag/" images/nginx/Dockerfile
