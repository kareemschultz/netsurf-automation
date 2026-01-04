# Contributing to Netsurf Automation

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a feature branch from `main`

## Branch Naming

Use descriptive branch names with prefixes:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feature/` | New features | `feature/whatsapp-templates` |
| `fix/` | Bug fixes | `fix/webhook-timeout` |
| `docs/` | Documentation | `docs/deployment-guide` |
| `refactor/` | Code refactoring | `refactor/workflow-structure` |
| `chore/` | Maintenance tasks | `chore/update-dependencies` |

## Commit Messages

Follow conventional commits format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `refactor` - Code refactoring
- `test` - Adding tests
- `chore` - Maintenance

**Examples:**
```
feat(workflows): add customer sentiment detection
fix(chatwoot): resolve webhook authentication issue
docs(deployment): update Docker requirements
```

## Pull Request Process

1. **Create PR** with descriptive title and body
2. **Link issues** - Reference related issues with `Closes #123`
3. **Wait for CI** - Ensure all checks pass
4. **Request review** - Tag appropriate reviewers
5. **Address feedback** - Make requested changes
6. **Merge** - Squash and merge when approved

## Code Style

### Shell Scripts
- Use `shellcheck` for linting
- Add descriptive comments
- Use `set -euo pipefail` for safety
- Quote all variables

### JSON (n8n Workflows)
- Valid JSON syntax
- Consistent indentation (2 spaces)
- Meaningful node names

### SQL
- Uppercase SQL keywords
- Lowercase identifiers
- Use meaningful table/column names

### Markdown
- One sentence per line (easier diffs)
- Use reference-style links for repeated URLs
- Include alt text for images

## Testing

Before submitting:

1. Run preflight check: `./scripts/00-preflight-check.sh`
2. Validate Docker config: `docker compose config`
3. Test locally if possible

## Security

- **Never commit secrets** - Use `.env` files
- **Report vulnerabilities** - Contact maintainers privately
- **Review dependencies** - Check for known vulnerabilities

## Questions?

Open a GitHub issue with the `question` label.
