# Managing expenses

This guide covers the complete lifecycle of an expense: creating, attaching receipts, updating, submitting for approval, and checking status.

## Creating an expense

Create a new expense with `POST /expenses`:

```bash

curl -X POST https://api.fjordexpense.example.com/v1/expenses \
  -H "X-API-Key: your_api_key_here" \
  -H "Content-Type: application/json" \
  -d '{
    "category_id": "cat_travel",
    "amount": "450.00",
    "currency": "NOK",
    "date": "2025-01-10",
    "description": "Client meeting in Bergen",
    "merchant": "NSB"
  }'

```

Response:

```json
{
  "id": "exp_1a2b3c4d5e",
  "employee_id": "emp_abc123",
  "category_id": "cat_travel",
  "amount": "450.00",
  "currency": "NOK",
  "date": "2025-01-10",
  "description": "Client meeting in Bergen",
  "merchant": "NSB",
  "status": "draft",
  "receipt_ids": [],
  "created_at": "2025-01-14T10:30:00Z",
  "updated_at": "2025-01-14T10:30:00Z"
}
```

The expense is created in `draft` status. You can update it freely until it's submitted.

## Required fields

When creating an expense, you must provide:

- `category_id` - Valid expense category (see [Categories API](../api-reference.md))
- `amount` - Amount as a string with up to 2 decimal places (e.g., "450.00")
- `currency` - ISO 4217 currency code (e.g., "NOK", "EUR", "USD")
- `date` - Date of the expense in YYYY-MM-DD format
- `description` - Brief description of the expense

The `merchant` field is optional but recommended.

## Amount formatting

Always send amounts as strings with up to 2 decimal places:

- ✅ `"450.00"`, `"12.50"`, `"1000"`
- ❌ `450`, `12.5`, `"1,000.00"`

This avoids floating-point precision issues with financial data.

## Attaching receipts

After creating an expense, upload a receipt:

```bash
curl -X POST https://api.fjordexpense.example.com/v1/receipts \
  -H "X-API-Key: your_api_key_here" \
  -F "file=@receipt.pdf" \
  -F "expense_id=exp_1a2b3c4d5e"
```

You can attach multiple receipts to a single expense. Supported formats are PDF, JPEG, and PNG. Maximum file size is 10MB.

See the [Working with Receipts](receipts.md) guide for more details.

## Updating an expense

Update draft expenses with `PATCH /expenses/{expense_id}`:

```bash
curl -X PATCH https://api.fjordexpense.example.com/v1/expenses/exp_1a2b3c4d5e \
  -H "X-API-Key: your_api_key_here" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": "475.00",
    "description": "Client meeting in Bergen - updated amount"
  }'
```

Only draft expenses can be updated. Attempting to update a submitted or approved expense returns a `409 Conflict` error.

## Submitting for approval

Once an expense has all required information and at least one receipt, submit it:

```bash
curl -X POST https://api.fjordexpense.example.com/v1/expenses/exp_1a2b3c4d5e/submit \
  -H "X-API-Key: your_api_key_here"
```

The expense status changes to `submitted` and enters the approval queue. After submission, you cannot modify or delete the expense.

## Checking expense status

Retrieve an expense to check its current status:

```bash
curl https://api.fjordexpense.example.com/v1/expenses/exp_1a2b3c4d5e \
  -H "X-API-Key: your_api_key_here"
```

Possible status values:

- `draft` - Expense is being prepared, not yet submitted
- `submitted` - Awaiting approval
- `approved` - Approved by manager
- `rejected` - Rejected by manager with reason
- `paid` - Approved and reimbursed

## Listing your expenses

Retrieve all your expenses with optional filters:

```bash
# All expenses
curl https://api.fjordexpense.example.com/v1/expenses \
  -H "X-API-Key: your_api_key_here"

# Only approved expenses
curl "https://api.fjordexpense.example.com/v1/expenses?status=approved" \
  -H "X-API-Key: your_api_key_here"

# Expenses from a date range
curl "https://api.fjordexpense.example.com/v1/expenses?from_date=2025-01-01&to_date=2025-01-31" \
  -H "X-API-Key: your_api_key_here"
```

Available filters:

- `status` - Filter by expense status
- `from_date` / `to_date` - Date range filter
- `category_id` - Filter by expense category
- `limit` / `offset` - Pagination (default limit: 50, max: 100)

## Creating multiple expenses

Create multiple expenses in a single request with `POST /expenses/bulk`:

```bash
curl -X POST https://api.fjordexpense.example.com/v1/expenses/bulk \
  -H "X-API-Key: your_api_key_here" \
  -H "Content-Type: application/json" \
  -d '{
    "expenses": [
      {
        "category_id": "cat_travel",
        "amount": "450.00",
        "currency": "NOK",
        "date": "2025-01-10",
        "description": "Train to Bergen",
        "merchant": "NSB"
      },
      {
        "category_id": "cat_meals",
        "amount": "180.00",
        "currency": "NOK",
        "date": "2025-01-10",
        "description": "Client lunch",
        "merchant": "Restaurant Name"
      }
    ]
  }'
```

Maximum 100 expenses per request. The response indicates which expenses were created successfully and which failed:

```json
{
  "created": [
    {
      "id": "exp_1a2b3c4d5e",
      "status": "draft",
      ...
    }
  ],
  "failed": [
    {
      "index": 1,
      "error": "Invalid category_id"
    }
  ]
}
```

## Deleting an expense

Delete draft expenses with `DELETE /expenses/{expense_id}`:

```bash
curl -X DELETE https://api.fjordexpense.example.com/v1/expenses/exp_1a2b3c4d5e \
  -H "X-API-Key: your_api_key_here"
```

Returns `204 No Content` on success. Only draft expenses can be deleted. Attempting to delete a submitted or approved expense returns `409 Conflict`.

## Error handling

Common errors when working with expenses:

**422 Validation Error** - Invalid or missing required fields:

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
        "value": "450.5.0"
      }
    ]
  }
}
```

**409 Conflict** - Operation not allowed in current state:

```json
{
  "error": {
    "code": "conflict",
    "message": "Cannot modify expense in current status",
    "request_id": "req_8f3c1a2b"
  }
}
```

**400 Bad Request** - Missing receipt when submitting:

```json
{
  "error": {
    "code": "bad_request",
    "message": "Expense must have at least one receipt before submission",
    "request_id": "req_8f3c1a2b"
  }
}
```

Include the `request_id` when contacting support for help with specific errors.
