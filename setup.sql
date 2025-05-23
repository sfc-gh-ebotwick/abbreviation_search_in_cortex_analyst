-- Setup resources
CREATE DATABASE IF NOT EXISTS SANDBOX;
USE DATABASE SANDBOX;
CREATE SCHEMA IF NOT EXISTS CORTEX;
USE SCHEMA CORTEX;
CREATE STAGE IF NOT EXISTS SEMANTIC DIRECTORY=(ENABLE=TRUE);

-- Abbreviation table
CREATE OR REPLACE TABLE company_abbreviations (
    company_abbreviation STRING PRIMARY KEY,
    full_company_name STRING
);

-- Companies table
CREATE OR REPLACE TABLE companies (
    company_id INT AUTOINCREMENT PRIMARY KEY,
    full_company_name STRING,
    num_employees INT,
    company_location STRING
);


-- Abbreviations table
INSERT INTO company_abbreviations (company_abbreviation, full_company_name) VALUES
('DSTR', 'Datastorm LLC'),
('GGLX', 'GiggleX Corp.'),
('LMBR', 'LlamaBear LLC'),
('NTFL', 'NotFlix Media'),
('CLND', 'Calendr.ai'),
('PRSN', 'Personable Inc.'),
('FLWR', 'FlowerTech Inc.'),
('ZOOM', 'Zoom Video Comm.'),
('BLCH', 'BleachBit Corp.'),
('CMBT', 'Combato Inc.'),
('REDD', 'Reddittor Inc.'),
('CHTR', 'Chatterbox Inc.'),
('GRMM', 'Grummble Ltd.'),
('SNCK', 'Snacky Inc.'),
('BRWS', 'Browsee LLC'),
('FRFR', 'ForReal Inc.'),
('SKYR', 'SkyRise Corp.'),
('CLVR', 'CleverTree Inc.'),
('TACO', 'TacoBase Inc.'),
('MGCL', 'Magicle Inc.'),
('DINK', 'Dinkleberg & Co.'),
('ZPPL', 'Zapple Tech');

INSERT INTO companies(full_company_name, num_employees, company_location) VALUES
('Datastorm LLC', 150, 'Boulder, CO'),
('GiggleX Corp.', 220, 'Austin, TX'),
('LlamaBear LLC', 95, 'Missoula, MT'),
('NotFlix Media', 85, 'Boise, ID'),
('Calendr.ai', 60, 'Remote'),
('Personable Inc.', 130, 'Chicago, IL'),
('FlowerTech Inc.', 90, 'Portland, OR'),
('Zoom Video Comm.', 6500, 'San Jose, CA'),
('BleachBit Corp.', 45, 'Remote'),
('Combato Inc.', 75, 'Columbus, OH'),
('Reddittor Inc.', 120, 'San Francisco, CA'),
('Chatterbox Inc.', 105, 'Brooklyn, NY'),
('Grummble Ltd.', 70, 'St. Louis, MO'),
('Snacky Inc.', 80, 'Los Angeles, CA'),
('Browsee LLC', 33, 'Remote'),
('ForReal Inc.', 140, 'Atlanta, GA'),
('SkyRise Corp.', 180, 'Denver, CO'),
('CleverTree Inc.', 220, 'Minneapolis, MN'),
('TacoBase Inc.', 55, 'El Paso, TX'),
('Magicle Inc.', 67, 'Salt Lake City, UT'),
('Dinkleberg & Co.', 28, 'Wichita, KS'),
('Zapple Tech', 98, 'Oakland, CA');




-- test query
CREATE OR REPLACE VIEW COMPANY_DATA AS
SELECT 
    ca.company_abbreviation,
    c.full_company_name,
    c.num_employees,
    c.company_location
FROM 
    company_abbreviations ca
JOIN 
    companies c
    ON ca.full_company_name = c.full_company_name; 


SELECT * FROM COMPANY_DATA;

 -- Create Cortex Search Service
CREATE OR REPLACE CORTEX SEARCH SERVICE COMPANY_NAME_ABBREVIATION_SEARCH
  ON COMPANY_ABBREVIATION
  ATTRIBUTES FULL_COMPANY_NAME
  WAREHOUSE = DEFAULT_XS
  TARGET_LAG = '365 days'
  AS (
    SELECT
        COMPANY_ABBREVIATION,
        FULL_COMPANY_NAME
    FROM COMPANY_ABBREVIATIONS
);

 -- Create Cortex Search Service
CREATE OR REPLACE CORTEX SEARCH SERVICE COMPANY_NAME_SEARCH
  ON FULL_COMPANY_NAME
  ATTRIBUTES COMPANY_ABBREVIATION
  WAREHOUSE = DEFAULT_XS
  TARGET_LAG = '365 days'
  AS (
    SELECT
        COMPANY_ABBREVIATION,
        FULL_COMPANY_NAME
    FROM COMPANY_ABBREVIATIONS
);

-- query 
SELECT * FROM table(snowflake.local.cortex_analyst_requests('FILE_ON_STAGE', '@SANDBOX.CORTEX.SEMANTIC/all_company_data.yaml'))
order by timestamp desc;

