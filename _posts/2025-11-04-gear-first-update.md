---
# Default post front matter — copy this into a new file under _posts/
title: "GEAR BLOG #1"
# You can omit `date` to let Jekyll use the filename (YYYY-MM-DD-title.md).
# If you include it, use this format: YYYY-MM-DD HH:MM:SS ±HHMM
date: "2025-11-04 02:20:04 +0000"
categories: [Blazor]
tags:
  - blazor
  - .net
  - gear
author: blake
---

## Introduction

Gear is an exercise management application build on the .NET Blazor platform. It's goal is to be simple, easy and fast so that the user can spend as little time as possible inputting information at the gym. 

My gym has an application which they provide that has this function - Trainerize. This application has a lot of features and is very useful. However, it has a few key issues. 

- Exercises are hard to search and load slowly
- Exercises are all in a huge list that you have to search the exact exercise name for, causing substitutions to be a hassle. More meta data could be used to make suggested substitutions (prioritized based on primary muscle, push, pull, technical difficulty)
- App in general has a lot of different features, making navigating to training difficult and many components load slowly
- User must stay subscribed to keep access to exercise data
- Data is not easily download for analysis
- You can't curate 'your' list of exercises/substitutions - you have to search for a substitution each time

Gear's goal is to try and maintian speed at all times. It is meant to be lightweight on the phone through Blazor client-server configuration. It will attempt to address all of the issues above. 

I am also using this opportunity to build an application in C# Blazor and learn best practices. I am using a postgres SQL server to components such as the master exercise list, user defined workouts, user defined exercise list, and user profiles. 

This application is developed in collaboration with Claude Sonnet 3.5. 

## Progress

This project's primary purpose (outside of solving the obvious list of problems above) is to learn best practices developing, deploying, and maintaining a Blazor application. I am using this as an opportunity to learn best practices. 

I've found that I discover a best practice about an hour after I already went far enough to make backing out irritating. 

Regardless, I am close to having the appropriate development environment set up for the application. I am going to have a dedicated debian host that will have the .NET SDK and Aspire packages, along with a docker runtime, to support the managment of the application and database containers through Aspire. 

It's been a lot of work for not a lot of output yet. Once I realized that I wanted to write the dates to a database, getting into Aspire was a natural next step - no need to run a container separately. 

## Conclusion

I'll hopefully have a more substantial update soon. Working on an ARM laptop, developing locally, was a wonderful learning experience - but ARM support for the latest .NET features is still a little behind x86. 


<!-- Optional: If you want a per-post contact callout, remove this comment and add content here.
     Otherwise rely on site-wide contact/social links (header/footer) handled by the theme/post-meta. -->
