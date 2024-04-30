#!/bin/sh
set -e
file=versions_map
charts=$(find . -mindepth 2 -maxdepth 2 -name Chart.yaml | awk 'sub("/Chart.yaml", "")')

# <chart> <version> <commit> 
new_map=$(
  for chart in $charts; do
    awk '/^name:/ {chart=$2} /^version:/ {version=$2} END{printf "%s %s %s\n", chart, version, "HEAD"}' $chart/Chart.yaml
  done
)

if [ ! -f "$file" ] || [ ! -s "$file" ]; then
  echo "$new_map" > "$file"
  exit 0
fi

miss_map=$(echo "$new_map" | awk 'NR==FNR { new_map[$1 " " $2] = $3; next } { if (!($1 " " $2 in new_map)) print $1, $2, $3}' - $file)

resolved_miss_map=$(
  echo "$miss_map" | while read chart version commit; do
    if [ "$commit" = HEAD ]; then
      line=$(awk '/^version:/ {print NR; exit}' "./$chart/Chart.yaml")
      change_commit=$(git --no-pager blame -L"$line",+1 -- "$chart/Chart.yaml" | awk '{print $1}')
       
      if [ "$change_commit" = "00000000" ]; then
        # Not commited yet, use previus commit
        line=$(git show HEAD:"./$chart/Chart.yaml" | awk '/^version:/ {print NR; exit}')
        commit=$(git --no-pager blame -L"$line",+1 HEAD -- "$chart/Chart.yaml" | awk '{print $1}')
        if [ $(echo $commit | cut -c1) = "^" ]; then
          # Previus commit not exists
          commit=$(echo $commit | cut -c2-)
        fi
      else
        # Commited, but version_map wasn't updated
        line=$(git show HEAD:"./$chart/Chart.yaml" | awk '/^version:/ {print NR; exit}')
        change_commit=$(git --no-pager blame -L"$line",+1 HEAD -- "$chart/Chart.yaml" | awk '{print $1}')
        if [ $(echo $change_commit | cut -c1) = "^" ]; then
          # Previus commit not exists
          commit=$(echo $change_commit | cut -c2-)
        else
          commit=$(git describe --always "$change_commit~1")
        fi
      fi
    fi
    echo "$chart $version $commit"
  done
)

printf "%s\n" "$new_map" "$resolved_miss_map" | sort -k1,1 -k2,2 -V | awk '$1' > "$file"
