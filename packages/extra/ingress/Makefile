get-cloudflare-ips:
	curl -s https://www.cloudflare.com/ips-v4/# | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}' > ips-v4.tmp
	curl -s https://www.cloudflare.com/ips-v6/# | grep -oE '([0-9a-fA-F]{1,4}::?){1,7}[0-9a-fA-F]{0,4}/[0-9]{1,3}' > ips-v6.tmp
	cat ips-v4.tmp ips-v6.tmp | tr '\n' ',' | sed 's/,$$//' | sed 's/^/"/;s/$$/"/' > ips-merged.tmp
	rm ips-v4.tmp ips-v6.tmp
	IP_LIST=$$(cat ips-merged.tmp); \
	sed -i '' -e '/proxy-real-ip-cidr: "[^"]*"/s|proxy-real-ip-cidr: "[^"]*"|proxy-real-ip-cidr: '"$$IP_LIST"'|' templates/nginx-ingress.yaml
	rm ips-merged.tmp


generate:
	readme-generator -v values.yaml -s values.schema.json -r README.md
