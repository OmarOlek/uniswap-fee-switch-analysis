WITH daily_burns AS (
    SELECT
        evt_block_date AS day,
        evt_tx_from AS wallet
    FROM uniswap_v3_ethereum.Pair_evt_Burn
    WHERE evt_block_time >= TIMESTAMP '2025-11-01'
      AND evt_block_time <= TIMESTAMP '2026-02-17'
),

wallets_that_returned AS (
    SELECT DISTINCT evt_tx_from AS wallet
    FROM uniswap_v3_ethereum.Pair_evt_Mint
    WHERE evt_block_time >= TIMESTAMP '2025-11-01'
      AND evt_block_time <= TIMESTAMP '2026-02-17'
),

daily_exits AS (
    SELECT
        b.day,
        COUNT(DISTINCT b.wallet) AS wallets_burned
    FROM daily_burns b
    LEFT JOIN wallets_that_returned r
        ON b.wallet = r.wallet
    WHERE r.wallet IS NULL
    GROUP BY b.day
)

SELECT
    day,
    wallets_burned AS daily_exits,
    AVG(wallets_burned) OVER (
        ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS seven_day_avg
FROM daily_exits
ORDER BY day
