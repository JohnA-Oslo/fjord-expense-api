# Rate limits

The Fjord Expense API implements rate limiting to ensure fair usage and maintain service quality for all users. This guide explains how rate limits work, how to handle rate limit errors, and best practices for staying within limits.

## Rate limit tiers

Rate limits are applied per API key:

| Environment | Requests per minute | Requests per hour |
|-------------|-------------------|------------------|
| Sandbox | 100 | 2,000 |
| Production | 300 | 10,000 |

These limits apply to all endpoints combined. For example, 50 expense creation requests and 50 receipt uploads count as 100 requests toward your per-minute limit.

## Rate limit headers

Every API response includes headers showing your current rate limit status:

```
X-RateLimit-Limit: 300
X-RateLimit-Remaining: 245
X-RateLimit-Reset: 1705503600
```

- `X-RateLimit-Limit` - Maximum requests allowed in the current window
- `X-RateLimit-Remaining` - Requests remaining in the current window
- `X-RateLimit-Reset` - Unix timestamp when the limit resets

Use these headers to track your usage and avoid hitting limits.

## Rate limit exceeded response

When you exceed the rate limit, the API returns `429 Too Many Requests`:

```json
{
  "error": {
    "code": "rate_limit_exceeded",
    "message": "Too many requests",
    "request_id": "req_8f3c1a2b"
  }
}
```

The response also includes a `Retry-After` header indicating how many seconds to wait before retrying:

```
HTTP/1.1 429 Too Many Requests
Retry-After: 30
X-RateLimit-Limit: 300
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1705503600
```

## Handling rate limits

### Check headers before making requests

Monitor the `X-RateLimit-Remaining` header to see how many requests you have left:

```python
import requests

response = requests.get(
    "https://api.fjordexpense.example.com/v1/expenses",
    headers={"X-API-Key": api_key}
)

remaining = int(response.headers.get('X-RateLimit-Remaining', 0))
if remaining < 10:
    print(f"Warning: Only {remaining} requests remaining")
```

### Implement exponential backoff

When you receive a `429` response, wait before retrying. Use exponential backoff to gradually increase wait times:

```python
import time
import requests

def make_request_with_retry(url, headers, max_retries=3):
    for attempt in range(max_retries):
        response = requests.get(url, headers=headers)
        
        if response.status_code == 429:
            retry_after = int(response.headers.get('Retry-After', 60))
            wait_time = retry_after * (2 ** attempt)  # Exponential backoff
            print(f"Rate limited. Waiting {wait_time} seconds...")
            time.sleep(wait_time)
            continue
        
        return response
    
    return response  # Return last response after all retries
```

### Respect the Retry-After header

Always check the `Retry-After` header when you receive a `429` response. This tells you exactly how long to wait:

```python
if response.status_code == 429:
    retry_after = int(response.headers.get('Retry-After', 60))
    time.sleep(retry_after)
    # Retry request
```

## Best practices

**Batch operations:** Use bulk endpoints like `POST /expenses/bulk` to create multiple resources in a single request rather than making multiple individual requests.

**Cache responses:** Cache expense categories, which change infrequently, rather than fetching them with every operation.

**Implement request queuing:** Queue requests in your application and process them at a controlled rate to avoid sudden spikes.

**Monitor your usage:** Track the `X-RateLimit-Remaining` header and adjust your request rate proactively.

**Use webhooks:** Instead of polling for updates, use webhooks to receive notifications when events occur. This dramatically reduces the number of API requests needed.

**Spread requests over time:** If you need to process large batches of data, distribute requests evenly across the hour rather than sending them all at once.

## Rate limit examples

### Example 1: Checking remaining requests

```bash
curl -i -H "X-API-Key: $FJORD_API_KEY" \
  "https://api.fjordexpense.example.com/v1/expenses" \
  | grep X-RateLimit
```

Output:

```
X-RateLimit-Limit: 300
X-RateLimit-Remaining: 245
X-RateLimit-Reset: 1705503600
```

### Example 2: Handling rate limit in Python

```python
import requests
import time

def fetch_all_expenses(api_key):
    expenses = []
    offset = 0
    limit = 50
    
    while True:
        response = requests.get(
            f"https://api.fjordexpense.example.com/v1/expenses",
            params={"limit": limit, "offset": offset},
            headers={"X-API-Key": api_key}
        )
        
        # Check rate limit
        if response.status_code == 429:
            retry_after = int(response.headers.get('Retry-After', 60))
            print(f"Rate limited. Waiting {retry_after} seconds...")
            time.sleep(retry_after)
            continue
        
        data = response.json()
        expenses.extend(data['data'])
        
        # Check if we need to slow down
        remaining = int(response.headers.get('X-RateLimit-Remaining', 0))
        if remaining < 50:
            print(f"Throttling: {remaining} requests remaining")
            time.sleep(2)  # Add delay to avoid hitting limit
        
        # Check if there are more results
        if not data['pagination']['has_more']:
            break
        
        offset += limit
    
    return expenses
```

### Example 3: Bulk operations to reduce requests

Instead of creating expenses one at a time:

```bash
# BAD: 100 requests for 100 expenses
for i in {1..100}; do
  curl -X POST "https://api.fjordexpense.example.com/v1/expenses" \
    -H "X-API-Key: $FJORD_API_KEY" \
    -d '{"category_id":"cat_travel", ...}'
done
```

Use the bulk endpoint:

```bash
# GOOD: 1 request for 100 expenses
curl -X POST "https://api.fjordexpense.example.com/v1/expenses/bulk" \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "expenses": [
      {"category_id":"cat_travel", ...},
      {"category_id":"cat_meals", ...},
      ...
    ]
  }'
```

## Requesting higher limits

If your application requires higher rate limits, contact support at api@fjordexpense.example.com with:

- Your API key ID (not the key itself)
- Current usage patterns
- Business justification for higher limits
- Expected request volume

Requests for increased limits are reviewed on a case-by-case basis.

## Rate limit FAQs

**Q: Are rate limits per user or per API key?**  
A: Rate limits are applied per API key. Each API key has its own independent rate limit.

**Q: Do failed requests count toward the rate limit?**  
A: Yes. All requests count toward your rate limit, including those that return errors (400, 401, 404, etc.).

**Q: Can I see my historical rate limit usage?**  
A: No. Rate limit headers show only the current window. Implement your own logging if you need historical tracking.

**Q: What happens if I consistently hit rate limits?**  
A: Consistent rate limit violations may result in temporary suspension. Use the best practices above to stay within limits.

**Q: Are different endpoints weighted differently?**  
A: No. All endpoints count equally toward your rate limit. A simple GET request counts the same as a complex POST request.
