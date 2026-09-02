# Fjord Expense API Documentation

This is a demo API documentation project using modern technical writing practices and doc tooling.

**[View live site →](https://johna-oslo.github.io/fjord-expense-api/)**

## What this includes

- **API documentation** - Documentation for a fictional expense management API
- **OpenAPI 3.1 specification** - Based on fictional API spec with 18 endpoints
- **MkDocs Material** - MkDocs static site generation with custom styling
- **Quality automation** - Layered approach using deterministic and AI tools
- **CI/CD pipeline** - GitHub Actions for automated validation and deployment
- **Enterprise workflow** - Automated quality checks and deployment practices

## Quality workflow

**Local review (pre-commit):**

- Claude Code with custom Skills for "peer" review
- Flags clarity issues, parallel structure problems, technical accuracy
- Reviews against project-specific standards in CLAUDE.md

**Automated checks (CI/CD):**

- Vale checks for Microsoft style guide compliance
- Lychee checks all internal and external links
- MkDocs strict mode catches broken references
- Runs on every push to main branch

This layered approach combines fast deterministic checks (Vale, Lychee) with AI analysis (Claude) for additional quality assurance in addition to human review and assessment.

## Project structure

```text
.
├── .github/workflows/docs.yml          # CI/CD pipeline
├── .claude/skills/                     # Agent Skills for documentation review
├── mkdocs.yml                          # MkDocs configuration
├── CLAUDE.md                           # Claude Code project instructions
├── fjord-expense-api-revised.yaml      # OpenAPI 3.1 specification
├── docs/
│   ├── index.md                        # Home page
│   ├── api-reference.md                # API reference (embeds OpenAPI spec)
│   ├── errors.md                       # Error handling guide
│   ├── webhooks.md                     # Webhooks guide
│   ├── getting-started/
│   │   ├── quickstart.md               # Quick start tutorial
│   │   ├── authentication.md           # Authentication guide
│   │   └── rate-limits.md              # Rate limiting guide
│   └── guides/
│       ├── expenses.md                 # Expense management guide
│       ├── receipts.md                 # Receipt handling guide
│       ├── approvals.md                # Approval workflows guide
│       └── invoicing.md                # Invoicing guide
```

## Local development

**Prerequisites:**

```bash
pip install mkdocs-material mkdocs-swagger-ui-tag
```

**Run locally:**

```bash
mkdocs serve
```

View at http://localhost:8000

**Quality checks:**

```bash
# Run all checks
check-docs.bat

# Individual tools
vale docs/
lychee docs/**/*.md
mkdocs build --strict
```

## Deployment

Automated deployment to GitHub Pages via GitHub Actions on push to `main`.

Manual deployment:

```bash
mkdocs gh-deploy
```

## Notes

This is a demo project used for demo and testing purposes. The Fjord Expense API is fictional but realistic.
