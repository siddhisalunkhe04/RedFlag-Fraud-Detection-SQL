use redflag;
SELECT COUNT(*)
FROM transactions;

SELECT COUNT(DISTINCT user_id)
FROM transactions;

SELECT MIN(txn_time), MAX(txn_time)
FROM transactions;

SELECT *
FROM transactions
LIMIT 10;

SELECT status, COUNT(*) AS transaction_count
FROM transactions
GROUP BY status;

SELECT payment_mode, COUNT(*) AS transaction_count
FROM transactions
GROUP BY payment_mode
ORDER BY transaction_count DESC;

SELECT txn_type, COUNT(*) AS transaction_count
FROM transactions
GROUP BY txn_type;

SELECT city, COUNT(*) AS transaction_count
FROM transactions
GROUP BY city
ORDER BY transaction_count DESC;

SELECT
    MIN(amount) AS minimum_amount,
    MAX(amount) AS maximum_amount,
    AVG(amount) AS average_amount
FROM transactions;

SELECT COUNT(DISTINCT merchant_id) AS total_merchants
FROM transactions;

SELECT
    user_id,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY user_id
ORDER BY transaction_count DESC
LIMIT 10;

SELECT
    DATE(txn_time) AS transaction_date,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY DATE(txn_time)
ORDER BY transaction_date;

SELECT COUNT(*)
FROM transactions;

SELECT COUNT(DISTINCT user_id)
FROM transactions;

SELECT MIN(txn_time), MAX(txn_time)
FROM transactions;

SELECT
    DATE(txn_time) AS transaction_date,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY DATE(txn_time)
ORDER BY transaction_date DESC
LIMIT 5;

-- Data Exploration
SELECT
    status,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY status;

SELECT
    payment_mode,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY payment_mode;

SELECT
    txn_type,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY txn_type;

SELECT
    COUNT(DISTINCT merchant_id) AS total_merchants
FROM transactions;

SELECT
    COUNT(DISTINCT city) AS total_cities
FROM transactions;

SELECT
    city,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY city
ORDER BY transaction_count DESC;

-- velocity fraud
SELECT
    user_id,
    DATE(txn_time) AS transaction_date,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY
    user_id,
    DATE(txn_time)
ORDER BY transaction_count DESC;

SELECT
    user_id,
    DATE(txn_time) AS transaction_date,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY
    user_id,
    DATE(txn_time)
ORDER BY transaction_count DESC;

SELECT
    user_id,
    DATE(txn_time) AS transaction_date,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY
    user_id,
    DATE(txn_time)
HAVING COUNT(*) >= 30
ORDER BY transaction_count DESC;

-- P1: Velocity Fraud
-- Flag users making 30 or more transactions in a single day

SELECT
    user_id,
    DATE(txn_time) AS transaction_date,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY
    user_id,
    DATE(txn_time)
HAVING COUNT(*) >= 30
ORDER BY transaction_count DESC;

SELECT
    amount,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY amount
ORDER BY transaction_count DESC
LIMIT 20;

SELECT
    user_id,
    amount,
    COUNT(*) AS transaction_count
FROM transactions
WHERE amount IN (100, 200, 500, 1000, 2000, 5000, 10000)
GROUP BY
    user_id,
    amount
ORDER BY transaction_count DESC;

SELECT
    user_id,
    COUNT(*) AS round_amount_transactions
FROM transactions
WHERE amount IN (100, 200, 500, 1000, 2000, 5000, 10000)
GROUP BY user_id
ORDER BY round_amount_transactions DESC;

-- P2: Round-Amount Clustering
-- Identifies users who repeatedly make transactions using common round-value amounts.
SELECT
    user_id,
    COUNT(*) AS round_amount_transactions
FROM transactions
WHERE amount IN (100, 200, 500, 1000, 2000, 5000, 10000)
GROUP BY user_id
HAVING COUNT(*) >= 15
ORDER BY round_amount_transactions DESC;

-- P2: Round-Amount Clustering
-- Finds users who repeatedly use a set of commonly observed round transaction values.
SELECT
    user_id,
    COUNT(*) AS round_amount_transactions
FROM transactions
WHERE amount IN (100, 200, 500, 1000, 2000, 5000, 10000)
GROUP BY user_id
HAVING COUNT(*) >= 15
ORDER BY round_amount_transactions DESC;
-- P3: Card Testing
-- Checks for unusually frequent low-value transactions that may indicate card testing.

SELECT
    user_id,
    DATE(txn_time) AS transaction_date,
    COUNT(*) AS low_value_transactions
FROM transactions
WHERE amount < 10
GROUP BY
    user_id,
    DATE(txn_time)
ORDER BY low_value_transactions DESC;

-- P3: Card Testing
-- Identifies users making many low-value transactions on the same day.
SELECT
    user_id,
    DATE(txn_time) AS transaction_date,
    COUNT(*) AS low_value_transactions
FROM transactions
WHERE amount < 10
GROUP BY
    user_id,
    DATE(txn_time)
HAVING COUNT(*) >= 30
ORDER BY low_value_transactions DESC;

-- P4: Failed-Then-Succeeded
-- Counts failed transactions for each user as the first step in identifying repeated payment failures.
SELECT
    user_id,
    COUNT(*) AS failed_transactions
FROM transactions
WHERE status = 'FAILED'
GROUP BY user_id
ORDER BY failed_transactions DESC;

-- P4: Failed-Then-Succeeded
-- Finds users with a high number of failed payment attempts.
SELECT
    user_id,
    COUNT(*) AS failed_transactions
FROM transactions
WHERE status = 'FAILED'
GROUP BY user_id
HAVING COUNT(*) >= 20
ORDER BY failed_transactions DESC;

-- P4: Failed-Then-Succeeded
-- Counts users who have at least 20 failed transaction attempts.
SELECT
    COUNT(*) AS flagged_users
FROM (
    SELECT
        user_id
    FROM transactions
    WHERE status = 'FAILED'
    GROUP BY user_id
    HAVING COUNT(*) >= 20
) AS failed_users;

-- P4: Failed-Then-Succeeded
-- Finds users with repeated failed payment attempts.
SELECT
    user_id,
    COUNT(*) AS failed_transactions
FROM transactions
WHERE status = 'FAILED'
GROUP BY user_id
HAVING COUNT(*) >= 20
ORDER BY failed_transactions DESC;

-- P5: Odd-Hour Concentration
-- Compares each user's overall transaction activity with activity during the 2 AM to 4 AM period.
SELECT
    user_id,
    COUNT(*) AS total_transactions,
    SUM(
        CASE
            WHEN HOUR(txn_time) BETWEEN 2 AND 4 THEN 1
            ELSE 0
        END
    ) AS odd_hour_transactions
FROM transactions
GROUP BY user_id
ORDER BY odd_hour_transactions DESC;

-- P5: Odd-Hour Concentration
-- Flags users whose transaction activity is heavily concentrated between 2 AM and 4 AM.
SELECT
    user_id,
    COUNT(*) AS total_transactions,
    SUM(
        CASE
            WHEN HOUR(txn_time) BETWEEN 2 AND 4 THEN 1
            ELSE 0
        END
    ) AS odd_hour_transactions
FROM transactions
GROUP BY user_id
HAVING COUNT(*) >= 30
   AND SUM(
        CASE
            WHEN HOUR(txn_time) BETWEEN 2 AND 4 THEN 1
            ELSE 0
        END
   ) / COUNT(*) >= 0.80
ORDER BY odd_hour_transactions DESC;

-- P6: Mule Accounts
-- Counts credit transactions for each user as the first step in identifying possible mule accounts.
SELECT
    user_id,
    COUNT(*) AS credit_transactions
FROM transactions
WHERE txn_type = 'CREDIT'
GROUP BY user_id
ORDER BY credit_transactions DESC;

-- P6: Mule Accounts
-- Identifies users receiving credit transactions frequently enough to warrant review.
SELECT
    user_id,
    COUNT(*) AS credit_transactions
FROM transactions
WHERE txn_type = 'CREDIT'
GROUP BY user_id
HAVING COUNT(*) >= 8
ORDER BY credit_transactions DESC;

-- P6: Mule Accounts
-- Identifies users receiving a high number of credit transactions.
SELECT
    user_id,
    COUNT(*) AS credit_transactions
FROM transactions
WHERE txn_type = 'CREDIT'
GROUP BY user_id
HAVING COUNT(*) >= 8
ORDER BY credit_transactions DESC;

-- P6: Mule Accounts
-- Pairs credit transactions with later debit transactions made by the same user.
SELECT
    c.user_id,
    c.txn_id AS credit_txn_id,
    c.amount AS credit_amount,
    c.txn_time AS credit_time,
    d.txn_id AS debit_txn_id,
    d.amount AS debit_amount,
    d.txn_time AS debit_time
FROM transactions c
JOIN transactions d
    ON c.user_id = d.user_id
   AND c.txn_type = 'CREDIT'
   AND d.txn_type = 'DEBIT'
   AND d.txn_time > c.txn_time
ORDER BY c.user_id, c.txn_time;

-- P6: Mule Accounts - Advanced Check
-- Finds credit transactions followed by a debit from the same user within 30 minutes.
SELECT
    c.user_id,
    c.txn_id AS credit_txn_id,
    c.amount AS credit_amount,
    c.txn_time AS credit_time,
    d.txn_id AS debit_txn_id,
    d.amount AS debit_amount,
    d.txn_time AS debit_time
FROM transactions c
JOIN transactions d
    ON c.user_id = d.user_id
   AND c.txn_type = 'CREDIT'
   AND d.txn_type = 'DEBIT'
   AND d.txn_time > c.txn_time
   AND TIMESTAMPDIFF(MINUTE, c.txn_time, d.txn_time) <= 30
ORDER BY c.user_id, c.txn_time;

-- P6: Mule Accounts - Advanced Check
-- Finds credit transactions followed by a debit of at least 70% of the credit amount within 30 minutes.
SELECT
    c.user_id,
    c.txn_id AS credit_txn_id,
    c.amount AS credit_amount,
    c.txn_time AS credit_time,
    d.txn_id AS debit_txn_id,
    d.amount AS debit_amount,
    d.txn_time AS debit_time
FROM transactions c
JOIN transactions d
    ON c.user_id = d.user_id
   AND c.txn_type = 'CREDIT'
   AND d.txn_type = 'DEBIT'
   AND d.txn_time > c.txn_time
   AND d.txn_time <= c.txn_time + INTERVAL 30 MINUTE
   AND d.amount >= 0.70 * c.amount
ORDER BY c.user_id, c.txn_time;

-- P6: Mule Accounts - Final
-- Identifies users with at least 5 credit-to-debit instances
-- where the debit occurs within 30 minutes and is at least 70% of the credit.
SELECT
    c.user_id,
    COUNT(*) AS qualifying_instances
FROM transactions c
JOIN transactions d
    ON c.user_id = d.user_id
   AND c.txn_type = 'CREDIT'
   AND d.txn_type = 'DEBIT'
   AND d.txn_time > c.txn_time
   AND d.txn_time <= c.txn_time + INTERVAL 30 MINUTE
   AND d.amount >= 0.70 * c.amount
GROUP BY c.user_id
HAVING COUNT(*) >= 5
ORDER BY qualifying_instances DESC;

-- P6: Mule Accounts
-- Identifies users with at least 5 credit-to-debit instances
-- where the debit occurs within 30 minutes and is at least 70% of the credit.
SELECT
    c.user_id,
    COUNT(*) AS qualifying_instances
FROM transactions c
JOIN transactions d
    ON c.user_id = d.user_id
   AND c.txn_type = 'CREDIT'
   AND d.txn_type = 'DEBIT'
   AND d.txn_time > c.txn_time
   AND d.txn_time <= c.txn_time + INTERVAL 30 MINUTE
   AND d.amount >= 0.70 * c.amount
GROUP BY c.user_id
HAVING COUNT(*) >= 5
ORDER BY qualifying_instances DESC;

-- P7: Refund Abuse
-- Counts total transactions and refund transactions for each user.
SELECT
    user_id,
    COUNT(*) AS total_transactions,
    SUM(
        CASE
            WHEN txn_type = 'REFUND' THEN 1
            ELSE 0
        END
    ) AS refund_transactions
FROM transactions
GROUP BY user_id
ORDER BY refund_transactions DESC;

-- P7: Refund Abuse
-- Identifies users with at least 20 transactions where refunds make up
-- more than 40% of their total transaction activity.
SELECT
    user_id,
    COUNT(*) AS total_transactions,
    SUM(
        CASE
            WHEN txn_type = 'REFUND' THEN 1
            ELSE 0
        END
    ) AS refund_transactions
FROM transactions
GROUP BY user_id
HAVING COUNT(*) >= 20
   AND SUM(
        CASE
            WHEN txn_type = 'REFUND' THEN 1
            ELSE 0
        END
       ) / COUNT(*) > 0.40
ORDER BY refund_transactions DESC;

SELECT COUNT(*) AS flagged_users
FROM (
    SELECT
        user_id
    FROM transactions
    GROUP BY user_id
    HAVING COUNT(*) >= 20
       AND SUM(
            CASE
                WHEN txn_type = 'REFUND' THEN 1
                ELSE 0
           END
       ) / COUNT(*) > 0.40
) AS refund_abuse_users;

-- P8: Merchant Collusion
-- Counts how many transactions each user has made with each merchant.

SELECT
    merchant_id,
    user_id,
    COUNT(*) AS user_transactions
FROM transactions
GROUP BY
    merchant_id,
    user_id
ORDER BY
    merchant_id,
    user_transactions DESC;
    
-- P8: Merchant Collusion - Ranking Users
-- Assigns a transaction-volume rank to each user within every merchant.

SELECT
    merchant_id,
    user_id,
    COUNT(*) AS user_transactions,
    ROW_NUMBER() OVER (
        PARTITION BY merchant_id
        ORDER BY COUNT(*) DESC
    ) AS user_rank
FROM transactions
GROUP BY
    merchant_id,
    user_id
ORDER BY
    merchant_id,
    user_rank;
    
-- P8: Merchant Collusion - Top 5 Users
-- Keeps the five highest-volume users for each merchant.
SELECT
    merchant_id,
    user_id,
    user_transactions,
    user_rank
FROM (
    SELECT
        merchant_id,
        user_id,
        COUNT(*) AS user_transactions,
        ROW_NUMBER() OVER (
            PARTITION BY merchant_id
            ORDER BY COUNT(*) DESC
        ) AS user_rank
    FROM transactions
    GROUP BY
        merchant_id,
        user_id
) AS ranked_users
WHERE user_rank <= 5
ORDER BY
    merchant_id,
    user_rank;
    
-- P8: Merchant Collusion - Top 5 Contribution
-- Calculates how much of each merchant's transaction volume comes from its top 5 users.
SELECT
    merchant_id,
    SUM(user_transactions) AS top_5_transactions,
    (
        SELECT COUNT(*)
        FROM transactions t2
        WHERE t2.merchant_id = ranked_users.merchant_id
    ) AS merchant_total_transactions
FROM (
    SELECT
        merchant_id,
        user_id,
        COUNT(*) AS user_transactions,
        ROW_NUMBER() OVER (
            PARTITION BY merchant_id
            ORDER BY COUNT(*) DESC
        ) AS user_rank
    FROM transactions
    GROUP BY
        merchant_id,
        user_id
) AS ranked_users
WHERE user_rank <= 5
GROUP BY merchant_id
ORDER BY merchant_id;

-- P8: Merchant Collusion
-- Flags merchants where the top 5 users contribute more than 60%
-- of the merchant's total transaction volume.
SELECT
    merchant_id,
    SUM(user_transactions) AS top_5_transactions,
    (
        SELECT COUNT(*)
        FROM transactions t2
        WHERE t2.merchant_id = ranked_users.merchant_id
    ) AS merchant_total_transactions
FROM (
    SELECT
        merchant_id,
        user_id,
        COUNT(*) AS user_transactions,
        ROW_NUMBER() OVER (
            PARTITION BY merchant_id
            ORDER BY COUNT(*) DESC
        ) AS user_rank
    FROM transactions
    GROUP BY
        merchant_id,
        user_id
) AS ranked_users
WHERE user_rank <= 5
GROUP BY merchant_id
HAVING SUM(user_transactions) / (
    SELECT COUNT(*)
    FROM transactions t2
    WHERE t2.merchant_id = ranked_users.merchant_id
) > 0.60
ORDER BY merchant_id;

-- P9: Just-Under-Threshold
-- Counts transactions made at exactly ₹9,999 for each user.
SELECT
    user_id,
    COUNT(*) AS threshold_transactions
FROM transactions
WHERE amount = 9999
GROUP BY user_id
ORDER BY threshold_transactions DESC;

-- P9: Just-Under-Threshold
-- Identifies users who made at least 10 transactions exactly at ₹9,999.
SELECT
    user_id,
    COUNT(*) AS threshold_transactions
FROM transactions
WHERE amount = 9999
GROUP BY user_id
HAVING COUNT(*) >= 10
ORDER BY threshold_transactions DESC;

-- P10: Dormant-Then-Active - Step 1
-- Finds the previous transaction time for each user's transactions.
SELECT
    user_id,
    txn_id,
    txn_time,
    LAG(txn_time) OVER (
        PARTITION BY user_id
        ORDER BY txn_time
    ) AS previous_txn_time
FROM transactions
ORDER BY user_id, txn_time;

-- P10: Dormant-Then-Active - Step 2
-- Calculates the number of days between consecutive transactions for each user.
SELECT
    user_id,
    txn_id,
    txn_time,
    previous_txn_time,
    TIMESTAMPDIFF(
        DAY,
        previous_txn_time,
        txn_time
    ) AS gap_days
FROM (
    SELECT
        user_id,
        txn_id,
        txn_time,
        LAG(txn_time) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_txn_time
    FROM transactions
) AS user_transactions
ORDER BY user_id, txn_time;

-- P10: Dormant-Then-Active - Step 3
-- Identifies transactions that occur after a dormant period of at least 90 days.
SELECT
    user_id,
    txn_id,
    txn_time,
    previous_txn_time,
    gap_days
FROM (
    SELECT
        user_id,
        txn_id,
        txn_time,
        previous_txn_time,
        TIMESTAMPDIFF(
            DAY,
            previous_txn_time,
            txn_time
        ) AS gap_days
    FROM (
        SELECT
            user_id,
            txn_id,
            txn_time,
            LAG(txn_time) OVER (
                PARTITION BY user_id
                ORDER BY txn_time
            ) AS previous_txn_time
        FROM transactions
    ) AS user_transactions
) AS transaction_gaps
WHERE gap_days >= 90
ORDER BY user_id, txn_time;

-- P10: Dormant-Then-Active - Step 4
-- Counts the transactions made by each user after a dormant period of at least 90 days.
SELECT
    dormant.user_id,
    dormant.txn_time AS reactivation_time,
    (
        SELECT COUNT(*)
        FROM transactions t2
        WHERE t2.user_id = dormant.user_id
          AND t2.txn_time >= dormant.txn_time
    ) AS post_gap_transactions
FROM (
    SELECT
        user_id,
        txn_time,
        LAG(txn_time) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_txn_time
    FROM transactions
) AS dormant
WHERE TIMESTAMPDIFF(
          DAY,
          dormant.previous_txn_time,
          dormant.txn_time
      ) >= 90
ORDER BY post_gap_transactions DESC;

-- P10: Dormant-Then-Active
-- Identifies users who became active again after a 90-day or longer
-- gap and then made at least 15 transactions.
SELECT
    user_id,
    reactivation_time,
    post_gap_transactions
FROM (
    SELECT
        dormant.user_id,
        dormant.txn_time AS reactivation_time,
        (
            SELECT COUNT(*)
            FROM transactions t2
            WHERE t2.user_id = dormant.user_id
              AND t2.txn_time >= dormant.txn_time
        ) AS post_gap_transactions
    FROM (
        SELECT
            user_id,
            txn_time,
            LAG(txn_time) OVER (
                PARTITION BY user_id
                ORDER BY txn_time
            ) AS previous_txn_time
        FROM transactions
    ) AS dormant
    WHERE TIMESTAMPDIFF(
              DAY,
              dormant.previous_txn_time,
              dormant.txn_time
          ) >= 90
) AS dormant_users
WHERE post_gap_transactions >= 15
ORDER BY post_gap_transactions DESC;

-- P10 Verification
-- Counts the users who became active after a 90+ day gap
-- and then made at least 15 transactions.

SELECT COUNT(*) AS flagged_users
FROM (
    SELECT
        user_id,
        reactivation_time,
        post_gap_transactions
    FROM (
        SELECT
            dormant.user_id,
            dormant.txn_time AS reactivation_time,
            (
                SELECT COUNT(*)
                FROM transactions t2
                WHERE t2.user_id = dormant.user_id
                  AND t2.txn_time >= dormant.txn_time
            ) AS post_gap_transactions
        FROM (
            SELECT
                user_id,
                txn_time,
                LAG(txn_time) OVER (
                    PARTITION BY user_id
                    ORDER BY txn_time
                ) AS previous_txn_time
            FROM transactions
        ) AS dormant
        WHERE TIMESTAMPDIFF(
                  DAY,
                  dormant.previous_txn_time,
                  dormant.txn_time
              ) >= 90
    ) AS dormant_users
    WHERE post_gap_transactions >= 15
) AS flagged_users_list;

-- P11: Velocity Spike - Step 1
-- Counts the number of transactions made by each user in each month.
SELECT
    user_id,
    MONTH(txn_time) AS transaction_month,
    COUNT(*) AS monthly_transactions
FROM transactions
GROUP BY
    user_id,
    MONTH(txn_time)
ORDER BY
    user_id,
    transaction_month;
    
-- P11: Velocity Spike - Step 2
-- Finds the average and highest monthly transaction count for each user.
SELECT
    user_id,
    transaction_month,
    monthly_transactions,
    AVG(monthly_transactions) OVER (
        PARTITION BY user_id
    ) AS average_monthly_transactions,
    MAX(monthly_transactions) OVER (
        PARTITION BY user_id
    ) AS peak_monthly_transactions
FROM (
    SELECT
        user_id,
        MONTH(txn_time) AS transaction_month,
        COUNT(*) AS monthly_transactions
    FROM transactions
    GROUP BY
        user_id,
        MONTH(txn_time)
) AS monthly_data
ORDER BY user_id, transaction_month;