VERSION := 0.2.0

gen: fix-chartnames
	
fix-chartnames:
	find . -name Chart.yaml -maxdepth 2 | awk -F/ '{print $$2}' | while read i; do printf "name: cozy-%s\nversion: $(VERSION)\n" "$$i" > "$$i/Chart.yaml"; done
