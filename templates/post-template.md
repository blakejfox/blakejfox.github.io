---
# Default post front matter — copy this into a new file under _posts/
title: "Your Post Title Here"
# You can omit `date` to let Jekyll use the filename (YYYY-MM-DD-title.md).
# If you include it, use this format: YYYY-MM-DD HH:MM:SS ±HHMM
date: "2025-10-23 12:00:00 -0600"
categories: [CI/CD]
tags:
  - tag1
  - tag2
author: blake
---

## Introduction

Briefly introduce the problem or topic you're addressing. State the goal of the post and what readers will learn.

## Background / Context

Provide any necessary background, prerequisites, or environment details. Link to references or documentation where appropriate.

## Steps / Implementation

Describe the steps, commands, code, or configuration. Use fenced code blocks and explain important lines.

```powershell
# example code block
Write-Host "Replace with your actual script or commands"
```

## Results / Notes

Show expected results, screenshots, outputs, or caveats. Add troubleshooting tips or common pitfalls.

### Screenshots (hint)
- Store screenshots in: assets/images/screenshots/
- Reference them in your post using the site's relative_url helper so paths work in dev and production. Example:

```markdown
![Short description]({{ '/assets/images/screenshots/example.png' | relative_url }})
```

- Keep filenames simple and lowercase, e.g., example.png. For multiple images, consider a subfolder per post.

## Conclusion

Summarize the key takeaways and next steps. Provide links to related posts or resources.

<!-- Optional: If you want a per-post contact callout, remove this comment and add content here.
     Otherwise rely on site-wide contact/social links (header/footer) handled by the theme/post-meta. -->