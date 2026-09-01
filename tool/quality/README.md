# Quality Hooks

Install repository-managed Git hooks:

```bash
make setup-hooks
```

The pre-commit hook checks formatting for staged Dart files and runs workspace
analysis. The commit-message hook enforces Conventional Commits with a subject
of at most 72 characters.

Hooks are a local convenience, not the security boundary. CI must run analyze,
tests, and code-generation checks independently.
