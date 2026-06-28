/*=============================================================================
  CORTEX ANALYST INCIDENT MANAGEMENT ASSISTANT — SETUP SCRIPT
  Creates database, schema, warehouse and resource monitor.
=============================================================================*/

USE ROLE ACCOUNTADMIN;

--Database and Schema
CREATE OR REPLACE DATABASE CORTEX_DEMO_DB;
CREATE OR REPLACE SCHEMA CORTEX_DEMO_DB.DWH_SCHEMA;

--Warehouse to execute all workloads
CREATE OR REPLACE WAREHOUSE CORTEX_DEMO_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

--Resource Monitor for monitoring warehouse cost
CREATE OR REPLACE RESOURCE MONITOR CORTEX_DEMO_COST_MONITOR
  WITH CREDIT_QUOTA = 30
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 80 PERCENT DO NOTIFY
    ON 90 PERCENT DO SUSPEND
    ON 100 PERCENT DO SUSPEND_IMMEDIATE;

--Attach RM to the the warehouse
ALTER WAREHOUSE CORTEX_DEMO_WH
  SET RESOURCE_MONITOR = CORTEX_DEMO_COST_MONITOR;

--Grant cortex user role to accountadmin.
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE ACCOUNTADMIN;