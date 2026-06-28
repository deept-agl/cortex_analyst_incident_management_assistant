/*=============================================================================
  USE CASE 1: CORTEX ANALYST — Natural Language to SQL
  
  Enterprise Value: Business users ask questions in plain English and get
  accurate SQL + results. No SQL knowledge required. The semantic view
  defines business logic so the AI generates correct queries every time.
  
  Components:
    - CREATE SEMANTIC VIEW: Define metrics, dimensions, relationships
    - CREATE AGENT: Build conversational interface with Analyst tool
    - DATA_AGENT_RUN: Test the agent from SQL
=============================================================================*/

USE WAREHOUSE CORTEX_DEMO_WH;
USE SCHEMA CORTEX_DEMO_DB.DWH_SCHEMA;

/*-----------------------------------------------------------------------------
  STEP 1: CREATE SEMANTIC VIEW — Define business semantics over incident data
  Maps physical columns to business concepts with synonyms and descriptions.
-----------------------------------------------------------------------------*/
CREATE OR REPLACE SEMANTIC VIEW INCIDENT_ANALYST_SV

  TABLES (
    incidents AS CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_FACT
      PRIMARY KEY (INCIDENT_ID)
      WITH SYNONYMS = ('incidents','tickets','issues','support tickets','service tickets')
      COMMENT = 'One row per IT incident. Contains incident timing and operational measures such as resolution time, downtime, and customers affected.',

    apps AS CORTEX_DEMO_DB.DWH_SCHEMA.APP_DIM
      PRIMARY KEY (APP_KEY)
      UNIQUE (APP_NAME)
      WITH SYNONYMS = ('applications','apps','systems','business applications','services' )
      COMMENT = 'Business application reference data including business unit, service, criticality, and responsible support team.',

    owners AS CORTEX_DEMO_DB.DWH_SCHEMA.OWNER_DIM
      PRIMARY KEY (OWNER_KEY)
      UNIQUE (OWNER_NAME)
      WITH SYNONYMS = ('owners','engineers','assignees','resolvers','support engineers')
      COMMENT = 'Support engineer reference data including team and designation.',

    priorities AS CORTEX_DEMO_DB.DWH_SCHEMA.PRIORITY_DIM
      PRIMARY KEY (PRIORITY_KEY)
      UNIQUE (PRIORITY_CODE)
      WITH SYNONYMS = ('priorities','severity levels','incident severity','priority levels')
      COMMENT = 'Incident priority reference data with the target resolution SLA in hours.',

    statuses AS CORTEX_DEMO_DB.DWH_SCHEMA.STATUS_DIM
      PRIMARY KEY (STATUS_KEY)
      UNIQUE (STATUS_NAME)
      WITH SYNONYMS = ('statuses','ticket status','incident state','incident status')
      COMMENT = 'Current status of each incident, such as Open, In Progress, Closed, or Cancelled.',

    dates AS CORTEX_DEMO_DB.DWH_SCHEMA.DATE_DIM
      PRIMARY KEY (DATE_KEY)
      UNIQUE (CALENDAR_DATE)
      WITH SYNONYMS ('dates','calendar','incident dates','raised dates','created dates')
      COMMENT = 'Calendar attributes for the date on which an incident was raised.'
    )

  RELATIONSHIPS (
    incidents_to_apps AS
      incidents (APP_KEY) REFERENCES apps (APP_KEY),

    incidents_to_owners AS
      incidents (OWNER_KEY) REFERENCES owners (OWNER_KEY),

    incidents_to_priorities AS
      incidents (PRIORITY_KEY) REFERENCES priorities (PRIORITY_KEY),

    incidents_to_statuses AS
      incidents (STATUS_KEY) REFERENCES statuses (STATUS_KEY),

    incidents_to_raised_dates AS
      incidents (RAISED_DATE_KEY) REFERENCES dates (DATE_KEY),
    
    incidents_to_closed_dates AS
      incidents (CLOSED_DATE_KEY) REFERENCES dates (DATE_KEY)
  )

  FACTS (

    incidents.resolution_hours AS RESOLUTION_HOURS
      WITH SYNONYMS ('resolution time','time to resolve','resolution duration')
      COMMENT = 'Number of hours taken to resolve an incident. Lower values indicate faster resolution.',

    incidents.downtime_minutes AS DOWNTIME_MINUTES
      WITH SYNONYMS ('downtime','outage duration','outage minutes','service disruption')
      COMMENT = 'Number of minutes the application or service was unavailable because of the incident.',

    incidents.customers_affected AS CUSTOMERS_AFFECTED
      WITH SYNONYMS ('affected customers','impacted customers','affected users','user impact')
      COMMENT = 'Number of customers or users affected by the incident.',

    incidents.sla_breach_flag AS SLA_BREACH_FLAG
      COMMENT = '1 when the incident breached SLA; otherwise 0.',

    incidents.active_incident_flag AS ACTIVE_INCIDENT_FLAG
      COMMENT = '1 when the incident is Open or In Progress; otherwise 0.',

    incidents.closed_incident_flag AS CLOSED_INCIDENT_FLAG
      COMMENT = '1 when the incident status is Closed; otherwise 0.'
  )
  DIMENSIONS (
    apps.app_name AS APP_NAME
      WITH SYNONYMS ('application','app','system','affected application')
      COMMENT = 'Application impacted by the incident.',
    apps.business_unit AS BUSINESS_UNIT
      WITH SYNONYMS ('business unit','business area','department','BU')
      COMMENT = 'Business unit that owns or uses the application.',
    apps.service_name AS SERVICE_NAME
      WITH SYNONYMS ('service','business service','service area')
      COMMENT = 'Business service supported by the application.',
    apps.criticality AS criticality
      WITH SYNONYMS ('application criticality','business criticality','critical app','critical application')
      COMMENT = 'Business criticality of the application: Critical, High, or Medium.',
    apps.APP_support_team AS APP_SUPPORT_TEAM
      WITH SYNONYMS ('application support team','owning team','responsible team')
      COMMENT = 'Support team responsible for the application.',
    owners.owner_name AS OWNER_NAME
      WITH SYNONYMS ('engineer','assignee','resolver','incident owner','support engineer')
      COMMENT = 'Engineer assigned to resolve the incident.',
    owners.support_team AS support_team
      WITH SYNONYMS ( 'support team','resolver group','operations team','team')
      COMMENT = 'Support team to which the assigned engineer belongs.',
    owners.designation AS DESIGNATION
      WITH SYNONYMS ('job title','role','engineer role')
      COMMENT = 'Job designation of the assigned engineer.',
    priorities.priority_code AS PRIORITY_CODE
      WITH SYNONYMS ('priority','severity','P1','P2','P3','P4','P5')
      COMMENT = 'Incident priority code from P1 through P5, where P1 is the highest priority.',
    priorities.priority_name AS PRIORITY_NAME
      WITH SYNONYMS ('priority level','severity level')
      COMMENT = 'Priority description such as Critical, High, Medium, Low, or Minor.',
    priorities.SLA_HOURS AS SLA_HOURS
      WITH SYNONYMS ('SLA','time to resolve')
      COMMENT = 'Priority SLA hours as per the priority level.',
    statuses.status_name AS STATUS_NAME
      WITH SYNONYMS ('status','current status','ticket status','incident state')
      COMMENT = 'Current status of the incident: Open, In Progress, Closed, or Cancelled.',
    statuses.status_group AS STATUS_GROUP
      WITH SYNONYMS ('status category','active status','resolved status')
      COMMENT = 'High-level status grouping such as Active, Resolved, or Closed.',
    dates.calendar_date AS calendar_date
      WITH SYNONYMS ('raised date','closed date','created date', 'incident date','opened date' )
      COMMENT = 'Date on which the incident was raised.',
    dates.month_name AS month_name
      WITH SYNONYMS ('raised month','closed month','created month','incident month')
      COMMENT = 'Month in which the incident was raised.',
    dates.quarter AS QUARTER
      WITH SYNONYMS ('raised quarter','closed quarter','created quarter','incident quarter')
      COMMENT = 'Quarter in which the incident was raised.',
    dates.year AS YEAR
      WITH SYNONYMS ('raised year','closed year','created year','incident year')
      COMMENT = 'Year in which the incident was raised.'
)
METRICS (
    incidents.total_incidents AS COUNT(incidents.INCIDENT_ID)
      WITH SYNONYMS ('incident count','number of incidents','ticket count','total tickets','workload')
      COMMENT = 'Total number of incidents.',
    incidents.sla_breach_count AS SUM(incidents.SLA_BREACH_FLAG)
      WITH SYNONYMS ('SLA breaches','SLA violation count','missed SLA count')
      COMMENT = 'Number of incidents that exceeded the SLA target.',

    incidents.sla_compliance_pct AS 100 * (COUNT(incidents.INCIDENT_ID) - SUM(incidents.SLA_BREACH_FLAG)) / NULLIF(COUNT(incidents.INCIDENT_ID), 0)
      WITH SYNONYMS ('SLA compliance','SLA compliance percentage','within SLA percentage')
      COMMENT = 'Percentage of incidents resolved within SLA.',

    incidents.active_incident_count AS SUM(incidents.ACTIVE_INCIDENT_FLAG)
      WITH SYNONYMS ('open incidents','active incidents','unresolved incidents','pending incidents')
      COMMENT = 'Number of currently Open or In Progress incidents.',

    incidents.closed_incident_count AS SUM(incidents.CLOSED_INCIDENT_FLAG)
      WITH SYNONYMS ('closed incidents','resolved incidents','completed tickets')
      COMMENT = 'Number of incidents currently marked Closed.'
)

  COMMENT = 'Incident Management analytics semantic view for natural language querying of incidents, applications, owners, priorities and statuses';

-- Verify
SHOW SEMANTIC VIEWS IN SCHEMA CORTEX_DEMO_DB.DWH_SCHEMA;


/*-----------------------------------------------------------------------------
  STEP 2: CREATE AGENT — Conversational Analyst interface
-----------------------------------------------------------------------------*/
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


/*-----------------------------------------------------------------------------
  STEP 3: Test the Agent — Ask business questions
  Each query demonstrates a different analytics pattern.
-----------------------------------------------------------------------------*/

-- Question 1: Exception analysis
-- Finds applications where outage impact is high despite fewer incidents.
WITH RESP AS (
  SELECT TRY_PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_ANALYST_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text", 
    "text": "Which applications have high total downtime but relatively low incident count? Show the application, total downtime, incident count, and business unit."}]}] }$$,
    TRUE)) AS R
)
SELECT f.value:text::STRING AS ANSWER FROM RESP, LATERAL FLATTEN(input => R:content) f WHERE f.value:type = 'text';

-- Question 2: Workload versus efficiency
-- Identifies engineers who handle many incidents while resolving them quickly.
WITH RESP AS (
  SELECT TRY_PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_ANALYST_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text",
     "text": "Which engineers have the highest workload but still maintain below-average resolution time? Include engineer, support team, incident count, and average resolution hours."}]}] }$$,
    TRUE)) AS R
)
SELECT f.value:text::STRING AS ANSWER FROM RESP, LATERAL FLATTEN(input => R:content) f WHERE f.value:type = 'text';

-- Question 3:  Hidden risk identification
-- Critical applications that appear stable but still need monitoring.
WITH RESP AS (
  SELECT TRY_PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_ANALYST_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text",
     "text": "Which critical applications rarely fail? Show their incident count, total downtime, and affected customers."}]}] }$$,
    TRUE)) AS R
)
SELECT f.value:text::STRING AS ANSWER FROM RESP, LATERAL FLATTEN(input => R:content) f WHERE f.value:type = 'text';

-- Question 4: SLA exception investigation
-- Finds unexpected SLA violations among lower-priority tickets.
WITH RESP AS (
  SELECT TRY_PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
    'CORTEX_DEMO_DB.DWH_SCHEMA.INCIDENT_ANALYST_AGENT',
    $${ "messages": [{"role": "user", "content": [{"type": "text",
     "text": "Show P4 and P5 incidents that breached SLA. Include incident ID, application, assigned engineer, resolution hours, SLA target hours, and current status."}]}] }$$,
    TRUE)) AS R
)
SELECT f.value:text::STRING AS ANSWER FROM RESP, LATERAL FLATTEN(input => R:content) f WHERE f.value:type = 'text';


--Some Questions which the business would want top check regularly/daily basis.
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