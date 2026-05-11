---
name: review-pr
description: Review the current pull request
agent: code-reviewer
---

Use the @code-reviewer agent to review the current pull request.

After receiving the review, pass it to the @code-review-verifier subagent for fact-checking.

Output the @code-review-verifier's finalized review.
