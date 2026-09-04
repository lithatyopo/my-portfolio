SELECT 
    {{dbt_utils.generate_surrogate_key(['agent_id'])}} as dim_agent_key, 
    agent_id,
    agent_name,
    agent_extension
FROM {{ ref("stg_agent_all_fields") }}