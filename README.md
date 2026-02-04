# Fjord Expense API documentation

Playground and demo API doc site for testing out ideas etc.

Using MkDocs and slightly customized Material theme.

Using Vale to check against Microsoft style guidelines.

Using Claude Code for rules checking prior to pushing changes to remote. 

## Project structure

```
.
├── mkdocs.yml                          # MkDocs configuration
├── fjord-expense-api_revised.yaml      # OpenAPI specification
├── docs/
│   ├── index.md                        # Home page
│   ├── api-reference.md                # API reference (embeds OpenAPI spec)
│   ├── errors.md                       # Error handling guide
│   ├── getting-started/
│   │   ├── authentication.md           # Authentication guide
│   │   ├── quickstart.md              # Quick start
│   │   └── rate-limits.md             # Rate limits
│   ├── guides/
│   │   ├── expenses.md                # Complete expense guide
│   │   ├── receipts.md                # Receipts guide 
│   │   ├── approvals.md               # Approvals guide 
│   │   └── invoicing.md               # Invoicing guide 
│   └── webhooks.md                     # Webhooks guide 
```

## Dependencies:

- mkdocs-material
- mkdocs-swagger-ui-tag

## What's included

**Complete:**
- OpenAPI specification (18 endpoints)
- Home page with overview
- Authentication documentation
- Error handling documentation
- Complete expense management guide
- API reference page (auto-generated)

## Notes

This is a demo project using a fictional but realistic API.
