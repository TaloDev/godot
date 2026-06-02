---
name: review
description: Review the current branch
---

## Determining what to review

- Run: `git log develop..HEAD` for commits to the current branch
- Run: `git diff` for unstaged changes
- Run: `git diff --cached` for staged changes
- Run: `git status --short` to identify untracked (net new) files

## Performing the code review

Follow these steps:

1. Use the **code-reviewer** subagent to review the diff.
2. Pass the finished review to the **code-review-verifier** subagent.
3. Output the verified final review.
