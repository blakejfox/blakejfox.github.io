#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") slug "Post Title"
Creates a new post in _posts/ from templates/post-template.md and prepares assets/images/screenshots/slug/ and assets/images/slug/.
Example: $(basename "$0") my-new-post "My New Post Title"
EOF
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

raw_slug="$1"
title="${2:-Your Post Title Here}"

# sanitize slug: lowercase, keep letters/numbers/hyphens
slug="$(printf '%s' "$raw_slug" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')"
if [ -z "$slug" ]; then
  echo "Error: invalid slug after sanitization." >&2
  exit 2
fi

date_prefix="$(date +%F)"
datetime="$(date +"%Y-%m-%d %H:%M:%S %z")"
target="_posts/${date_prefix}-${slug}.md"

mkdir -p "$(dirname "$target")"

if [ ! -f templates/post-template.md ]; then
  echo "Error: templates/post-template.md not found." >&2
  exit 3
fi

# Replace title and date in the template and write to _posts
awk -v title="$title" -v date="$datetime" '
  BEGIN { tset=0; dset=0 }
  /^title:/ && !tset { print "title: \"" title "\""; tset=1; next }
  /^date:/ && !dset { print "date: \"" date "\""; dset=1; next }
  { print }
' templates/post-template.md > "$target"

# Create image folders for screenshots and other images for this post
mkdir -p "assets/images/${date_prefix}-${slug}"

echo "Created: $target"
echo "Images dir: assets/images/${date_prefix}-${slug}"
echo "Open the new post: code \"$target\""