---
# Default post front matter — copy this into a new file under _posts/
title: "Blog Infrastructure Update"
# You can omit `date` to let Jekyll use the filename (YYYY-MM-DD-title.md).
# If you include it, use this format: YYYY-MM-DD HH:MM:SS ±HHMM
date: "2025-10-23 18:45:17 +0000"
categories: [CI/CD]
tags:
  - ai
  - copilot
  - vscode
  - jekyll
  - github
  - ci/cd
author: Blake
---

## Introduction

It's been a couple of years. When I first deployed this blog, the goal was to improve my skills with Markdown and deploying web applications. While that was successful, the nature of the website as a static web site means that creating a new post was a fairly manual process. Today, using Copilot in VS Code, I've learned more about these topics than I have in the past three years that this blog has existed. 

## What Changed? 

I've done a number of small quality of life improvements for the blog. 

1. Using Copilot, I reviewed the existing github build and deploy actions. In the past, I've had issues where I would fail builds and deployments when adding a blog post - this disincentivized me from making updates to the site.
2. I've learned more about how Jekyll handles templates and meta data. Each post is now generated using a layout with the meta data included, significantly cutting down on manual implementation. 
3. A post template is now used to generate a post with the current date and standard front-matter. The assets folder for images is also deployed at the same time, making image inclusion a little easier. 
4. I've standardized my blog writing environment. The blog repo lives on a debian host that I can edit from anywhere. I have a tendency to change laptops and distros often, so having a stable development environment has been a big deal. 

## Post Template Script

Now instead of creating these assets manually, I automatically generate it. Running this script from the root of my project positions me to immediately fill and publish the blog post.

{% highlight bash %}
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
{% endhighlight %}


## Results / Notes

Using copilot to create a shell script, I noticed that the behavior is a little different than other files. For most additions, vs code copilot can immediately write a new directory and drop the file. However, for the script, it expects you to actually execute it from terminal and doesn't offer to write it into the file tree. 

## Conclusion

I originally set up this blog to learn about deploying static websites with github actions and provide a place to showcase work that I do in my personal time. While it was a success on learning about Github Actions, the difficulty of writing a blog post has created a situation where I never blog, and blog posts that I do write have a high rate of clerical errors. 

Using VS Code Copilot, I was able to streamline my work in such a way that feels more sustainable going forward. 

I'm hoping to have a lot more content on the way! Stay tuned for updates from here, and my new Youtube channel, [Fox Labs Build & Deploy](https://www.youtube.com/@FoxLabBuilds)

<!-- Optional: If you want a per-post contact callout, remove this comment and add content here.
     Otherwise rely on site-wide contact/social links (header/footer) handled by the theme/post-meta. -->
