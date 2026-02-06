
# Getting started with the Fjord Expense API

The Fjord Expense API lets you create and manage expenses, attach receipts, submit expenses for approval, and track approvals. This topic shows how to authenticate, choose an environment, and complete a basic end-to-end flow using `curl`.

## Base URLs

Use the sandbox environment while you build and test:

- Sandbox: `https://sandbox.fjordexpense.example.com/v1`
- Production: `https://api.fjordexpense.example.com/v1`

## Authentication

All endpoints require an API key sent in the `X-API-Key` header.

1. Obtain an API key from your Fjord Expense developer portal.
2. Send the key with every request:

```bash
curl -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json" \
  https://sandbox.fjordexpense.example.com/v1/categories
```

If the API key is missing or invalid, the API returns `401 Unauthorized`.

## Content types

- Most endpoints use JSON:
    - Request header: `Content-Type: application/json`
    - Response header: `Accept: application/json`

- Receipt upload uses `multipart/form-data`.
- Some endpoints return binary content (for example, PDF downloads).

### Step 1: List categories

Categories are used when creating an expense (`category_id` is required).

```bash
curl -H "X-API-Key: $FJORD_API_KEY" \
     -H "Accept: application/json" \
     https://sandbox.fjordexpense.example.com/v1/categories
```

A typical response shape is:

```json
{
  "data": [
    { "id": "cat_travel", "name": "Travel" },
    { "id": "cat_meals", "name": "Meals" }
  ]
}
```

### Step 2: Create an expense

Create a draft expense with the minimum required fields:

- `category_id`
- `amount` (string with up to 2 decimal places, e.g. "450.00")
- `currency` (3-letter code, e.g. NOK)
- `date` (YYYY-MM-DD)
- `description`

```bash
curl -X POST \
  https://sandbox.fjordexpense.example.com/v1/expenses \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "category_id": "cat_travel",
    "amount": "450.00",
    "currency": "NOK",
    "date": "2025-01-10",
    "description": "Client meeting in Bergen",
    "merchant": "NSB"
  }'
```

The response includes the expense ID (for example, `exp_1a2b3c4d5e`). Save this for the next steps.

### Step 3: Upload a receipt and attach it to the expense

Upload a receipt file using `multipart/form-data`. If you include `expense_id`, the receipt is attached during upload.

```bash
curl -X POST \
  https://sandbox.fjordexpense.example.com/v1/receipts \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json" \
  -F "file=@/path/to/receipt.jpg" \
  -F "expense_id=exp_1a2b3c4d5e"
```

The response includes a `receipt_id` (for example, `rec_xyz789`). You can download this later using the `download` endpoint.

### Step 4: Submit the expense for approval

Submitting the expense changes the expense status from `draft` to `submitted` (assuming it passes validation).

```bash
curl -X POST \
  https://sandbox.fjordexpense.example.com/v1/expenses/exp_1a2b3c4d5e/submit \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json"
```

If the expense ID does not exist, you’ll get `404 Not Found`. If the request is invalid, you’ll get `400 Bad Request`.

### Step 5: Track approval status

Approvals are represented as their own resource. To list approvals (for example, for an approver workflow):

```bash
curl -H "X-API-Key: $FJORD_API_KEY" \
     -H "Accept: application/json" \
     "https://sandbox.fjordexpense.example.com/v1/approvals?status=pending"
```

A single approval includes `expense_id`, an embedded `expense` object, and an approval `status` (`pending`, `approved`, `rejected`).

### Approve or reject an expense (approver only)

Approve:

```bash
curl -X POST \
  https://sandbox.fjordexpense.example.com/v1/approvals/appr_def456/approve \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json"
```

Reject (with a comment, if your implementation supports it):

```bash
curl -X POST \
  https://sandbox.fjordexpense.example.com/v1/approvals/appr_def456/reject \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{ "comment": "Receipt is unreadable" }'
```

### Listing expenses with filters and pagination

The `GET /expenses` endpoint supports filtering (for example by `status`, `employee_id`, date range, and `category_id`) and uses `limit`/`offset` pagination. The response includes:

- `data`: array of expenses
- `pagination`: `{ limit, offset, total, has_more }`

**Example:**

```bash
curl -H "X-API-Key: $FJORD_API_KEY" \
     -H "Accept: application/json" \
     "https://sandbox.fjordexpense.example.com/v1/expenses?status=submitted&limit=20&offset=0"
```

## Handling errors

Error responses use a consistent shape:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed.",
    "request_id": "req_8f3c1a2b",
    "details": [
      { "field": "currency", "issue": "must be a 3-letter code" }
    ]
  }
}
```

Common HTTP statuses you should handle:

- `400 Bad Request` (validation problems)
- `401 Unauthorized` (missing/invalid API key)
- `404 Not Found` (unknown IDs)
- `429 Too Many Requests` (if you simulate rate limiting in your sample)

## Next steps

- Implement an “expense list” view using `GET /expenses` with filters and pagination.
- Add a “receipt viewer” using `GET /receipts/{receipt_id}/download` (binary response).
- Use the Reports endpoints if you want a higher-level workflow, for example, generating a PDF via `GET /reports/{report_id}/pdf`.



