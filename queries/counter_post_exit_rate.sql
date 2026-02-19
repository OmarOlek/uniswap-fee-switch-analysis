WITH burns AS (
    SELECT DISTINCT evt_tx_from AS wallet
    FROM uniswap_v3_ethereum.Pair_evt_Burn
    WHERE evt_block_time >= TIMESTAMP '2025-12-27'
),
mints AS (
    SELECT DISTINCT evt_tx_from AS wallet
    FROM uniswap_v3_ethereum.Pair_evt_Mint
    WHERE evt_block_time >= TIMESTAMP '2025-12-27'
)
SELECT ROUND(COUNT(*) / 53.0, 1) AS exits_per_day
FROM burns b
LEFT JOIN mints m ON b.wallet = m.wallet
WHERE m.wallet IS NULL
