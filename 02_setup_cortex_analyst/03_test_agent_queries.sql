
/*-----------------------------------------------------------------------------
  STEP 3: Test the Agent — Ask business questions
  Each query demonstrates a different analytics pattern.
-----------------------------------------------------------------------------*/
USE WAREHOUSE CORTEX_DEMO_WH;
USE SCHEMA CORTEX_DEMO_DB.DWH_SCHEMA;

-- Question 1: Exception analysis
-- Finds applications where outage impact is high despite fewer incidents.
WITH RESP AS (
  SELECT TRY_PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_ANALYST_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text", 
    "text": "Which applications have high total downtime but relatively low incident count?"}]}] }$$,
    TRUE)) AS R
)
SELECT f.value:text::STRING AS ANSWER FROM RESP, LATERAL FLATTEN(input => R:content) f WHERE f.value:type = 'text';

-- Question 2: Workload versus efficiency
-- Identifies engineers who handle many incidents while resolving them quickly.
WITH RESP AS (
  SELECT TRY_PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_ANALYST_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text",
     "text": "Which engineers have the highest workload but still maintain below-average resolution time?"}]}] }$$,
    TRUE)) AS R
)
SELECT f.value:text::STRING AS ANSWER FROM RESP, LATERAL FLATTEN(input => R:content) f WHERE f.value:type = 'text';

-- Question 3: SLA exception investigation
-- Finds unexpected SLA violations among lower-priority tickets.
WITH RESP AS (
  SELECT TRY_PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_ANALYST_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text",
     "text": "Show P4 and P5 incidents that breached SLA."}]}] }$$,
    TRUE)) AS R
)
SELECT f.value:text::STRING AS ANSWER FROM RESP, LATERAL FLATTEN(input => R:content) f WHERE f.value:type = 'text';


--Some Questions which the business would want to check on regular/daily basis.
-- Question 5: Operational Questions
-- High Priority Open Incidents
WITH RESP AS (
  SELECT TRY_PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_ANALYST_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text",
     "text": "Which P1 and P2 incidents are still open or in progress?"}]}] }$$,
    TRUE)) AS R
)
SELECT f.value:text::STRING AS ANSWER FROM RESP, LATERAL FLATTEN(input => R:content) f WHERE f.value:type = 'text';

-- Critical applications incidents
WITH RESP AS (
  SELECT TRY_PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_ANALYST_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text",
     "text": "Which critical applications currently have active incidents?"}]}] }$$,
    TRUE)) AS R
)
SELECT f.value:text::STRING AS ANSWER FROM RESP, LATERAL FLATTEN(input => R:content) f WHERE f.value:type = 'text';

-- Analyzing team workload
WITH RESP AS (
  SELECT TRY_PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_ANALYST_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text",
     "text": "Which support team has the highest active workload?"}]}] }$$,
    TRUE)) AS R
)
SELECT f.value:text::STRING AS ANSWER FROM RESP, LATERAL FLATTEN(input => R:content) f WHERE f.value:type = 'text';

-- Escalation
WITH RESP AS (
  SELECT TRY_PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_ANALYST_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text",
     "text": "Which services should be escalated based on priority, downtime, and customers affected"}]}] }$$,
    TRUE)) AS R
)
SELECT f.value:text::STRING AS ANSWER FROM RESP, LATERAL FLATTEN(input => R:content) f WHERE f.value:type = 'text';

-
-- KEY INSIGHT:
-- The semantic view provides:
-- 1. Business-friendly names (synonyms) so users can say "revenue" or "sales" or "amount"
-- 2. Pre-defined metrics with correct aggregation (SUM, AVG, COUNT)
-- 3. Relationships between tables so joins are automatic
-- 4. The Agent handles multi-turn conversations via threads in CoWork