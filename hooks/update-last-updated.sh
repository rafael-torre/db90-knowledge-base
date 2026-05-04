#!/usr/bin/env bash
#
# Pre-commit hook: updates `last_updated` in YAML frontmatter of final documents.
#
# Detects staged final documents (**/final/**/*.md) with YAML frontmatter,
# sets `last_updated` to today's date, and re-stages the file.
#
# Installation (pick one):
#
#   Direct:
#     cp hooks/update-last-updated.sh .git/hooks/pre-commit
#     chmod +x .git/hooks/pre-commit
#
#   Husky (Node.js):
#     npx husky add .husky/pre-commit "bash hooks/update-last-updated.sh"
#
#   Lefthook:
#     # lefthook.yml
#     pre-commit:
#       commands:
#         update-last-updated:
#           run: bash hooks/update-last-updated.sh
#
#   pre-commit (Python):
#     # .pre-commit-config.yaml
#     - repo: local
#       hooks:
#         - id: update-last-updated
#           name: Update last_updated in final docs
#           entry: bash hooks/update-last-updated.sh
#           language: system
#           pass_filenames: false
#
# Platform support:
#   macOS, Linux, and Windows (via Git Bash, which ships with Git for Windows).

set -euo pipefail

TODAY=$(date +%Y-%m-%d)

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

for file in $STAGED_FILES; do
  case "$file" in
    */final/*.md | */final/**/*.md)
      ;;
    *)
      continue
      ;;
  esac

  head_bytes=$(head -c 4 "$file")
  if [ "$head_bytes" != "---" ]; then
    continue
  fi

  if ! grep -q "^last_updated:" "$file"; then
    continue
  fi

  current_value=$(grep "^last_updated:" "$file" | head -1 | sed 's/^last_updated:[[:space:]]*//')
  if [ "$current_value" = "$TODAY" ]; then
    continue
  fi

  # macOS sed requires '' after -i; Linux and Git Bash (Windows) do not
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^last_updated:.*$/last_updated: $TODAY/" "$file"
  else
    sed -i "s/^last_updated:.*$/last_updated: $TODAY/" "$file"
  fi

  git add "$file"
done
