# Error Handling

The API uses standard HTTP status codes and returns structured error responses in JSON format.

## Error Response Format

All error responses follow this structure:

```json
{
  "error": {
    "code": "validation_error",
    "message": "Invalid input data",
    "request_id": "req_8f3c1a2b",
    "details": [
      {
        "field": "amount",
        "issue": "must match pattern ^\\d+(\\.\\d{1,2})?$",
        "value": "invalid"
      }
    ]
  }
}
```

- `code` - Machine-readable error code (e.g., `validation_error`)
- `message` - Human-readable error description
- `request_id` - Correlation ID for debugging and support
- `details` - Optional array of field-level error information

## HTTP Status Codes

### 2xx Success

**200 OK** - Request succeeded

**201 Created** - Resource created successfully

**204 No Content** - Request succeeded with no response body (typically for DELETE operations)

### 4xx Client Errors

**400 Bad Request** - Invalid request (malformed JSON, missing required parameters)

```json
{
  "error": {
    "code": "bad_request",
    "message": "Invalid request parameters",
    "request_id": "req_8f3c1a2b"
  }
}
```

**401 Unauthorized** - Missing or invalid API key

```json
{
  "error": {
    "code": "unauthorized",
    "message": "Invalid or missing API key",
    "request_id": "req_8f3c1a2b"
  }
}
```

**403 Forbidden** - Valid credentials but insufficient permissions

```json
{
  "error": {
    "code": "forbidden",
    "message": "You do not have access to this resource",
    "request_id": "req_8f3c1a2b"
  }
}
```

**404 Not Found** - Resource does not exist

```json
{
  "error": {
    "code": "not_found",
    "message": "Resource not found",
    "request_id": "req_8f3c1a2b"
  }
}
```

**409 Conflict** - Request conflicts with current resource state

```json
{
  "error": {
    "code": "conflict",
    "message": "Cannot modify expense in current status",
    "request_id": "req_8f3c1a2b"
  }
}
```

Common causes:
- Attempting to update a submitted expense
- Deleting an expense that's already approved
- Submitting an expense without required receipts

**413 Payload Too Large** - Request body or file upload exceeds size limits

```json
{
  "error": {
    "code": "payload_too_large",
    "message": "File size exceeds 10MB limit",
    "request_id": "req_8f3c1a2b"
  }
}
```

**422 Unprocessable Entity** - Request is well-formed but contains validation errors

```json
{
  "error": {
    "code": "validation_error",
    "message": "Invalid input data",
    "request_id": "req_8f3c1a2b",
    "details": [
      {
        "field": "amount",
        "issue": "must be greater than 0",
        "value": "-10.00"
      },
      {
        "field": "currency",
        "issue": "must be a valid ISO 4217 currency code",
        "value": "DOLLAR"
      }
    ]
  }
}
```

**429 Too Many Requests** - Rate limit exceeded

```json
{
  "error": {
    "code": "rate_limit_exceeded",
    "message": "Too many requests",
    "request_id": "req_8f3c1a2b"
  }
}
```

See [Rate Limits](getting-started/rate-limits.md) for details on rate limiting.

### 5xx Server Errors

**500 Internal Server Error** - Unexpected server error

```json
{
  "error": {
    "code": "internal_server_error",
    "message": "An unexpected error occurred",
    "request_id": "req_8f3c1a2b"
  }
}
```

If you encounter persistent 5xx errors, contact support with the `request_id`.

## Error Codes Reference

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `bad_request` | 400 | Invalid request format or parameters |
| `unauthorized` | 401 | Missing or invalid authentication |
| `forbidden` | 403 | Insufficient permissions |
| `not_found` | 404 | Resource does not exist |
| `conflict` | 409 | Operation conflicts with resource state |
| `payload_too_large` | 413 | Request exceeds size limits |
| `validation_error` | 422 | Input validation failed |
| `rate_limit_exceeded` | 429 | Too many requests |
| `internal_server_error` | 500 | Server error |

## Best Practices

**Check HTTP status codes first**

Always check the HTTP status code before parsing the response body. A `2xx` status indicates success; `4xx` or `5xx` indicates an error.

**Parse error details**

For validation errors (`422`), check the `details` array for field-level information about what went wrong.

**Log request IDs**

Always log the `request_id` from error responses. Include it when contacting support to help diagnose issues quickly.

**Retry logic**

For `429` (rate limit) and `5xx` errors, implement exponential backoff retry logic:

```python
import time
import requests

def make_request_with_retry(url, headers, max_retries=3):
    for attempt in range(max_retries):
        response = requests.get(url, headers=headers)
        
        if response.status_code == 429 or response.status_code >= 500:
            wait_time = 2 ** attempt  # Exponential backoff
            time.sleep(wait_time)
            continue
            
        return response
    
    return response  # Return last response after all retries
```

**Handle validation errors gracefully**

Present field-level validation errors to users:

```python
def handle_error(response):
    error_data = response.json()["error"]
    
    if error_data["code"] == "validation_error":
        for detail in error_data.get("details", []):
            print(f"{detail['field']}: {detail['issue']}")
    else:
        print(f"Error: {error_data['message']}")
    
    print(f"Request ID: {error_data['request_id']}")
```

## Getting Help

If you encounter errors you cannot resolve:

1. Check the error `code` and `message` in the response
2. Review the relevant API documentation
3. Verify your request matches the examples in this documentation
4. Contact support with the `request_id` from the error response
