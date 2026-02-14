---
name: api-doc-reviewer
description: Use when reviewing, writing, or improving API reference documentation. 
Checks completeness against OpenAPI spec, validates examples, and flags common 
documentation gaps.
---

# API Documentation review

## Endpoint documentation checklist

For each endpoint, verify:

1. HTTP method and path clearly stated
2. One-line summary in plain English
3. All path parameters documented with type and description
4. All query parameters documented with type, default value, and constraints
5. Request body schema with required/optional fields clearly marked
6. At least one complete request example (curl)
7. Success response documented with status code and schema
8. At least one complete response example
9. All error responses documented (401, 403, 404, 409, 422, 429, 500)
10. Business rules and constraints explicitly stated
11. State transitions explained where relevant

## Error response validation

Every error example must:

- Use correct HTTP status code for the error type
- Use lowercase error code: `validation_error` not `VALIDATION_ERROR`
- Include `request_id` field
- Include `details` array for validation errors (not object)
- Match this exact structure:
```json
{
  "error": {
    "code": "validation_error",
    "message": "Human readable message",
    "request_id": "req_8f3c1a2b",
    "details": [
      {
        "field": "amount",
        "issue": "must be greater than 0",
        "value": null
      }
    ]
  }
}
```

## Code example validation

curl examples must include:

- Correct HTTP method (`-X POST`, `-X PATCH`, `-X DELETE`)
- `X-API-Key: $FJORD_API_KEY` header
- `Accept: application/json` header
- `Content-Type: application/json` for POST/PATCH requests
- Sandbox URL: `https://sandbox.fjordexpense.example.com/v1/`
- Complete, copy-pastable command (no truncation)

## Common gaps to flag

- Parameters documented without type or constraints
- Missing error responses (especially 401, 404)
- Examples that don't match the schema
- Amounts formatted as numbers instead of strings
- Currency codes missing or wrong format
- State transitions not explained
- Business rules implied but not stated explicitly
- Internal links using wrong relative path depth

## Output format

When reviewing existing documentation:
- List each issue with file and line reference where possible
- Explain why it's an issue
- Provide suggested fix

When writing from scratch:
- Follow completeness checklist for every endpoint
- Include all required examples
- State all business rules explicitly