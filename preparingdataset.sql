# Preparing dataset
CREATE TABLE retail_redact AS (SELECT * FROM retail WHERE quantity > 0 AND unitprice > 0 AND customerid IS NOT NULL AND stockcode IS NOT NULL AND invoiceno IS NOT NULL AND 
customerid IS NOT NULL AND time IS NOT NULL LIMIT 1000)

WITH t1 AS (SELECT customerid, min(time) as start_date_user FROM retail_redact GROUP BY customerid)

CREATE TABLE retail_redact_again AS (SELECT * FROM retail_redact JOIN t1 ON t1.customerid = retail_redact.customerid)

CREATE TABLE t1 AS (SELECT customerid, min(time) as start_date_user FROM retail_redact GROUP BY customerid)

CREATE TABLE retail_redact_again AS (SELECT t1.customerid, time, start_date_user, quantity, description, country FROM retail_redact INNER JOIN t1 ON t1.customerid = retail_redact.customerid)

CREATE TABLE retail_redact_date AS (SELECT customerid, time, start_date_user, quantity, description, country, 
DATE_PART('year', AGE(time, start_date_user)) as year_life, 
DATE_PART('month', AGE(time, start_date_user)) as month_life, DATE_PART('day', AGE(time, start_date_user)) as day_life
FROM retail_redact_again)

ALTER TABLE retail_redact_date ADD week_life integer

UPDATE retail_redact_date SET week_life = FLOOR(year_life * 48 + month_life * 4 + day_life / 7)

CREATE TABLE final_date AS 
WITH t1 AS (SELECT COUNT(customerid) as countusers, week_life FROM retail_redact_date GROUP BY week_life)

SELECT countusers, country, t1.week_life FROM retail_redact_date rr JOIN t1 ON rr.week_life = t1.week_life
