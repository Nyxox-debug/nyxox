---
title: "Building an Email Priority Classifier"
date: 2026-04-14
slug: email-scam-detector
github: "https://github.com/Nyxox-debug/triageai"
categories:
  - projects
tags:
  - python
  - machine-learning
---

I've always wondered: what actually makes an email urgent? Is it the length? The words? The tone? So I built TriageAI - a model that classifies incoming emails into priority levels (Urgent, High, Medium, Low) to figure out what deserves attention *right now*.

<!--more-->

## The Problem

Support inboxes don't just get busy - they get noisy. Hundreds of emails coming in every day, and the real question isn't "how many emails" but "which ones matter?".

I wanted to see if I could build something that could automatically sort emails by urgency, so support teams could focus on what actually needs attention first.

## The Dataset

Since I didn't have access to a real support inbox (that would be a privacy nightmare), I generated a synthetic dataset of ~800 emails that mimics real customer support patterns:

- **Urgent** (10%): System down, critical bugs, payment issues
- **High** (25%): Account problems, broken features, time-sensitive requests
- **Medium** (40%): General inquiries, feature requests, follow-ups
- **Low** (25%): Spam, newsletters, casual questions

The key was making the emails feel realistic - different tones, lengths, and urgency signals that you'd actually see in a support inbox.

## Feature Engineering

This was the interesting part. I used two types of features:

### 1. TF-IDF Features (300 features)
Standard text vectorization to capture which words matter. The TF-IDF analysis showed clear patterns - urgent emails had words like "ASAP", "broken", "immediately", while low priority emails had "subscribe", "newsletter", "update".

### 2. Custom Urgency Signals (9 features)
These were the signals that actually made the difference:

- **Exclamation marks** - "!!!" usually means urgency
- **ALL CAPS words** - Shouting usually indicates frustration
- **Urgency keywords** - "ASAP", "urgent", "critical", "down", "emergency"
- **Sentiment** - TextBlob polarity score (more negative = more urgent)
- **All-caps subject line** - A simple but effective signal

```python
# Example: extracting urgency signals
def count_urgency_signals(text):
    signals = {
        'exclamation_count': text.count('!'),
        'caps_words': sum(1 for word in text.split() if word.isupper() and len(word) > 1),
        'urgency_keywords': sum(1 for word in ['asap', 'urgent', 'critical', 'down'] if word in text.lower()),
        'sentiment': TextBlob(text).sentiment.polarity
    }
    return signals
```

## The Model

I went with Logistic Regression. It might seem simple, but for this kind of classification problem, it's actually perfect - interpretable, fast, and works well with the feature set I had.

One important detail: since Urgent emails are only 10% of the data, I used `class_weight='balanced'` to make sure the model didn't just learn to always predict "Medium" or "High".

## Results

The model achieved:

- **82% overall accuracy**
- **91% recall on Urgent emails** - This was the critical metric. Missing an urgent email is the actual failure case here.

What surprised me was what didn't matter: **email length**. Urgent emails aren't longer - they're sharper. More direct. More aggressive. The model learned that it's not about how much someone writes, but how they write it.

## What I Learned

1. **Simple features work** - You don't need deep learning for this. The combination of TF-IDF plus custom urgency signals gave us solid results.

2. **Domain knowledge helps** - Adding those custom features (exclamation marks, CAPS, urgency keywords) made a real difference. TF-IDF alone wouldn't have captured "!!!" as a signal.

3. **Class imbalance matters** - The `class_weight='balanced'` was crucial. Without it, the model would just predict the majority classes and miss all the urgent emails.

4. **Interpretability is valuable** - With Logistic Regression, I can actually explain why the model classified something as urgent. That's important for trust in a real support workflow.

## What's Next

This was a proof-of-concept, but there's room to grow:

- Try on real data (with proper privacy handling)
- Add more features (time of day, sender history)
- Experiment with other models (Random Forest, XGBoost)
- Build an actual integration with email providers

The notebooks have all the details - data exploration and feature engineering are both available if you want to dig into the code:

- [data-exploration.ipynb](/docs/email-scam-detector/data-exploration.html)
- [feature-engineering.ipynb](/docs/email-scam-detector/feature-engineering.html)

It works. It's not perfect. But it's a solid baseline for something that could actually help support teams prioritize what matters.
