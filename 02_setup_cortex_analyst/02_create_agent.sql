
/*-----------------------------------------------------------------------------
  STEP 2: CREATE AGENT — Conversational Analyst interface
-----------------------------------------------------------------------------*/

USE WAREHOUSE CORTEX_DEMO_WH;
USE SCHEMA CORTEX_DEMO_DB.DWH_SCHEMA;
CREATE OR REPLACE AGENT INCIDENT_ANALYST_AGENT
  FROM SPECIFICATION $$
models:
  orchestration: auto
instructions:
  orchestration: >
    You are an IT incident analytics assistant. Use the Analyst tool to answer
    questions about incidents, applications, engineers, support teams, SLA
    compliance, downtime, workload, customer impact, priorities, and trends.
    For rankings, sort and limit results appropriately. Use raised-date and closed-date fields
    for time-based incident questions.
  response: >
    Be concise and data-driven. Use clear labels and mention the time period
    when relevant. Format resolution time in hours, downtime in minutes, and
    round percentages to two decimal places.
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: incident_analyst
      description: >
        Answers questions about incident volume, application health, support
        team efficiency, engineer workload, SLA compliance, downtime,
        customer impact, priority analysis, and date trends.
tool_resources:
  incident_analyst:
    semantic_view: CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_ANALYST_SV
    execution_environment:
      type: warehouse
      warehouse: CORTEX_DEMO_WH
  $$;

-- Verify
SHOW AGENTS IN SCHEMA CORTEX_DEMO_DB.DWH_SCHEMA;
