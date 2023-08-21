# Operation-Analytics-and-Investigating-Metric_Spike-Trainity

 
## Project Description:
This project focuses on two aspects of data analysis: operation analytics and investigating metric spikes. In operation analytics, the goal is to analyse the end-to-end operations of a company and derive insights to improve various aspects such as workflows, cross-functional team collaboration, and automation. The project involves working closely with teams like operations, support, and marketing to analyse the collected data and predict the company's growth or decline. On the other hand, investigating metric spikes aims to understand anomalies or fluctuations in specific metrics to identify underlying causes and take appropriate actions. The project involves analysing datasets related to user engagement, user growth, weekly retention, weekly engagement, and email engagement to uncover patterns and insights.

### Case Study 1 (Job Data):
•	Table-1: jobs

o	job_id: unique identifier of jobs
o	actor_id: unique identifier of actor
o	event: decision/skip/transfer
o	language: language of the content
o	time_spent: time spent to review the job in seconds
o	org: organization of the actor
o	ds: date in the yyyy/mm/dd format. It is stored in the form of text, and we use presto to run. no need for date function

#### Case Study 2 (Investigating metric spike):
•	Table-1: users
o	This table includes one row per user, with descriptive information about that user’s account.
•	Table-2: events
o	This table includes one row per event, where an event is an action that a user has taken. These events include login events, messaging events, search events, events logged as users progress through a signup funnel, events around received emails.
•	Table-3: email
o	 contains events specific to the sending of emails. It is similar in structure to the events table above.


## Approach:
The project was approached by first understanding the requirements and questions posed by different departments. The relevant datasets, such as job_data, users, events, and email_events, were collected and analysed using SQL queries. The queries were designed to calculate specific metrics and derive meaningful insights. The results were then examined, and patterns and trends were identified. The analysis was performed iteratively, refining the queries and adjusting the approach as needed to ensure accurate and relevant insights.
Tech-Stack Used:
The project utilized SQL for data analysis and query execution. The SQL queries were executed using tools such as MySQL Workbench. The purpose of using SQL was to efficiently extract, transform, and analyse the data from the provided datasets. The use of SQL allowed me for easy manipulation of the datasets and enabled the calculation of various metrics and insights based on the specific requirements.
Insights:
Throughout the project, several key insights were gained. In operation analytics, the number of jobs reviewed per hour per day for November 2020 was calculated, providing a deeper understanding of the workload distribution. The 7-day rolling average of throughput was computed to observe the trend in event occurrences and account for fluctuations. The percentage share of each language in the last 30 days was analysed, shedding light on language preferences among users. Duplicate rows were identified using appropriate SQL queries to help maintain data integrity and cleanliness.

In investigating metric spikes, user engagement, user growth, weekly retention, and weekly engagement were calculated to measure different aspects of user activity and product/service quality. Email engagement metrics were determined to assess the level of user engagement with the email service. These insights helped identify trends, anomalies, and areas of improvement in the analysed metrics, providing valuable information for decision-making and optimization.
Result:
The project successfully addressed the questions and requirements presented in the case studies related to operation analytics and investigating metric spikes. By analysing the provided datasets and executing the appropriate queries, meaningful insights were derived for each aspect. The results provided a deeper understanding of user behaviour, product/service quality, user growth, and the effectiveness of email engagement. The project has helped in making data-driven decisions, identifying areas for improvement, and optimizing various operational aspects within the company.
Analysis using SQL
Case Study 1 – Jobs data:
A.	Number of jobs reviewed: Amount of jobs reviewed over time.
Your task: Calculate the number of jobs reviewed per hour per day for November 2020?


`SELECT 
    ds,
    COUNT(job_id) AS jobs_per_day,
    SUM(time_spent / 3600) AS jobs_per_hour
FROM jobs
WHERE ds BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY ds
ORDER BY jobs_per_day;`

 ![image](https://github.com/rohithsomella/Operation-Analytics-and-Investigating-Metric_Spike-Trainity/assets/141708838/145bc7ea-96f8-4ba2-b1fb-59755d1e8a33)



B.	Throughput: It is the no. of events happening per second.
Your task: Let’s say the above metric is called throughput. Calculate 7 day rolling average of throughput? For throughput, do you prefer daily metric or 7-day rolling and why?

`SELECT
  ds, COUNT(*) AS daily_throughput,
  AVG(COUNT(*)) OVER(ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
  AS rolling_average_throughput
FROM jobs GROUP BY ds;`

![image](https://github.com/rohithsomella/Operation-Analytics-and-Investigating-Metric_Spike-Trainity/assets/141708838/6c739d29-53f7-492e-96ab-94d03b15901f)

 


C.	Percentage share of each language: Share of each language for different contents.
Your task: Calculate the percentage share of each language in the last 30 days?

`SELECT 
    language,
    ((COUNT(*) / (SELECT 
            COUNT(language)
        FROM jobs)) * 100) AS percent
FROM jobs
GROUP BY language
ORDER BY percent;`

 ![image](https://github.com/rohithsomella/Operation-Analytics-and-Investigating-Metric_Spike-Trainity/assets/141708838/4ab14bc5-305f-4db0-83c2-6cee5371bb3f)



D.	Duplicate rows: Rows that have the same value present in them.
Your task: Let’s say you see some duplicate rows in the data. How will you display duplicates from the table?

`SELECT ds, job_id, actor_id, event, language, time_spent, org, COUNT(*)
FROM jobs
GROUP BY ds , job_id , actor_id , event , language , time_spent , org
HAVING COUNT(*) > 1;`

![image](https://github.com/rohithsomella/Operation-Analytics-and-Investigating-Metric_Spike-Trainity/assets/141708838/84c72db2-955c-4ff3-86dc-b4146933d183)

 
No Duplicate rows.

## Case Study 2 (Investigating metric spike):
A.	User Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service.
Your task: Calculate the weekly user engagement?

`SELECT YEAR(occurred_at) AS year,
WEEK(occurred_at) AS week, COUNT(*) AS engagement_count
FROM events
WHERE event_type = 'engagement'
GROUP BY YEAR(occurred_at), WEEK(occurred_at), YEAR(occurred_at);`

 ![image](https://github.com/rohithsomella/Operation-Analytics-and-Investigating-Metric_Spike-Trainity/assets/141708838/bcb38b92-0e16-4b22-9407-7025d5c13301)



B.	User Growth: Amount of users growing over time for a product.
Your task: Calculate the user growth for the product.

`SELECT
  DATE_FORMAT(created_at, '%Y-%m') AS month,
  COUNT(DISTINCT user_id) AS user_growth,
  ROUND((COUNT(DISTINCT user_id) - LAG(COUNT(DISTINCT user_id))
		OVER (ORDER BY DATE_FORMAT(created_at, '%Y-%m'))) / 
        LAG(COUNT(DISTINCT user_id)) 
        OVER (ORDER BY DATE_FORMAT(created_at, '%Y-%m')) * 100, 1) 
        AS growth_rate
FROM users
GROUP BY month
ORDER BY month;`
   
![image](https://github.com/rohithsomella/Operation-Analytics-and-Investigating-Metric_Spike-Trainity/assets/141708838/5d7dde82-83fd-4d45-8129-fb8cce119ba9)
![image](https://github.com/rohithsomella/Operation-Analytics-and-Investigating-Metric_Spike-Trainity/assets/141708838/08d63581-eff0-40be-8975-030b4528af3b)


C.	Weekly Retention: Users getting retained weekly after signing-up for a product.
Your task: Calculate the weekly retention of users-sign up cohort?

`SELECT
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
  retention_week;`
![image](https://github.com/rohithsomella/Operation-Analytics-and-Investigating-Metric_Spike-Trainity/assets/141708838/cec83f67-6691-4c01-90e6-b81f1e596cc1)

  …


D.	Weekly Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service weekly.
Your task: Calculate the weekly engagement per device?

`SELECT
  DATE_FORMAT(occurred_at, '%Y-%u') AS week,
  device,
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_id) AS unique_users,
  COUNT(*) / COUNT(DISTINCT user_id) AS engagement_per_user
FROM events
GROUP BY week, device
ORDER BY week, device;`

 ![image](https://github.com/rohithsomella/Operation-Analytics-and-Investigating-Metric_Spike-Trainity/assets/141708838/7720ece9-2d7d-4a8e-87e7-c3f290840747)



E.	Email Engagement: Users engaging with the email service.
Your task: Calculate the email engagement metrics?
By Week:

`SELECT
  DATE_FORMAT(occurred_at, '%Y-%u') AS week,
  COUNT(DISTINCT CASE WHEN action = 'email_open' THEN user_id END) AS email_open_count,
  COUNT(DISTINCT CASE WHEN action = 'email_clickthrough' THEN user_id END) AS email_clickthrough_count
  FROM email
GROUP BY week
ORDER BY week;`

![image](https://github.com/rohithsomella/Operation-Analytics-and-Investigating-Metric_Spike-Trainity/assets/141708838/dc892177-ed10-4763-aaaa-b1177e936295)

 

Total Engagement:

`SELECT
  COUNT(DISTINCT CASE WHEN action = 'email_open' THEN user_id END) AS email_open_count,
  COUNT(DISTINCT CASE WHEN action = 'click_link' THEN user_id END) AS click_through_count,
  COUNT(DISTINCT CASE WHEN action = 'conversion' THEN user_id END) AS conversion_count,
  COUNT(DISTINCT user_id) AS total_users,
  COUNT(DISTINCT CASE WHEN action = 'email_open' OR action = 'click_link' OR action = 'conversion' THEN user_id END) AS engaged_users,
  COUNT(DISTINCT CASE WHEN action = 'email_open' OR action = 'click_link' OR action = 'conversion' THEN user_id END) / COUNT(DISTINCT user_id) * 100 AS engagement_rate
FROM email;`
![image](https://github.com/rohithsomella/Operation-Analytics-and-Investigating-Metric_Spike-Trainity/assets/141708838/fd1a3294-8f84-4e21-9e5e-8fd2c7314613)

 


SQL File Link: Operation Analysis and Investigating Metric Spike
