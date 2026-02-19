WITH pool_fees AS (
    SELECT
        pool AS pool_address,
        fee / 1e6 AS fee_rate
    FROM uniswap_v3_ethereum.Factory_evt_PoolCreated
),

period_fees AS (
    SELECT
        CASE
            WHEN t.block_date < DATE '2025-12-27' THEN 'Pre-Switch'
            ELSE 'Post-Switch'
        END AS period,
        COUNT(DISTINCT t.block_date) AS days,
        ROUND(SUM(t.amount_usd) / COUNT(DISTINCT t.block_date), 0) AS avg_daily_volume,
        ROUND(SUM(t.amount_usd * p.fee_rate) / COUNT(DISTINCT t.block_date), 0) AS avg_daily_pool_fees
    FROM dex.trades t
    LEFT JOIN pool_fees p
        ON t.project_contract_address = p.pool_address
    WHERE t.blockchain = 'ethereum'
      AND t.project = 'uniswap'
      AND t.version = '3'
      AND t.block_date >= DATE '2025-11-01'
      AND t.block_date <= DATE '2026-02-17'
      AND t.amount_usd > 0
      AND t.amount_usd < 1e10
    GROUP BY 1
)

SELECT
    period,
    days,
    avg_daily_volume,
    avg_daily_pool_fees,
    ROUND(
        CASE
            WHEN period = 'Pre-Switch' THEN avg_daily_pool_fees * 1.0
            ELSE avg_daily_pool_fees * 0.85
        END, 0
    ) AS avg_daily_lp_earnings,
    ROUND(
        CASE
            WHEN period = 'Pre-Switch' THEN 0
            ELSE avg_daily_pool_fees * 0.15
        END, 0
    ) AS redirected_to_protocol
FROM period_fees
ORDER BY period
