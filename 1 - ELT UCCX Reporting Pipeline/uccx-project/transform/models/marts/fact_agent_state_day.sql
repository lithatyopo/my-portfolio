with agent_state as (
    select * from {{ ref('stg_agent_state_detail') }}
),

dim_agents as (
    select * from {{ ref('dim_agents') }}
),
  
dim_dates as (
    select * from {{ ref('dim_dates') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['ast.agent_id', 'ast.state_transition_time']) }} AS fact_agent_state_key,
    da.dim_agent_key,
    dd.date_day AS dim_date_key,
    ast.agent_id, 
    ast.state_transition_time,
    ast.agent_state,
    ast.state_duration,
    ast.state_reason
from agent_state ast
left join dim_agents da
    on ast.agent_id = da.agent_id
left join dim_dates dd
    on cast(ast.state_transition_time as date) = dd.date_day
