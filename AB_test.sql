CREATE TABLE [dbo].[marketing_AB_test] (
[No ] varchar(50),
[user_id] varchar(50),
[test_group] varchar(50),
[converted] varchar(50),
[total_ads] varchar(50),
[most_ads_day] varchar(50),
[most_ads_hour] varchar(50)
)
USE [PortfolioProject]
Go
-- How many rows do we have?
SELECT COUNT(*) AS total_rows
FROM marketing_AB_test;

SELECT * FROM marketing_AB_test


--how are users split b/w the two groups?
SELECT 
    test_group,
    COUNT(*) AS users,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM marketing_AB_test
GROUP BY test_group;
----96% of users are seeing ads while only 4% are seeing psa

--Calculate conversion rate--
---do people who see ads convert at a higher rate?

SELECT 
    test_group,
    COUNT(*) AS total_users,
    SUM(CASE WHEN converted = 'TRUE' THEN 1 ELSE 0 END) AS converted_users,
    ROUND(
        SUM(CASE WHEN converted = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS conversion_rate_pct
FROM marketing_ab_test
GROUP BY test_group;


---Consider ad exposure
CREATE INDEX idx_group_ads 
ON marketing_ab_test (test_group, total_ads);

WITH base AS (
    SELECT 
        test_group,
        CAST(total_ads AS INT) AS total_ads
    FROM marketing_ab_test
),
statss AS (
    SELECT 
        test_group,
        ROUND(AVG(total_ads), 1) AS avg_ads_seen,
        MIN(total_ads) AS min_ads,
        MAX(total_ads) AS max_ads
    FROM base
    GROUP BY test_group
),
med AS (
    SELECT DISTINCT
        test_group,
        PERCENTILE_CONT(0.5) 
            WITHIN GROUP (ORDER BY total_ads)
            OVER (PARTITION BY test_group) AS median_ads
    FROM base
)
SELECT *
FROM statss s
JOIN med m 
  ON s.test_group = m.test_group;
----------------------------------------------------------------

--conversion rate by ad volume

WITH bucketed AS (
  SELECT 
    total_ads,
    converted,
    CASE 
      WHEN total_ads BETWEEN 1 AND 10 THEN '1-10 ads'
      WHEN total_ads BETWEEN 11 AND 50 THEN '11-50 ads'
      WHEN total_ads BETWEEN 51 AND 100 THEN '51-100 ads'
      ELSE '100+ ads'
    END AS ads_bucket
  FROM marketing_AB_test
  WHERE test_group = 'ad'
)
SELECT 
  ads_bucket,
  COUNT(*) AS users,
  ROUND(
    SUM(CASE WHEN converted = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2
  ) AS conversion_rate_pct
FROM bucketed
GROUP BY ads_bucket
ORDER BY ads_bucket;

--best day and hour to show ads

SELECT 
    most_ads_day,
    COUNT(*) AS users,
    SUM(CASE WHEN converted = 'TRUE' THEN 1 ELSE 0 END) AS conversions,
    ROUND(
        SUM(CASE WHEN converted = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS conversion_rate_pct
FROM marketing_ab_test
WHERE test_group = 'ad'
GROUP BY most_ads_day
ORDER BY conversion_rate_pct DESC;
---by hour
SELECT TOP 5
    most_ads_hour,
    COUNT(*) AS users,
    ROUND(
        SUM(CASE WHEN converted = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS conversion_rate_pct
FROM marketing_ab_test
WHERE test_group = 'ad'
GROUP BY most_ads_hour
ORDER BY conversion_rate_pct DESC;


--summarize findings
SELECT 
    test_group,
    COUNT(*) AS total_users,
    SUM(CASE WHEN converted = 'TRUE' THEN 1 ELSE 0 END) AS conversions,
    ROUND(
        SUM(CASE WHEN converted = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS conversion_rate_pct,
    ROUND(AVG(CAST(total_ads As Int)), 1) AS avg_ads_seen
FROM marketing_ab_test
GROUP BY test_group;


