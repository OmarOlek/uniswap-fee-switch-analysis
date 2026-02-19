WITH pool_fees AS (
    SELECT
        pool AS pool_address,
        fee / 1e6 AS fee_rate
    FROM uniswap_v3_ethereum.Factory_evt_PoolCreated
)

SELECT
    CASE
        WHEN t.block_date < DATE '2025-12-27' THEN 'Pre-Switch'
        ELSE 'Post-Switch'
    END AS period,
    COUNT(DISTINCT t.block_date) AS days,
    ROUND(SUM(t.amount_usd) / COUNT(DISTINCT t.block_date), 0) AS avg_daily_volume,
    ROUND(SUM(t.amount_usd * p.fee_rate) / COUNT(DISTINCT t.block_date), 0) AS avg_daily_pool_fees,
    ROUND(
        CASE
            WHEN t.block_date < DATE '2025-12-27'
            THEN SUM(t.amount_usd * p.fee_rate) / COUNT(DISTINCT t.block_date) * 1.0
            ELSE SUM(t.amount_usd * p.fee_rate) / COUNT(DISTINCT t.block_date) * 0.85
        END, 0
    ) AS avg_daily_lp_earnings,
    ROUND(SUM(t.amount_usd * p.fee_rate) / COUNT(DISTINCT t.block_date), 0)
        - ROUND(
            CASE
                WHEN t.block_date < DATE '2025-12-27'
                THEN SUM(t.amount_usd * p.fee_rate) / COUNT(DISTINCT t.block_date) * 1.0
                ELSE SUM(t.amount_usd * p.fee_rate) / COUNT(DISTINCT t.block_date) * 0.85
            END, 0
        ) AS redirected_to_protocol
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
ORDER BY 1
