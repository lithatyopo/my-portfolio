SELECT
    {{dbt_utils.generate_surrogate_key(['csq_id'])}} AS dim_csq_key,
    csq_id,
    csq_name
FROM {{ ref("stg_csq_activity") }}