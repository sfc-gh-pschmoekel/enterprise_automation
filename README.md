# Enterprise Workflow Automation with Snowflake Intelligence

> One company. Three teams. Zero code.

---

Total Duration: 45-60 minutes

---

## The Three Demos

| Demo | Team | The Story | Agent Capabilities |
|------|------|-----------|-------------------|
| Finance Agent | Accounts Payable | Process invoices, catch the vendor problem | Tool-calling (stored procedures) |
| Ops Monitor | Warehouse Operations | Investigate the supply chain ripple effect | Cortex Analyst (semantic model) |
| Marketing Commander | Marketing | Plan campaigns with data + brand strategy | Multi-Agent (Search + Analyst) |


---

## Prerequisites

- Snowflake account
- Cortex Agents enabled

---

## Quick Start

Run these SQL scripts before the session:

```sql
-- Run in order (each takes ~30-90 seconds)
-- Script 1: Finance data + agent tools
-- Script 2: Operations data + semantic model  
-- Script 3: Marketing data + multi-agent setup
```

---

### Agent Architecture

| Demo | Agent | Tools |
|------|-------|-------|
| Finance | FINANCE_AGENT | 6 stored procedures |
| Operations | OPS_ANALYTICS (semantic view) | Cortex Analyst |
| Marketing | MARKETING_ASSISTANT | Multiple Tools |

---

## Key Messages

### For Business Audiences

> "Every team at every company should have an agent. This is what that looks like."

- Finance: 10 invoices in 10 minutes vs. 10 invoices in 2 hours
- Operations: Root cause in seconds vs. hours of investigation
- Marketing: Strategy + data in one conversation vs. multiple tools

### For Technical Audiences

> "Build the primitives once. Business users configure forever."

- Stored procedures become agent tools
- Semantic models become agent knowledge
- Agents can call other agents (multi-agent)
- Everything stays governed in Snowflake

---

## Cleanup

```sql
DROP DATABASE IF EXISTS HOL_AUTOMATION;
DROP WAREHOUSE IF EXISTS HOL_AGENT_WH;
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Agent not finding tools | Ensure setup scripts completed successfully |
| Semantic view errors | Check that views were created before semantic model |
| Search not returning results | Verify Cortex Search service is running |

