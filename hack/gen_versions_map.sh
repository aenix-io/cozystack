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
        # Not committed yet, use previous commit
        line=$(git show HEAD:"./$chart/Chart.yaml" | awk '/^version:/ {print NR; exit}')
        commit=$(git --no-pager blame -L"$line",+1 HEAD -- "$chart/Chart.yaml" | awk '{print $1}')
        if [ $(echo $commit | cut -c1) = "^" ]; then
          # Previous commit not exists
          commit=$(echo $commit | cut -c2-)
        fi
      else
        # Committed, but version_map wasn't updated
        line=$(git show HEAD:"./$chart/Chart.yaml" | awk '/^version:/ {print NR; exit}')
        change_commit=$(git --no-pager blame -L"$line",+1 HEAD -- "$chart/Chart.yaml" | awk '{print $1}')
        if [ $(echo $change_commit | cut -c1) = "^" ]; then
          # Previous commit not exists
          commit=$(echo $change_commit | cut -c2-)
        else
          commit=$(git describe --always "$change_commit~1")
        fi
      fi

      # Check if the commit belongs to the main branch
      if ! git merge-base --is-ancestor "$commit" main; then
        # Find the closest parent commit that belongs to main
        commit_in_main=$(git log --pretty=format:"%h" main -- "$chart" | head -n 1)
        if [ -n "$commit_in_main" ]; then
          commit="$commit_in_main"
        else
          # No valid commit found in main branch for $chart, skipping..."
          continue
        fi
      fi
    fi
    echo "$chart $version $commit"
  done
)

printf "%s\n" "$new_map" "$resolved_miss_map" | sort -k1,1 -k2,2 -V | awk '$1' > "$file"
