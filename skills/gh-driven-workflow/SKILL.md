---
name: gh-driven-workflow
description: A strict GitHub-driven development workflow to ensure every bug fix or feature implementation is tracked via GitHub Issues, documented in changelog.md, and referenced in every commit. Use this when a user reports a bug or requests a new feature.
---

# GitHub-Driven Workflow

This skill enforces a disciplined engineering process by mandating that every change starts with a GitHub Issue and ends with a verified closure.

## Core Mandates

1. **Issue First**: NEVER modify code before creating or identifying a corresponding GitHub Issue.
2. **Traceability**: Every commit MUST reference an Issue ID (e.g., `#12`).
3. **Documentation**: Every user-facing change MUST be recorded in `changelog.md` with its Issue ID.
4. **Clean Closure**: Issues MUST only be closed after implementation is **verified and accepted**. For UI/UX changes, this requires visual proof (e.g., screenshots or `browser-use` verification) or explicit user confirmation.

## Procedures

### 1. Identify and Create Issue
When a requirement is identified:
- Create a GitHub Issue using `gh issue create`.
- **Trigger**: "Create issue for [title] with body [body]".
- **Action**: Use `gh issue create --title "[TITLE]" --body "[BODY]"`.
- **Output**: Capture the Issue ID for subsequent steps.

### 2. Update Changelog
Immediately after creating the issue, update `changelog.md`.
- Add a new entry under the current version (or create a new version).
- Include the Issue ID in parentheses at the end of the entry (e.g., `- Added feature X (#12)`).

### 3. Implementation and Commit
- Implement the fix or feature.
- Commit changes using a descriptive message that ends with the Issue ID.
- **Example**: `feat: implement new sidebar layout #12`

### 4. Verification and Acceptance
- **Build/Test**: Run the project's build/test suite (e.g., `npm run build`).
- **Proof of Work**: For UI changes, provide evidence or request user verification.
- **Closure**: Once verified by the agent or accepted by the user, close the issue.
- **Action**: Use `gh issue close [ID] --comment "Implemented, verified, and accepted."`.

## Resources
- **Scripts**: `scripts/gh_workflow.sh` (Helper for common operations).
