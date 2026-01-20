# Working with receipts

Receipts provide proof of expenses and are required before submitting expenses for approval. This guide covers uploading receipts, attaching them to expenses, downloading receipt files, and managing receipt metadata.

## Before you begin

For authentication and environment details, see [Authentication](../getting-started/authentication.md).

## Supported file formats

The API accepts these receipt formats:

- **Images:** JPEG (`.jpg`, `.jpeg`), PNG (`.png`)
- **Documents:** PDF (`.pdf`)

Maximum file size: **10MB**

## Upload a receipt

Use `POST /receipts` to upload a receipt file. You can optionally attach it to an expense during upload.

### Upload without attaching

```bash
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/receipts" \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json" \
  -F "file=@/path/to/receipt.pdf"
```

### Upload and attach to expense

```bash
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/receipts" \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json" \
  -F "file=@/path/to/receipt.pdf" \
  -F "expense_id=exp_1a2b3c4d5e"
```

When you include `expense_id`, the receipt is immediately associated with that expense.

### Response

```json
{
  "id": "rec_xyz789",
  "expense_id": "exp_1a2b3c4d5e",
  "filename": "receipt_2025-01-10.pdf",
  "content_type": "application/pdf",
  "size": 245678,
  "url": "https://api.fjordexpense.example.com/v1/receipts/rec_xyz789/download",
  "uploaded_at": "2025-01-17T14:30:00Z"
}
```

Save the `id` - you'll need it to download or delete the receipt.

## Get receipt metadata

Use `GET /receipts/{receipt_id}` to retrieve receipt details without downloading the file:

```bash
curl -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json" \
  "https://sandbox.fjordexpense.example.com/v1/receipts/rec_xyz789"
```

This returns the same metadata structure as the upload response, showing the filename, size, content type, and associated expense.

## Download a receipt file

Use `GET /receipts/{receipt_id}/download` to download the original receipt file:

```bash
curl -H "X-API-Key: $FJORD_API_KEY" \
  "https://sandbox.fjordexpense.example.com/v1/receipts/rec_xyz789/download" \
  --output receipt.pdf
```

The response is the binary file content with the appropriate `Content-Type` header (`image/jpeg`, `image/png`, or `application/pdf`).

### Display in browser

To display the receipt in a browser, use the download URL directly:

```
https://api.fjordexpense.example.com/v1/receipts/rec_xyz789/download
```

Include your API key in the request header when accessing this URL programmatically.

## Multiple receipts per expense

An expense can have multiple receipts attached. This is useful when:

- A single expense involves multiple transactions (for example, hotel and meals)
- The original receipt is unclear and a clearer copy is added
- Supporting documentation is needed (for example, approval emails)

Upload each receipt separately with the same `expense_id`:

```bash
# Upload first receipt
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/receipts" \
  -H "X-API-Key: $FJORD_API_KEY" \
  -F "file=@hotel_receipt.pdf" \
  -F "expense_id=exp_1a2b3c4d5e"

# Upload second receipt
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/receipts" \
  -H "X-API-Key: $FJORD_API_KEY" \
  -F "file=@meal_receipt.pdf" \
  -F "expense_id=exp_1a2b3c4d5e"
```

Both receipts will appear in the expense's `receipt_ids` array.

## Delete a receipt

Use `DELETE /receipts/{receipt_id}` to remove a receipt:

```bash
curl -X DELETE \
  "https://sandbox.fjordexpense.example.com/v1/receipts/rec_xyz789" \
  -H "X-API-Key: $FJORD_API_KEY"
```

Returns `204 No Content` on success.

**Important:** You cannot delete receipts attached to submitted, approved, or rejected expenses. The expense must be in `draft` status. Attempting to delete a receipt from a submitted expense returns `409 Conflict`.

## Receipt requirements before submission

Before submitting an expense for approval using `POST /expenses/{expense_id}/submit`, the expense must have at least one receipt attached.

If you attempt to submit an expense without receipts, you'll receive this error:

```json
{
  "error": {
    "code": "bad_request",
    "message": "Expense must have at least one receipt before submission",
    "request_id": "req_8f3c1a2b"
  }
}
```

## File size and format validation

**413 Payload Too Large** - File exceeds 10MB:

```json
{
  "error": {
    "code": "payload_too_large",
    "message": "File size exceeds 10MB limit",
    "request_id": "req_8f3c1a2b"
  }
}
```

**422 Validation Error** - Unsupported file format:

```json
{
  "error": {
    "code": "validation_error",
    "message": "Invalid file format",
    "request_id": "req_8f3c1a2b",
    "details": [
      {
        "field": "file",
        "issue": "must be JPEG, PNG, or PDF"
      }
    ]
  }
}
```

## Working with receipt metadata

The expense object includes a `receipt_ids` array showing all attached receipts:

```bash
curl -H "X-API-Key: $FJORD_API_KEY" \
  "https://sandbox.fjordexpense.example.com/v1/expenses/exp_1a2b3c4d5e"
```

Response excerpt:

```json
{
  "id": "exp_1a2b3c4d5e",
  "amount": "450.00",
  "currency": "NOK",
  "receipt_ids": ["rec_xyz789", "rec_abc123"],
  ...
}
```

To get details for each receipt, call `GET /receipts/{receipt_id}` for each ID, or download them directly using the download endpoint.

## Error handling

Common errors when working with receipts:

**400 Bad Request** - Missing file in upload:

```json
{
  "error": {
    "code": "bad_request",
    "message": "No file provided",
    "request_id": "req_8f3c1a2b"
  }
}
```

**404 Not Found** - Receipt ID does not exist:

```json
{
  "error": {
    "code": "not_found",
    "message": "Receipt not found",
    "request_id": "req_8f3c1a2b"
  }
}
```

**409 Conflict** - Cannot delete receipt from submitted expense:

```json
{
  "error": {
    "code": "conflict",
    "message": "Cannot delete receipt from submitted expense",
    "request_id": "req_8f3c1a2b"
  }
}
```

## Best practices

**Upload immediately:** Upload receipts as soon as expenses are created. Don't wait until submission time to avoid delays.

**Use descriptive filenames:** Name files clearly (for example, `hotel_2025-01-10.pdf`) to make them easier to identify later.

**Verify uploads:** After uploading, verify the receipt appears in the expense's `receipt_ids` array.

**Keep originals:** The API stores receipts indefinitely, but keep original receipts according to your organization's retention policy.

**Check file size:** If your images are too large, compress them before upload. Most phones capture high-resolution images that can be safely reduced to under 2MB without losing readability.

**Use PDF for documents:** If you have multiple pages or want to preserve document formatting, upload as PDF rather than multiple images.
