# Authentication

All API requests require authentication using an API key.

## Obtaining an API key

API keys are generated through the Fjord Expense dashboard:

1. Log in to your account at `https://app.fjordexpense.example.com`
2. Navigate to **Settings → API Keys**
3. Click **Generate New Key**
4. Copy the key immediately - it will only be shown once

Store your API key securely. Do not commit it to version control or expose it in client-side code.

## Using your API key

Include your API key in the `X-API-Key` header with every request:

```bash
curl https://api.fjordexpense.example.com/v1/expenses \
  -H "X-API-Key: your_api_key_here"
```

```python
import requests

headers = {
    "X-API-Key": "your_api_key_here"
}

response = requests.get(
    "https://api.fjordexpense.example.com/v1/expenses",
    headers=headers
)
```

```javascript
const response = await fetch(
  'https://api.fjordexpense.example.com/v1/expenses',
  {
    headers: {
      'X-API-Key': 'your_api_key_here'
    }
  }
);
```

## Authentication errors

If authentication fails, you'll receive a `401 Unauthorized` response:

```json
{
  "error": {
    "code": "unauthorized",
    "message": "Invalid or missing API key",
    "request_id": "req_8f3c1a2b"
  }
}
```

Common causes:

- Missing `X-API-Key` header
- Invalid or expired API key
- API key revoked in dashboard

## API key permissions

API keys inherit the permissions of the user who created them. An employee's API key can only access their own expenses, while a manager's key can access expenses from their team members.

## Rotating API keys

Rotate your API keys regularly:

1. Generate a new API key in the dashboard
2. Update your application to use the new key
3. Verify the new key works correctly
4. Revoke the old key in the dashboard

We recommend rotating keys at least every 90 days.

## Sandbox API keys

Sandbox API keys are separate from production keys. Generate sandbox keys specifically for testing at `https://sandbox.fjordexpense.example.com`.
