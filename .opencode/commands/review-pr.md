---
name: review-pr
description: Review the current pull request
agent: code-reviewer
---

Use the @code-reviewer agent to review the current pull request.

After receiving the code-reviewer’s review, you MUST pass it to the @code-review-verifier subagent for fact-checking. Provide the subagent with:

1. The original PR diff
2. The code-reviewer’s complete review text

Output the @code-review-verifier's finalized code review.
