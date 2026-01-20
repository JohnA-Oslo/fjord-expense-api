# Fjord expense API documentation

The Fjord Expense API provides programmatic access to expense management, receipt handling, approval workflows, and invoice generation.

This is a demo API created as a playground and to experiment with various technical documentation capabilities around API documentation.

## Overview

The API allows you to:

- Create and manage employee expense entries
- Upload and attach receipts to expenses
- Submit expenses for approval and process approvals
- Generate expense reports
- Create invoices from approved expenses
- Configure webhooks for event notifications

## Base URLs

- **Production:** `https://api.fjordexpense.example.com/v1`
- **Sandbox:** `https://sandbox.fjordexpense.example.com/v1`

Use the sandbox environment for testing and development. The sandbox resets daily at 00:00 UTC.

## Getting started

If you are new to the API read these guides first:

1. [Quick Start Guide](getting-started/quickstart.md) - Describes how to make your first API call
2. [Authentication](getting-started/authentication.md) - Learn how to authenticate your requests
3. [Rate Limits](getting-started/rate-limits.md) - Understand API usage limits

## Common use cases

**Employee expense submission:**
Employees create expenses, attach receipts, and submit for approval. See [Managing Expenses](guides/expenses.md).

**Manager approval workflow:**
Managers review pending expenses and approve or reject them. See [Approval Workflows](guides/approvals.md).

**Client invoicing:**
Generate invoices from approved expenses for billing clients. See [Generating Invoices](guides/invoicing.md).

## API reference

Complete endpoint documentation is available in the [API Reference](api-reference.md).

## Support

For questions or issues with this demonstration API:

- **Email:** api@fjordexpense.example.com
- **GitHub:** [github.com/JohnA-Oslo/fjord-expense-api](https://github.com/yourusername/fjord-expense-api)
