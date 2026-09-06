# RedFlag — Fraud Detection Using SQL

RedFlag is a fraud detection project built using MySQL and SQL. The project uses 200,000 simulated payment transactions from an Indian payment aggregator and identifies different suspicious transaction patterns. I used SQL techniques such as GROUP BY, HAVING, CASE WHEN, JOINs, subqueries, and window functions to detect potential fraud without using Python or Machine Learning.

## Fraud Patterns Detected

- Velocity Fraud
- Round-Amount Clustering
- Card Testing
- Failed-Then-Succeeded Transactions
- Odd-Hour Concentration
- Mule Accounts
- Refund Abuse
- Merchant Collusion
- Just-Under-Threshold Transactions
- Dormant-Then-Active Accounts
- Velocity Spike
- Geographic Impossibility

## Tech Stack

- MySQL
- SQL
- GitHub

## Project Screenshot

![Fraud Detection Query Output](screenshots/p8_merchant_collusion.png)

## Project Files

- `RedFlag_Siddhi.sql` — SQL queries for all 12 fraud patterns
- `screenshots/` — Query output screenshots

## Dataset

The project uses a simulated dataset of approximately 200,000 payment transactions.

The original dataset file is not included in this repository because of its large size. It can be provided separately if required.
