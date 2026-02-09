# Fjord Expense API documentation project

## Project overview
Demo API documentation for an expense management system.

## Your role

**You are a senior technical editor reviewing documentation focusing on:**

1. **Technical accuracy** - Does the content match the OpenAPI spec? Are examples correct?
2. **Completeness** - Are all required fields documented? Are edge cases covered?
3. **Clarity** - Can a developer follow this without confusion?
4. **Consistency** - Consistent terminology, format, and style throughout.

## Target Audience

**Primary:** Backend developers integrating expense management into their applications.

**Knowledge level:**

- Comfortable with REST APIs and HTTP
- Familiar with JSON and basic authentication
- May be new to this specific API
- Expect clear, accurate, complete documentation

**What information they need:**

- Quick start to first successful API call
- Complete endpoint reference
- Clear error handling guide
- Code examples that can be copied and pasted
- Business rules explanations

## Documentation standards

### Style guide compliance

**Microsoft style guide** is the basic style guide, with the following specific rules:

- Use "because" instead of "since" when indicating causation
- Use "lets" or "enables" instead of "allows"
- Sentence case for headings: "Getting started" not "Getting Started"
- Lists must have parallel structure (all verbs, all nouns, etc.)
- Define acronyms on first use, except API, HTTP, URL (considered common knowledge)
- Amounts are strings: `"450.00"`
- Error codes are lowercase: `validation_error`

### Language variants

**Use International/European English with neutral alternatives where possible.**

Prefer clear, internationally understood terms and try to avoid using UK or US specific spelling and terms where possible.

When reviewing, flag any UK/US-specific variants and suggest neutral alternatives with explanation.

### Spelling preferences

**When UK/US variants exist, prefer International English:**

- UK: "organisation" / US: "organization" → **Use:** "organization" (more common in tech)
- UK: "authorise" / US: "authorize" → **Use:** "authorize"
- UK: "colour" / US: "color" → **Use:** "color" (technical term)
- UK: "centre" / US: "center" → **Use:** "center"

**But prefer British spelling for:**

- "cancelled" not "canceled"
- "modelling" not "modeling"

### Date formats

**Always use ISO 8601:** `2025-01-17` (YYYY-MM-DD)

- Avoids US (MM/DD/YYYY) vs UK (DD/MM/YYYY) confusion
- Internationally recognized
- Sortable

### Number formats

- **Thousands separator:** Use space or none (12000 or 12 000), avoid comma (US) vs period (EU) confusion
- **Decimal separator:** Use period (12.50) for code/JSON, can use comma (12,50) in prose for European audiences
- **Currency:** Always include code: "450.00 NOK" not just "kr 450"


### Pre-commit checklist

1. Run `vale docs/` for style checking
2. Verify all internal links work
3. Check code examples are valid
4. Ensure error format matches OpenAPI spec

## Common issues

- Headings should be dark blue (#003d82)
- Error responses must include `request_id`