---
title: "Useful Git Commands"
date: 2026-03-15T11:00:00+01:00
categories:
  - notes
tags:
  - git
  - cheatsheet
---

Quick git commands I keep forgetting:

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Stash changes
git stash push -m "work in progress"

# Interactive rebase
git rebase -i HEAD~5
```
