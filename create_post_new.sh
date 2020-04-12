#!/bin/bash
editor="vim"


cat <<EOF > _posts/$(date +%Y-%m-%d)-$1.markdown
---
layout: post
title:  "Title"
date:   $(date +"%Y-%m-%d %H:%M:%S %z")
categories: newpost
---
EOF
echo "Creating new post..."
sleep 1
echo "Opening post with $editor"
sleep 2
$editor _posts/$(date +%Y-%m-%d)-$1.markdown
