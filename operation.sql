Create database Operation_1;

use operation_1;
show tables;

select * from jobs;

# A. Number of jobs reviewed: Amount of jobs reviewed over time.
# Your task: Calculate the number of jobs reviewed per hour 
#				per day for November 2020?
SELECT 
    ds,
    COUNT(job_id) AS jobs_per_day,
    SUM(time_spent / 3600) AS jobs_per_hour
FROM jobs
WHERE ds BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY ds
ORDER BY jobs_per_day;



# B. Throughput: It is the no. of events happening per second.
# Your task: Let’s say the above metric is called throughput. 
#		Calculate 7 day rolling average of throughput? For throughput, 
#		do you prefer daily metric or 7-day rolling and why?


  
  SELECT
  ds, COUNT(*) AS daily_throughput,
  AVG(COUNT(*)) OVER(ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
  AS rolling_average_throughput
FROM jobs GROUP BY ds;


# 3. Percentage share of each language: Share of each language for different contents.
# Your task: Calculate the percentage share of each language in the last 30 days?
select * from jobs;
select count(language) from jobs;

SELECT 
    language,
    ((COUNT(*) / (SELECT 
            COUNT(language)
        FROM jobs)) * 100) AS percent
FROM jobs
GROUP BY language
ORDER BY percent;



# 4. Duplicate rows: Rows that have the same value present in them.
#Your task: Let’s say you see some duplicate rows in the data.
 #		How will you display duplicates from the table?
 
 
SELECT * FROM jobs;

SELECT ds, job_id, actor_id, event, language, time_spent, org, COUNT(*)
FROM jobs
GROUP BY ds , job_id , actor_id , event , language , time_spent , org
HAVING COUNT(*) > 1;
# There are No duplicate rows.


########
# Case Study 2:
########


-- ---------------------------------------------------
show tables;
# Table users Importing

CREATE TABLE users (
  user_id INT,
  created_at DATETIME,
  company_id INT,
  language VARCHAR(50),
  activated_at DATETIME,
  state VARCHAR(50)
);

show tables;
show variables like "local_infile";

set global local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/rohit/Downloads/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


SELECT * FROM USERS;

# Table events importing

CREATE TABLE events (
  user_id INT,
  occurred_at DATETIME,
  event_type VARCHAR(50),
  event_name VARCHAR(50),
  location VARCHAR(50),
  device VARCHAR(50),
  user_type INT
);

select * from events;
LOAD DATA LOCAL INFILE "C:\\Users\\rohit\\Downloads\\events.csv"
INTO TABLE events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

select count(*) from events;
show tables;

# Importing Email table


CREATE TABLE email (
user_id INT, 
occurred_at DATETIME, 
action VARCHAR (70), 
user_type INT);


LOAD DATA LOCAL INFILE "C:\\Users\\rohit\\Downloads\\emails.csv"
INTO TABLE email
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

select count(*) from email;
-- ---------------------------------------------------------
use operation_1;
show tables;




# 1. User Engagement: To measure the activeness of a user. 
#	 Measuring if the user finds quality in a product/service.
# Your task: Calculate the weekly user engagement?


SELECT year(occurred_at) as year,
WEEK(occurred_at) AS week, COUNT(*) AS engagement_count
FROM events
WHERE event_type = 'engagement'
GROUP BY YEAR(occurred_at), WEEK(occurred_at), year(occurred_at);
-- considering all the details from Year 2014


# 2. User Growth: Amount of users growing over time for a product.
#	Your task: Calculate the user growth for product?

SELECT
  DATE_FORMAT(created_at, '%Y-%m') AS month,
  COUNT(DISTINCT user_id) AS user_growth,
  ROUND((COUNT(DISTINCT user_id) - LAG(COUNT(DISTINCT user_id))
		OVER (ORDER BY DATE_FORMAT(created_at, '%Y-%m'))) / 
        LAG(COUNT(DISTINCT user_id)) 
        OVER (ORDER BY DATE_FORMAT(created_at, '%Y-%m')) * 100, 1) 
        AS growth_rate
FROM users
GROUP BY month
ORDER BY month;



# 3. Weekly Retention: Users getting retained weekly after signing-up for a product.
# Your task: Calculate the weekly retention of users-sign up cohort?

select event_name from events
group by event_name;


SELECT
  sign_up_week,
  retention_week,
  COUNT(DISTINCT subquery.user_id) AS active_users,
  COUNT(DISTINCT subquery.user_id) * 100 / NULLIF(COUNT(DISTINCT CASE WHEN retention_week = 1 THEN subquery.user_id END), 0) AS retention_rate
FROM
  (
    SELECT
      DATE_FORMAT(created_at, '%Y-%u') AS sign_up_week,
      DATE_FORMAT(occurred_at, '%Y-%u') AS retention_week,
      u.user_id
    FROM
      users u
      JOIN events e ON u.user_id = e.user_id
    WHERE
      e.occurred_at >= u.created_at
    GROUP BY
      sign_up_week,
      retention_week,
      u.user_id
  ) subquery
GROUP BY
  sign_up_week,
  retention_week
ORDER BY
  sign_up_week,
  retention_week;
  
  
# 4. Weekly Engagement: To measure the activeness of a user. 
#	Measuring if the user finds quality in a product/service weekly.
# Your task: Calculate the weekly engagement per device?

select * from users;
select * from events;
select * from email;


SELECT
  DATE_FORMAT(occurred_at, '%Y-%u') AS week,
  device,
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_id) AS unique_users,
  COUNT(*) / COUNT(DISTINCT user_id) AS engagement_per_user
FROM events
GROUP BY week, device
ORDER BY week, device;



# Email Engagement: Users engaging with the email service.
# Your task: Calculate the email engagement metrics?

-- By week
SELECT
  DATE_FORMAT(occurred_at, '%Y-%u') AS week,
  COUNT(DISTINCT CASE WHEN action = 'email_open' THEN user_id END) AS email_open_count,
  COUNT(DISTINCT CASE WHEN action = 'email_clickthrough' THEN user_id END) AS email_clickthrough_count
  FROM email
GROUP BY week
ORDER BY week;


-- Total engagement
SELECT
  COUNT(DISTINCT CASE WHEN action = 'email_open' THEN user_id END) AS email_open_count,
  COUNT(DISTINCT CASE WHEN action = 'click_link' THEN user_id END) AS click_through_count,
  COUNT(DISTINCT CASE WHEN action = 'conversion' THEN user_id END) AS conversion_count,
  COUNT(DISTINCT user_id) AS total_users,
  COUNT(DISTINCT CASE WHEN action = 'email_open' OR action = 'click_link' OR action = 'conversion' THEN user_id END) AS engaged_users,
  COUNT(DISTINCT CASE WHEN action = 'email_open' OR action = 'click_link' OR action = 'conversion' THEN user_id END) / COUNT(DISTINCT user_id) * 100 AS engagement_rate
FROM email;
