# Webhooks

Webhooks let you receive real-time notifications when events occur in the Fjord Expense system. Instead of polling the API for changes, the system sends HTTP POST requests to your specified endpoint when events happen.

## Before you begin

For authentication and environment details, see [Authentication](getting-started/authentication.md).

## Use cases

Webhooks are useful for:

- Sending notifications when expenses are submitted for approval
- Triggering invoice processing when expenses are approved
- Updating external systems when invoice status changes
- Logging expense activity for audit purposes
- Automating approval workflows

## Available events

The API supports these webhook events:

- `expense.created` - New expense created
- `expense.submitted` - Expense submitted for approval
- `expense.approved` - Expense approved by manager
- `expense.rejected` - Expense rejected by manager
- `invoice.created` - New invoice generated
- `invoice.sent` - Invoice sent to client
- `invoice.paid` - Invoice marked as paid

## Webhook payload structure

When an event occurs, the API sends a POST request to your webhook URL with this payload:

```json
{
  "event": "expense.approved",
  "timestamp": "2025-01-17T14:30:00Z",
  "data": {
    "id": "exp_1a2b3c4d5e",
    "employee_id": "emp_abc123",
    "amount": "450.00",
    "currency": "NOK",
    "status": "approved"
  }
}
```

The `data` object contains the relevant resource (expense, invoice, etc.) that triggered the event.

## Register a webhook

Use `POST /webhooks` to register a webhook endpoint.

### Request

**Required fields:**

- `url` - Your endpoint URL (must be HTTPS)
- `events` - Array of event types to subscribe to

```bash
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/webhooks" \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "url": "https://your-domain.com/webhooks/fjord-expense",
    "events": ["expense.submitted", "expense.approved"]
  }'
```

### Response

The API returns `201 Created` with the webhook details:

```json
{
  "id": "hook_mno345",
  "url": "https://your-domain.com/webhooks/fjord-expense",
  "events": ["expense.submitted", "expense.approved"],
  "created_at": "2025-01-17T10:00:00Z"
}
```

Save the `id` - you'll need it to delete the webhook later.

## Your webhook endpoint

Your endpoint must:

- Accept POST requests with JSON payload
- Respond with `200 OK` status within 5 seconds
- Use HTTPS (HTTP is not supported)
- Be publicly accessible (localhost URLs are not allowed)

Example endpoint implementation (Python/Flask):

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/webhooks/fjord-expense', methods=['POST'])
def handle_webhook():
    payload = request.json
    event_type = payload.get('event')
    
    if event_type == 'expense.submitted':
        # Send notification to approvers
        notify_approvers(payload['data'])
    
    elif event_type == 'expense.approved':
        # Process approved expense
        process_expense(payload['data'])
    
    return jsonify({'status': 'received'}), 200
```

## Webhook delivery

**Timeouts:** The API waits up to 5 seconds for your endpoint to respond. If your endpoint doesn't respond within this time, the delivery is considered failed.

**Retries:** Failed deliveries are retried with exponential backoff:
- First retry: after 1 minute
- Second retry: after 5 minutes  
- Third retry: after 15 minutes

After 3 failed attempts, the webhook is automatically disabled.

**Order:** Events are sent in the order they occur, but delivery is not guaranteed to be in order due to retries.

## Security

Webhook URLs must use HTTPS. The API does not send authentication headers, so you should:

1. Use a non-guessable URL (include a secret token in the path)
2. Validate the request comes from Fjord Expense by checking the source IP (if your implementation supports this)
3. Implement idempotency - the same event may be delivered multiple times

Example URL with secret token:

```
https://your-domain.com/webhooks/fjord-expense/a8f3c2b1d4e5
```

## List webhooks

Use `GET /webhooks` to retrieve all registered webhooks:

```bash
curl -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json" \
  "https://sandbox.fjordexpense.example.com/v1/webhooks"
```

Response:

```json
{
  "data": [
    {
      "id": "hook_mno345",
      "url": "https://your-domain.com/webhooks/fjord-expense",
      "events": ["expense.submitted", "expense.approved"],
      "created_at": "2025-01-17T10:00:00Z"
    }
  ]
}
```

## Delete a webhook

Use `DELETE /webhooks/{webhook_id}` to remove a webhook:

```bash
curl -X DELETE \
  "https://sandbox.fjordexpense.example.com/v1/webhooks/hook_mno345" \
  -H "X-API-Key: $FJORD_API_KEY"
```

Returns `204 No Content` on success.

## Testing webhooks

During development, use a service like ngrok or webhook.site to create a public URL that forwards to your local environment:

```bash
# Using ngrok
ngrok http 5000

# Register the ngrok URL
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/webhooks" \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://abc123.ngrok.io/webhooks",
    "events": ["expense.submitted"]
  }'
```

Then trigger events in the sandbox environment to test your webhook handling.

## Error handling

Common errors when working with webhooks:

**422 Validation Error** - Invalid URL or event types:

```json
{
  "error": {
    "code": "validation_error",
    "message": "Invalid webhook configuration",
    "request_id": "req_8f3c1a2b",
    "details": [
      {
        "field": "url",
        "issue": "must be a valid HTTPS URL"
      }
    ]
  }
}
```

**400 Bad Request** - URL not accessible:

```json
{
  "error": {
    "code": "bad_request",
    "message": "Webhook URL is not accessible",
    "request_id": "req_8f3c1a2b"
  }
}
```

**404 Not Found** - Webhook ID does not exist when attempting to delete.

## Best practices

**Respond quickly:** Return `200 OK` immediately and process the webhook payload asynchronously. Don't perform slow operations before responding.

**Handle duplicates:** The same event may be delivered multiple times. Use the event `timestamp` and resource `id` to detect and ignore duplicates.

**Log deliveries:** Keep logs of received webhooks for debugging and auditing.

**Monitor failures:** If your endpoint is consistently failing, check your logs and fix any issues. The webhook will be automatically disabled after 3 consecutive failures.

**Use specific events:** Only subscribe to events you need. This reduces unnecessary traffic to your endpoint.
