# Invoicing

The invoicing endpoints let you generate invoices from approved expenses, retrieve invoice details, and send invoices to clients.

## Before you begin

Invoices are generated from approved expenses. You'll typically list expenses with `status=approved`, then create an invoice using the returned expense IDs.

For authentication and environment details, see [Authentication](../getting-started/authentication.md).

## Invoice lifecycle

Invoice `status` values:

- `draft` (created, not sent)
- `sent` (sent to client)
- `paid` (marked paid)
- `overdue` (past due date, automatically set when `due_date` is passed and `status` is still sent)
- `cancelled` (cancelled)

The API returns `409 Conflict` if you attempt an invalid state transition (for example, sending an invoice that is already `sent` or `cancelled`).

## List approved expenses to invoice

Use `GET /expenses?status=approved` to find expenses ready to invoice. See [Managing Expenses](expenses.md#listing-your-expenses) for filtering and pagination details.

## Create an invoice

Use `POST /invoices` to generate an invoice from approved expenses for a specific client.

**Note:** An expense can only be included in one invoice. If you attempt to create an invoice with an expense that's already been invoiced, the API returns `422 Unprocessable Entity` with details indicating which expenses are unavailable.

The error response in this case looks like this:

```json
{
  "error": {
    "code": "validation_error",
    "message": "One or more expenses have already been invoiced",
    "request_id": "req_8f3c1a2b",
    "details": [
      {
        "field": "expense_ids",
        "issue": "expense exp_1a2b3c4d5e is already included in invoice inv_abc123"
      }
    ]
  }
}
```

### Request

**Required fields:**

- `client_id`
- `expense_ids` (one or more expense IDs)

**Optional fields:**

- `due_date` (YYYY-MM-DD)
- `notes`

```bash
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/invoices" \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "client_id": "cli_12345",
    "expense_ids": ["exp_1a2b3c4d5e", "exp_6f7g8h9i0j"],
    "due_date": "2025-02-15",
    "notes": "Consulting services - January"
  }'
```

### Response

The API returns `201 Created` with an `Invoice` object.

**Key fields:**

- `id`
- `invoice_number`
- `total_amount` (string, up to 2 decimals)
- `currency` (ISO 4217 code, for example NOK)
- `status`
- `expense_ids`

The `total_amount` is calculated as the sum of all included expense amounts in the specified currency. All expenses must use the same currency.

Example:

```json
{
  "id": "inv_jkl012",
  "invoice_number": "INV-2025-001",
  "client_id": "cli_12345",
  "total_amount": "1250.50",
  "currency": "NOK",
  "due_date": "2025-02-15",
  "status": "draft",
  "expense_ids": ["exp_1a2b3c4d5e", "exp_6f7g8h9i0j"],
  "created_at": "2025-01-17T10:00:00Z",
  "sent_at": null,
  "paid_at": null
}
```
If validation fails, the API returns `422 Unprocessable Entity`.

## List invoices

Use `GET /invoices` to retrieve invoices. You can filter by `client_id` and `status`.

```bash
curl -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json" \
  "https://sandbox.fjordexpense.example.com/v1/invoices?status=draft&limit=50&offset=0"
```

A successful response returns:

- `data`: array of invoices
- `pagination`: { limit, offset, total, has_more }

## Get an invoice

Use `GET /invoices/{invoice_id}` to retrieve details for a specific invoice.

```bash
curl -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json" \
  "https://sandbox.fjordexpense.example.com/v1/invoices/inv_jkl012"
```

If the invoice ID does not exist, the API returns `404 Not Found`.

## Send an invoice

Use `POST /invoices/{invoice_id}/send` to send an invoice to the client (for example, by email).

```bash
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/invoices/inv_jkl012/send" \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json"
```

The API returns `200 OK` with the updated invoice. After sending, status is typically `sent` and `sent_at` is set.

If the invoice cannot be sent due to its current state, the API returns `409 Conflict`.


## Error handling

These endpoints commonly return:

- `400 Bad Request` (invalid request format or parameters)
- `401 Unauthorized` (missing/invalid API key)
- `403 Forbidden` (insufficient permissions)
- `404 Not Found` (unknown `invoice_id`)
- `409 Conflict` (invalid state transition, for example sending an invoice twice)
- `422 Unprocessable Entity` (validation error for request bodies)
- `429 Too Many Requests` (rate limiting, if enabled)
- `500 Internal Server Error`

Error responses use this shape:

```json
{
  "error": {
    "code": "validation_error",
    "message": "Request validation failed.",
    "request_id": "req_8f3c1a2b",
    "details": [
      { "field": "due_date", "issue": "must be a valid date" }
    ]
  }
}
```


