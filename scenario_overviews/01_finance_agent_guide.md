# Lab 1: Finance Agent

**Time:** 15 min | **Pattern:** Tool-calling (stored procedures)

## Overview

An AI agent that validates invoices, checks vendors, and routes exceptions. The agent calls stored procedures as tools.

## Data Location

`HOL_AUTOMATION.FINANCE` — Tables: INVOICES, PURCHASE_ORDERS, VENDORS, APPROVERS

## Your Task

1. Open **AI & ML → Studio → FINANCE_AGENT**
2. Click Settings, add the `GET_EXCEPTIONS` stored procedure as a tool
3. Save and test

## Sample Prompts

| Prompt | What It Shows |
|--------|---------------|
| "What invoices are pending?" | Queue overview |
| "Validate INV-2024-001" | Clean validation |
| "Validate INV-2024-003" | Amount exceeds PO |
| "What's wrong with INV-2024-005?" | Suspended vendor |
| "Validate INV-2024-010" | Multiple issues (cancelled PO + inactive vendor) |

## Key Insight

Stored procedures become agent capabilities. No code required to extend.
