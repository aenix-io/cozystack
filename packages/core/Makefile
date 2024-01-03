fix-chartnames:
	find . -name Chart.yaml -maxdepth 2 | awk -F/ '{print $$2}' | while read i; do printf "name: cozy-%s\nversion: 1.0.0\n" "$$i" > "$$i/Chart.yaml"; done
