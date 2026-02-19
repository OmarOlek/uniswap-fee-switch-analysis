WITH pre_burns AS (
    SELECT DISTINCT evt_tx_from AS wallet
    FROM uniswap_v3_ethereum.Pair_evt_Burn
    WHERE evt_block_time >= TIMESTAMP '2025-11-03'
      AND evt_block_time < TIMESTAMP '2025-12-27'
),
pre_mints AS (
    SELECT DISTINCT evt_tx_from AS wallet
    FROM uniswap_v3_ethereum.Pair_evt_Mint
    WHERE evt_block_time >= TIMESTAMP '2025-11-03'
      AND evt_block_time < TIMESTAMP '2025-12-27'
),
post_burns AS (
    SELECT DISTINCT evt_tx_from AS wallet
    FROM uniswap_v3_ethereum.Pair_evt_Burn
    WHERE evt_block_time >= TIMESTAMP '2025-12-27'
),
post_mints AS (
    SELECT DISTINCT evt_tx_from AS wallet
    FROM uniswap_v3_ethereum.Pair_evt_Mint
    WHERE evt_block_time >= TIMESTAMP '2025-12-27'
),
pre_exits AS (
    SELECT COUNT(*) / 54.0 AS rate
    FROM pre_burns b LEFT JOIN pre_mints m ON b.wallet = m.wallet
    WHERE m.wallet IS NULL
),
post_exits AS (
    SELECT COUNT(*) / 53.0 AS rate
    FROM post_burns b LEFT JOIN post_mints m ON b.wallet = m.wallet
    WHERE m.wallet IS NULL
)
SELECT ROUND(((post.rate - pre.rate) / pre.rate) * 100, 1) AS pct_change
FROM pre_exits pre, post_exits post
