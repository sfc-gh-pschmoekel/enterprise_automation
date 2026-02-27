# Lab 2: Ops Monitor

**Time:** 15 min | **Pattern:** Cortex Analyst (semantic model)

## Overview

An AI agent that monitors inventory, detects anomalies, and investigates issues using natural language queries against a semantic model.

## Data Location

`HOL_AUTOMATION.OPERATIONS` — Tables: WAREHOUSES, INVENTORY, INVENTORY_HISTORY, ORDERS, PRODUCTS

## Your Task

1. Open **AI & ML → Studio**
2. Create new agent named `Ops_Monitor`
3. Add the semantic view `OPS_ANALYTICS` as a data source
4. Test with the prompts below

## Sample Prompts

| Prompt | What It Shows |
|--------|---------------|
| "Any inventory issues?" | Morning health check |
| "Check for unusual inventory changes" | Anomaly detection (finds 87% drop at Midwest Hub) |
| "Investigate SKU-001 at Midwest Hub" | Root cause analysis |
| "What orders are affected?" | Impact assessment ($89K+ at risk) |
| "Create an alert for the warehouse manager" | Action execution |

## Key Insight

The agent found a supplier issue (Midwest Manufacturing went INACTIVE) that's now affecting inventory and orders. Two departments, one connected problem.
