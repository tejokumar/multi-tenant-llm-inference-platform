#!/usr/bin/env bash

set -euo pipefail

required_files=(
  README.md
  CODEX.md
  docs/decisions/README.md
  docs/architecture/README.md
  docs/runbooks/README.md
  infrastructure/README.md
  experiments/README.md
  evidence/README.md
)

for file in "${required_files[@]}"; do
  if [[ ! -s "$file" ]]; then
    echo "Required artifact is missing or empty: $file" >&2
    exit 1
  fi
done

while IFS= read -r decision; do
  if [[ ! "$decision" =~ /[0-9]{4}-[a-z0-9-]+\.md$ ]]; then
    echo "ADR name must use NNNN-short-title.md: $decision" >&2
    exit 1
  fi
done < <(find docs/decisions -maxdepth 1 -type f ! -name README.md | sort)

if git grep -nE '[[:blank:]]+$' -- '*.md' '*.yml' '*.yaml' '*.sh'; then
  echo "Remove trailing whitespace from the files listed above." >&2
  exit 1
fi

echo "Artifact checks passed."
