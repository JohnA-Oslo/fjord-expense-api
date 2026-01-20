# Fjord Expense API Documentation Project

## Project Overview
Demonstration API documentation for an expense management system.

## Documentation Standards

### Style Guide Compliance
- Use "because" instead of "since" for causation
- Lists must have parallel structure
- Error codes are lowercase: `validation_error`
- Amounts are strings: `"450.00"`

### Pre-commit Checklist
1. Run `vale docs/` for style checking
2. Verify all internal links work
3. Check code examples are valid
4. Ensure error format matches OpenAPI spec

## Common Issues
- Headings should be dark blue (#003d82)
- Error responses must include `request_id`
- All guides should link to Authentication page