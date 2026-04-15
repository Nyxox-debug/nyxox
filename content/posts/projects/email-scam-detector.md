---
title: "Building an Email Scam Detector"
date: 2026-04-14
slug: email-scam-detector
github: "https://github.com/Nyxox-debug/triageai"
categories:
  - projects
tags:
  - python
  - machine-learning
---

## TriageAI: Figuring Out Which Emails Actually Matter

Support inboxes don’t just get busy—they get noisy. The real problem isn’t volume, it’s deciding what deserves attention *right now*.

So I built a small experiment: a model that classifies incoming emails into priority levels — **Urgent, High, Medium, Low**.

<!--more-->

Instead of relying on complex models, I focused on simple signals:

* urgency keywords (“ASAP”, “down”, “urgent”)
* punctuation patterns (excessive `!!!`)
* sentiment (angrier messages tend to be more urgent)

What stood out pretty quickly was that **length doesn’t matter**. Urgent emails aren’t longer—they’re sharper. More direct. More aggressive.

A basic Logistic Regression model, trained on these features, reached about **82% accuracy** with a **91% recall on urgent emails**—which is the only metric that really matters here. Missing an urgent email is the actual failure case.

The interesting part isn’t the model—it’s the signal.
You don’t need deep learning to solve this kind of problem. You just need to capture the right patterns.

Still early, but it’s a solid baseline for something that could plug into a real support workflow.

If you want it slightly more “you” (more sharp/edgy), I can tighten it further.
Check out the full docs:
- [data-exploration.ipynb](/nyxox/docs/email-scam-detector/data-exploration.html)
- [feature-engineering.ipynb](/nyxox/docs/email-scam-detector/feature-engineering.html)

## Key Takeaways

I'll expand on this later - but the core idea is analyzing email patterns for scam indicators using a combination of:
- Data exploration
- Keyword analysis
- Feature engineering
- Email Classification 
