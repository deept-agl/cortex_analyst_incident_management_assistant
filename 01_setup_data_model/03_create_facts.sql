/*=============================================================================
  CORTEX ANALYST INCIDENT MANAGEMENT ASSISTANT — SETUP SCRIPT
  Creates all facts and loads sample data using a generator code.
=============================================================================*/

CREATE OR REPLACE TABLE INCIDENT_FACT (
    INCIDENT_ID             VARCHAR PRIMARY KEY,
    APP_KEY                 NUMBER,
    OWNER_KEY               NUMBER,
    PRIORITY_KEY            NUMBER,
    STATUS_KEY              NUMBER,
    RAISED_DATE_KEY         NUMBER,
    CLOSED_DATE_KEY         NUMBER,
    RAISED_TIMESTAMP        TIMESTAMP,
    CLOSED_TIMESTAMP        TIMESTAMP,
    RESOLUTION_HOURS        NUMBER(8,2),
    DOWNTIME_MINUTES        NUMBER,
    CUSTOMERS_AFFECTED      NUMBER,
    SLA_BREACH_FLAG         NUMBER(1,0),
    ACTIVE_INCIDENT_FLAG    NUMBER(1,0),
    CLOSED_INCIDENT_FLAG    NUMBER(1,0)
);
INSERT INTO INCIDENT_FACT
WITH seed AS (
    SELECT
        SEQ4() + 1 AS INCIDENT_SEQ,
        UNIFORM(0, 364, RANDOM()) AS DAY_OFFSET,
        UNIFORM(1, 100, RANDOM()) AS APP_RAND,
        UNIFORM(1, 100, RANDOM()) AS PRIORITY_RAND,
        UNIFORM(1, 100, RANDOM()) AS STATUS_RAND,
        UNIFORM(1, 100, RANDOM()) AS OWNER_RAND
    FROM TABLE(GENERATOR(ROWCOUNT => 600))
),
base_incidents AS (
    SELECT
        INCIDENT_SEQ,
        DAY_OFFSET,
        OWNER_RAND,
        CASE
            WHEN APP_RAND <= 18 THEN 102  -- Customer Portal: high volume
            WHEN APP_RAND <= 33 THEN 101  -- Payment Gateway: high impact
            WHEN APP_RAND <= 45 THEN 106  -- Data Warehouse: high downtime
            WHEN APP_RAND <= 54 THEN 103  -- CRM
            WHEN APP_RAND <= 62 THEN 107  -- API Gateway
            WHEN APP_RAND <= 69 THEN 105  -- Inventory System
            WHEN APP_RAND <= 76 THEN 109  -- Loan Processing
            WHEN APP_RAND <= 82 THEN 108  -- Fraud Detection
            WHEN APP_RAND <= 88 THEN 110  -- Customer Notification
            WHEN APP_RAND <= 93 THEN 112  -- Reporting Portal
            WHEN APP_RAND <= 97 THEN 104  -- HRMS
            ELSE 111                       -- Identity Management: rare/critical
        END AS APP_KEY,
        CASE
            WHEN PRIORITY_RAND <= 6 THEN 1
            WHEN PRIORITY_RAND <= 22 THEN 2
            WHEN PRIORITY_RAND <= 58 THEN 3
            WHEN PRIORITY_RAND <= 90 THEN 4
            ELSE 5
        END AS PRIORITY_KEY,
        CASE
            WHEN STATUS_RAND <= 12 THEN 1  -- Open
            WHEN STATUS_RAND <= 24 THEN 2  -- In Progress
            WHEN STATUS_RAND <= 96 THEN 3  -- Closed
            ELSE 4                          -- Cancelled
        END AS STATUS_KEY
    FROM seed
),
incident_values AS (
    SELECT
        b.*,
        CASE
            WHEN APP_KEY = 101 THEN CASE
                WHEN OWNER_RAND <= 45 THEN 204
                WHEN OWNER_RAND <= 75 THEN 205
                ELSE 206
            END
            WHEN APP_KEY = 102 THEN CASE
                WHEN OWNER_RAND <= 45 THEN 207
                WHEN OWNER_RAND <= 75 THEN 208
                ELSE 209
            END
            WHEN APP_KEY = 103 THEN CASE
                WHEN OWNER_RAND <= 50 THEN 210
                WHEN OWNER_RAND <= 80 THEN 211
                ELSE 212
            END
            WHEN APP_KEY = 104 THEN IFF(OWNER_RAND <= 60, 213, 214)
            WHEN APP_KEY = 105 THEN IFF(OWNER_RAND <= 60, 215, 216)
            WHEN APP_KEY = 106 THEN CASE
                WHEN OWNER_RAND <= 45 THEN 201
                WHEN OWNER_RAND <= 75 THEN 202
                ELSE 203
            END
            WHEN APP_KEY = 107 THEN IFF(OWNER_RAND <= 60, 217, 218)
            WHEN APP_KEY = 108 THEN IFF(OWNER_RAND <= 60, 219, 220)
            WHEN APP_KEY = 109 THEN IFF(OWNER_RAND <= 60, 221, 222)
            WHEN APP_KEY = 110 THEN IFF(OWNER_RAND <= 60, 223, 224)
            WHEN APP_KEY = 111 THEN IFF(OWNER_RAND <= 60, 225, 226)
            WHEN APP_KEY = 112 THEN IFF(OWNER_RAND <= 60, 227, 228)
        END AS OWNER_KEY,
        DATEADD(
            HOUR,
            UNIFORM(0, 23, RANDOM()),
            DATEADD(DAY, DAY_OFFSET, '2025-01-01')
        ) AS RAISED_TIMESTAMP,
        CASE
            WHEN PRIORITY_KEY = 1 THEN 4
            WHEN PRIORITY_KEY = 2 THEN 8
            WHEN PRIORITY_KEY = 3 THEN 24
            WHEN PRIORITY_KEY = 4 THEN 48
            ELSE 72
        END AS SLA_HOURS,
        ROUND(
            CASE
                WHEN APP_KEY IN (106, 108) AND PRIORITY_KEY IN (1, 2)
                    THEN UNIFORM(8, 36, RANDOM())
                WHEN APP_KEY IN (106, 108)
                    THEN UNIFORM(6, 30, RANDOM())
                WHEN PRIORITY_KEY = 1
                    THEN UNIFORM(2, 16, RANDOM())
                WHEN PRIORITY_KEY = 2
                    THEN UNIFORM(2, 14, RANDOM())
                WHEN PRIORITY_KEY = 3
                    THEN UNIFORM(2, 20, RANDOM())
                WHEN PRIORITY_KEY = 4
                    THEN UNIFORM(4, 60, RANDOM())
                ELSE UNIFORM(8, 84, RANDOM())
            END,
            2
        ) AS GENERATED_RESOLUTION_HOURS,
        CASE
            WHEN APP_KEY IN (101, 108) THEN UNIFORM(120, 420, RANDOM())
            WHEN APP_KEY = 106 THEN UNIFORM(90, 300, RANDOM())
            WHEN APP_KEY IN (102, 103, 107, 109) THEN UNIFORM(30, 150, RANDOM())
            ELSE UNIFORM(0, 60, RANDOM())
        END AS DOWNTIME_MINUTES,
        CASE
            WHEN APP_KEY = 101 THEN UNIFORM(5000, 20000, RANDOM())
            WHEN APP_KEY IN (108, 109) THEN UNIFORM(1500, 8000, RANDOM())
            WHEN APP_KEY IN (102, 103) THEN UNIFORM(300, 3000, RANDOM())
            ELSE UNIFORM(10, 500, RANDOM())
        END AS CUSTOMERS_AFFECTED
    FROM base_incidents b
)
SELECT
    CONCAT('INC', LPAD(INCIDENT_SEQ, 6, '0')) AS INCIDENT_ID,
    APP_KEY,
    OWNER_KEY,
    PRIORITY_KEY,
    STATUS_KEY,
    TO_NUMBER(TO_CHAR(RAISED_TIMESTAMP, 'YYYYMMDD')) AS RAISED_DATE_KEY,
    IFF(
        STATUS_KEY IN (3, 4),
        TO_NUMBER(
            TO_CHAR(
                DATEADD(HOUR, GENERATED_RESOLUTION_HOURS, RAISED_TIMESTAMP),
                'YYYYMMDD'
            )
        ),
        NULL
    ) AS CLOSED_DATE_KEY,
    RAISED_TIMESTAMP,
    IFF(
        STATUS_KEY IN (3, 4),
        DATEADD(HOUR, GENERATED_RESOLUTION_HOURS, RAISED_TIMESTAMP),
        NULL
    ) AS CLOSED_TIMESTAMP,
    /*
      Active incidents do not have a final resolution time yet.
    */
    IFF(
        STATUS_KEY IN (3, 4),
        GENERATED_RESOLUTION_HOURS,
        NULL
    ) AS RESOLUTION_HOURS,
    DOWNTIME_MINUTES,
    CUSTOMERS_AFFECTED,
    /*
      SLA breach is evaluated only for completed/cancelled incidents.
    */
    IFF(
        STATUS_KEY IN (3, 4)
        AND GENERATED_RESOLUTION_HOURS > SLA_HOURS,
        1,
        0
    ) AS SLA_BREACH_FLAG,
    IFF(STATUS_KEY IN (1, 2), 1, 0) AS ACTIVE_INCIDENT_FLAG,
    IFF(STATUS_KEY = 3, 1, 0) AS CLOSED_INCIDENT_FLAG
FROM incident_values;

--Validation Query ( to check any orphan records) --This should return zero rows.
SELECT
    a.APP_NAME,
    a.APP_SUPPORT_TEAM AS APP_SUPPORT_TEAM,
    o.OWNER_NAME,
    o.SUPPORT_TEAM AS OWNER_SUPPORT_TEAM,
    COUNT(*) AS INCIDENT_COUNT
FROM INCIDENT_FACT f
JOIN APP_DIM a
    ON f.APP_KEY = a.APP_KEY
JOIN OWNER_DIM o
    ON f.OWNER_KEY = o.OWNER_KEY
WHERE a.APP_SUPPORT_TEAM <> o.SUPPORT_TEAM
GROUP BY 1,2,3,4;