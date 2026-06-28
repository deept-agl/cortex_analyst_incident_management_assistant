/*=============================================================================
  CORTEX ANALYST INCIDENT MANAGEMENT ASSISTANT — SETUP SCRIPT
  Creates all dimensions and loads sample data.
=============================================================================*/


USE WAREHOUSE CORTEX_DEMO_WH;
USE SCHEMA CORTEX_DEMO_DB.DWH_SCHEMA;

/*-----------------------------------------------------------------------------
TABLE 1: APP_DIM
Stores master details for each business application,including its business unit,
supported service, criticality, and responsible support team.

Each application is supported by a support team.
-----------------------------------------------------------------------------*/
CREATE OR REPLACE TABLE APP_DIM (
    APP_KEY          NUMBER PRIMARY KEY,
    APP_NAME         VARCHAR,
    BUSINESS_UNIT    VARCHAR,
    SERVICE_NAME     VARCHAR,
    CRITICALITY      VARCHAR,
    APP_SUPPORT_TEAM     VARCHAR
);

INSERT INTO APP_DIM
VALUES
(101, 'Payment Gateway',        'Retail Banking', 'Payments',              'Critical', 'Payments Team'),
(102, 'Customer Portal',        'Sales',          'Customer Management',   'High',     'Application Support'),
(103, 'CRM',                    'Sales',          'Lead Management',      'High',     'CRM Team'),
(104, 'HRMS',                   'Human Resources','Employee Services',     'Medium',   'HR Support'),
(105, 'Inventory System',       'Supply Chain',   'Inventory Management',  'High',     'ERP Team'),
(106, 'Data Warehouse',         'Technology',     'Analytics Platform',    'Critical', 'Data Engineering'),
(107, 'API Gateway',            'Technology',     'Integration Services',  'High',     'Integration Team'),
(108, 'Fraud Detection',        'Risk',           'Fraud Analytics',       'Critical', 'Risk Analytics'),
(109, 'Loan Processing',        'Retail Banking', 'Loan Origination',      'Critical', 'Loans Team'),
(110, 'Customer Notification',  'Marketing',      'Notifications',         'Medium',   'Messaging Team'),
(111, 'Identity Management',    'Technology',     'Authentication',        'Critical', 'Security Team'),
(112, 'Reporting Portal',       'Finance',        'Enterprise Reporting',  'Medium',   'BI Team');

/*-----------------------------------------------------------------------------
TABLE 2: OWNER_DIM
Stores support engineer details, including the engineer name, designation, and support team.

Each owner belongs to a support team.
-----------------------------------------------------------------------------*/
CREATE OR REPLACE TABLE OWNER_DIM (
    OWNER_KEY        NUMBER PRIMARY KEY,
    OWNER_NAME       VARCHAR,
    SUPPORT_TEAM     VARCHAR,
    DESIGNATION      VARCHAR
);

INSERT INTO OWNER_DIM
VALUES
-- Data Engineering: Data Warehouse
(201, 'Alice Johnson', 'Data Engineering', 'Lead Data Engineer'),
(202, 'Nancy Brown',   'Data Engineering', 'Senior Data Engineer'),
(203, 'Vikram Sharma', 'Data Engineering', 'Data Engineer'),

-- Payments: Payment Gateway
(204, 'Bob Smith',     'Payments Team', 'Lead Payments Engineer'),
(205, 'Priya Nair',    'Payments Team', 'Payments Engineer'),
(206, 'Mark Evans',    'Payments Team', 'Senior Payments Engineer'),

-- Application Support: Customer Portal
(207, 'Henry Clark',   'Application Support', 'Lead Application Support Engineer'),
(208, 'Oliver Green',  'Application Support', 'Application Support Engineer'),
(209, 'Deepak Kumar',  'Application Support', 'Associate Application Support Engineer'),

-- CRM
(210, 'Charlie Davis', 'CRM Team', 'Lead CRM Engineer'),
(211, 'Arjun Rao',     'CRM Team', 'CRM Engineer'),
(212, 'Sneha Kapoor',  'CRM Team', 'Associate CRM Engineer'),

-- HR Support
(213, 'David Lee',     'HR Support', 'Lead SAP Consultant'),
(214, 'Karan Singh',   'HR Support', 'SAP Consultant'),

-- ERP
(215, 'Emma Thomas',   'ERP Team', 'Lead ERP Engineer'),
(216, 'Rohit Gupta',   'ERP Team', 'ERP Engineer'),

-- Integration
(217, 'Frank Miller',  'Integration Team', 'Lead Integration Engineer'),
(218, 'Ankit Jain',    'Integration Team', 'Integration Engineer'),

-- Risk
(219, 'Grace Hall',    'Risk Analytics', 'Lead Risk Engineer'),
(220, 'Aditya Kulkarni','Risk Analytics', 'Risk Engineer'),

-- Loans
(221, 'Jack White',    'Loans Team', 'Lead Loans Engineer'),
(222, 'Mohit Arora',   'Loans Team', 'Loans Engineer'),

-- Messaging
(223, 'Isabella Lewis','Messaging Team', 'Lead Messaging Engineer'),
(224, 'Tania Roy',     'Messaging Team', 'Messaging Engineer'),

-- Security
(225, 'Kevin Adams',   'Security Team', 'Lead Security Engineer'),
(226, 'Aman Khanna',   'Security Team', 'Security Engineer'),

-- BI
(227, 'Linda Moore',   'BI Team', 'Lead BI Engineer'),
(228, 'Varun Joshi',   'BI Team', 'BI Engineer');

/*-----------------------------------------------------------------------------
TABLE 3: PRIORITY_DIM
Stores incident priority levels such as P1 to P5 along with the SLA target hours for each priority.
-----------------------------------------------------------------------------*/
CREATE OR REPLACE TABLE PRIORITY_DIM (
    PRIORITY_KEY     NUMBER PRIMARY KEY,
    PRIORITY_CODE    VARCHAR,
    PRIORITY_NAME    VARCHAR,
    SLA_HOURS        NUMBER
);

INSERT INTO PRIORITY_DIM
VALUES
(1, 'P1', 'Critical', 4),
(2, 'P2', 'High',     8),
(3, 'P3', 'Medium',  24),
(4, 'P4', 'Low',     48),
(5, 'P5', 'Minor',   72);
/*-----------------------------------------------------------------------------
TABLE 3: STATUS_DIM
Stores incident lifecycle statuses such as Open, In Progress, Closed, and Cancelled.
-----------------------------------------------------------------------------*/
CREATE OR REPLACE TABLE STATUS_DIM (
    STATUS_KEY           NUMBER PRIMARY KEY,
    STATUS_NAME          VARCHAR,
    STATUS_GROUP         VARCHAR
);

INSERT INTO STATUS_DIM
VALUES
(1, 'Open',        'Active'),
(2, 'In Progress', 'Active'),
(3, 'Closed',      'Resolved'),
(4, 'Cancelled',   'Closed');
/*-----------------------------------------------------------------------------
  TABLE 4: DATE_DIM
Stores calendar attributes used to analyze incidents by date, month, quarter, and year.
-----------------------------------------------------------------------------*/
CREATE OR REPLACE TABLE DATE_DIM (
    DATE_KEY             NUMBER PRIMARY KEY,
    CALENDAR_DATE        DATE,
    MONTH_NUMBER         NUMBER,
    MONTH_NAME           VARCHAR,
    QUARTER              VARCHAR,
    YEAR                 NUMBER
);

INSERT INTO DATE_DIM
SELECT
    TO_NUMBER(TO_CHAR(DATEADD(DAY, SEQ4(), '2025-01-01'), 'YYYYMMDD')) AS DATE_KEY,
    DATEADD(DAY, SEQ4(), '2025-01-01') AS CALENDAR_DATE,
    MONTH(DATEADD(DAY, SEQ4(), '2025-01-01')) AS MONTH_NUMBER,
    MONTHNAME(DATEADD(DAY, SEQ4(), '2025-01-01')) AS MONTH_NAME,
    CONCAT('Q', QUARTER(DATEADD(DAY, SEQ4(), '2025-01-01'))) AS QUARTER,
    YEAR(DATEADD(DAY, SEQ4(), '2025-01-01')) AS YEAR
FROM TABLE(GENERATOR(ROWCOUNT => 365));


-- Verify data has been loaded
SELECT 'APP_DIM' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM APP_DIM
UNION ALL
SELECT 'OWNER_DIM', COUNT(*) FROM OWNER_DIM
UNION ALL
SELECT 'PRIORITY_DIM', COUNT(*) FROM PRIORITY_DIM
UNION ALL
SELECT 'STATUS_DIM', COUNT(*) FROM STATUS_DIM
UNION ALL
SELECT 'DATE_DIM', COUNT(*) FROM DATE_DIM;