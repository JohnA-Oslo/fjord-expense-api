# Approval workflows

The approval endpoints let managers review and approve or reject submitted expenses. This guide covers listing pending approvals, approving expenses, and rejecting expenses with reasons.

## Before you begin

Approvals are only accessible to users with manager permissions. Employee users can submit expenses for approval but cannot access approval endpoints.

For authentication and environment details, see [Authentication](../getting-started/authentication.md).

## Approval lifecycle

When an employee submits an expense using `POST /expenses/{expense_id}/submit`, an approval record is created with `status: pending`. The expense remains in `submitted` status until the approval is processed.

Approval `status` values:

- `pending` - Awaiting manager decision
- `approved` - Manager approved the expense
- `rejected` - Manager rejected the expense

Once an approval is `approved` or `rejected`, it cannot be changed. The employee must create a new expense if corrections are needed.

## List pending approvals

Use `GET /approvals` to retrieve expenses awaiting approval. By default, this returns approvals assigned to the authenticated user.

```bash
curl -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json" \
  "https://sandbox.fjordexpense.example.com/v1/approvals?limit=50&offset=0"
```

### Response

```json
{
  "data": [
    {
      "id": "appr_def456",
      "expense_id": "exp_1a2b3c4d5e",
      "expense": {
        "id": "exp_1a2b3c4d5e",
        "employee_id": "emp_abc123",
        "category_id": "cat_travel",
        "amount": "450.00",
        "currency": "NOK",
        "date": "2025-01-10",
        "description": "Client meeting in Bergen",
        "merchant": "NSB",
        "status": "submitted",
        "receipt_ids": ["rec_xyz789"],
        "created_at": "2025-01-14T10:30:00Z",
        "updated_at": "2025-01-14T11:00:00Z"
      },
      "approver_id": "emp_manager1",
      "status": "pending",
      "comment": null,
      "approved_at": null,
      "rejected_at": null
    }
  ],
  "pagination": {
    "limit": 50,
    "offset": 0,
    "total": 1,
    "has_more": false
  }
}
```

The `expense` object is embedded in the approval, giving you immediate access to expense details without additional API calls.

### Pagination

Use `limit` and `offset` parameters to paginate through large result sets:

```bash
# Get the next page
curl -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json" \
  "https://sandbox.fjordexpense.example.com/v1/approvals?limit=50&offset=50"
```

## Approve an expense

Use `POST /approvals/{approval_id}/approve` to approve a pending expense.

```bash
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/approvals/appr_def456/approve" \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Accept: application/json"
```

### Optional comment

You can include an optional comment (maximum 500 characters):

```bash
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/approvals/appr_def456/approve" \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "comment": "Approved for reimbursement"
  }'
```

### Response

```json
{
  "id": "appr_def456",
  "expense_id": "exp_1a2b3c4d5e",
  "expense": {
    "id": "exp_1a2b3c4d5e",
    "status": "approved",
    ...
  },
  "approver_id": "emp_manager1",
  "status": "approved",
  "comment": "Approved for reimbursement",
  "approved_at": "2025-01-17T14:30:00Z",
  "rejected_at": null
}
```

After approval:
- The approval `status` changes to `approved`
- The approval `approved_at` timestamp is set
- The expense `status` changes to `approved`
- The expense becomes available for invoicing or reimbursement

## Reject an expense

Use `POST /approvals/{approval_id}/reject` to reject a pending expense. A rejection reason is required.

```bash
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/approvals/appr_def456/reject" \
  -H "X-API-Key: $FJORD_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "reason": "Receipt is unclear. Please upload a higher quality image."
  }'
```

The `reason` field is required and limited to 500 characters.

### Response

```json
{
  "id": "appr_def456",
  "expense_id": "exp_1a2b3c4d5e",
  "expense": {
    "id": "exp_1a2b3c4d5e",
    "status": "rejected",
    ...
  },
  "approver_id": "emp_manager1",
  "status": "rejected",
  "comment": "Receipt is unclear. Please upload a higher quality image.",
  "approved_at": null,
  "rejected_at": "2025-01-17T14:35:00Z"
}
```

After rejection:
- The approval `status` changes to `rejected`
- The approval `rejected_at` timestamp is set
- The expense `status` changes to `rejected`
- The rejection reason is stored in the `comment` field
- The employee can view the rejection reason and create a corrected expense

## Approval workflow example

Complete workflow from expense submission to approval:

```bash
# Employee: Create expense
EXPENSE_ID=$(curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/expenses" \
  -H "X-API-Key: $EMPLOYEE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "category_id": "cat_travel",
    "amount": "450.00",
    "currency": "NOK",
    "date": "2025-01-10",
    "description": "Client meeting",
    "merchant": "NSB"
  }' | jq -r '.id')

# Employee: Upload receipt
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/receipts" \
  -H "X-API-Key: $EMPLOYEE_API_KEY" \
  -F "file=@receipt.pdf" \
  -F "expense_id=$EXPENSE_ID"

# Employee: Submit for approval
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/expenses/$EXPENSE_ID/submit" \
  -H "X-API-Key: $EMPLOYEE_API_KEY"

# Manager: List pending approvals
APPROVAL_ID=$(curl -H "X-API-Key: $MANAGER_API_KEY" \
  "https://sandbox.fjordexpense.example.com/v1/approvals" \
  | jq -r '.data[0].id')

# Manager: Approve expense
curl -X POST \
  "https://sandbox.fjordexpense.example.com/v1/approvals/$APPROVAL_ID/approve" \
  -H "X-API-Key: $MANAGER_API_KEY"
```

## Error handling

Common errors when working with approvals:

**403 Forbidden** - User lacks approval permissions:

```json
{
  "error": {
    "code": "forbidden",
    "message": "You do not have permission to approve expenses",
    "request_id": "req_8f3c1a2b"
  }
}
```

**404 Not Found** - Approval ID does not exist:

```json
{
  "error": {
    "code": "not_found",
    "message": "Approval not found",
    "request_id": "req_8f3c1a2b"
  }
}
```

**409 Conflict** - Approval already processed:

```json
{
  "error": {
    "code": "conflict",
    "message": "Approval has already been processed",
    "request_id": "req_8f3c1a2b"
  }
}
```

**422 Validation Error** - Missing required rejection reason:

```json
{
  "error": {
    "code": "validation_error",
    "message": "Rejection reason is required",
    "request_id": "req_8f3c1a2b",
    "details": [
      {
        "field": "reason",
        "issue": "required field is missing"
      }
    ]
  }
}
```

## Best practices

**Review receipts:** Always check that receipts are clear and complete before approving. Use `GET /receipts/{receipt_id}/download` to view receipt images.

**Provide clear rejection reasons:** When rejecting expenses, explain specifically what needs to be corrected so employees can resubmit properly.

**Process approvals promptly:** Delayed approvals can impact employee reimbursement timelines and financial reporting.

**Check embedded expense details:** The approval response includes the full expense object, eliminating the need for additional API calls to verify expense details.

**Handle already-processed approvals gracefully:** If you receive a `409 Conflict` error, the approval has already been processed by another manager. Refresh your approval list.
