WITH post_uni_exits AS (
    SELECT DISTINCT b.evt_tx_from AS wallet
    FROM uniswap_v3_ethereum.Pair_evt_Burn b
    LEFT JOIN uniswap_v3_ethereum.Pair_evt_Mint m
        ON b.evt_tx_from = m.evt_tx_from
        AND m.evt_block_time >= TIMESTAMP '2025-12-27'
    WHERE b.evt_block_time >= TIMESTAMP '2025-12-27'
      AND m.evt_tx_from IS NULL
),
pre_uni_exits AS (
    SELECT DISTINCT b.evt_tx_from AS wallet
    FROM uniswap_v3_ethereum.Pair_evt_Burn b
    LEFT JOIN uniswap_v3_ethereum.Pair_evt_Mint m
        ON b.evt_tx_from = m.evt_tx_from
        AND m.evt_block_time >= TIMESTAMP '2025-11-03'
        AND m.evt_block_time < TIMESTAMP '2025-12-27'
    WHERE b.evt_block_time >= TIMESTAMP '2025-11-03'
      AND b.evt_block_time < TIMESTAMP '2025-12-27'
      AND m.evt_tx_from IS NULL
),
bal_post AS (
    SELECT DISTINCT evt_tx_from AS wallet
    FROM balancer_v2_ethereum.Vault_evt_PoolBalanceChanged
    WHERE evt_block_time >= TIMESTAMP '2025-12-27'
),
bal_pre AS (
    SELECT DISTINCT evt_tx_from AS wallet
    FROM balancer_v2_ethereum.Vault_evt_PoolBalanceChanged
    WHERE evt_block_time >= TIMESTAMP '2025-11-03'
      AND evt_block_time < TIMESTAMP '2025-12-27'
)

SELECT
    'Pre-Switch' AS period,
    (SELECT COUNT(*) FROM pre_uni_exits) AS total_exits,
    (SELECT COUNT(*) FROM pre_uni_exits u INNER JOIN bal_pre b ON u.wallet = b.wallet) AS migrated_to_balancer,
    ROUND(100.0 * (SELECT COUNT(*) FROM pre_uni_exits u INNER JOIN bal_pre b ON u.wallet = b.wallet) / (SELECT COUNT(*) FROM pre_uni_exits), 2) AS migration_rate_pct

UNION ALL

SELECT
    'Post-Switch' AS period,
    (SELECT COUNT(*) FROM post_uni_exits) AS total_exits,
    (SELECT COUNT(*) FROM post_uni_exits u INNER JOIN bal_post b ON u.wallet = b.wallet) AS migrated_to_balancer,
    ROUND(100.0 * (SELECT COUNT(*) FROM post_uni_exits u INNER JOIN bal_post b ON u.wallet = b.wallet) / (SELECT COUNT(*) FROM post_uni_exits), 2) AS migration_rate_pct
