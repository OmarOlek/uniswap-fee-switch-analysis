WITH post_burns AS (
    SELECT DISTINCT evt_tx_from AS wallet
    FROM uniswap_v3_ethereum.Pair_evt_Burn
    WHERE evt_block_time >= TIMESTAMP '2025-12-27'
),
post_mints AS (
    SELECT DISTINCT evt_tx_from AS wallet
    FROM uniswap_v3_ethereum.Pair_evt_Mint
    WHERE evt_block_time >= TIMESTAMP '2025-12-27'
),
pre_burns AS (
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
)

SELECT 'Pre-Switch (Nov 3 – Dec 26)' AS period,
    54 AS days_in_period,
    (SELECT COUNT(*) FROM pre_burns b LEFT JOIN pre_mints m ON b.wallet = m.wallet WHERE m.wallet IS NULL) AS total_exits,
    ROUND((SELECT COUNT(*) FROM pre_burns b LEFT JOIN pre_mints m ON b.wallet = m.wallet WHERE m.wallet IS NULL) / 54.0, 1) AS exits_per_day

UNION ALL

SELECT 'Post-Switch (Dec 27 – Feb 17)' AS period,
    53 AS days_in_period,
    (SELECT COUNT(*) FROM post_burns b LEFT JOIN post_mints m ON b.wallet = m.wallet WHERE m.wallet IS NULL) AS total_exits,
    ROUND((SELECT COUNT(*) FROM post_burns b LEFT JOIN post_mints m ON b.wallet = m.wallet WHERE m.wallet IS NULL) / 53.0, 1) AS exits_per_day
