with agents as (
    select * from {{ ref('stg_agent_all_fields') }}
),
  
dim_agents as (
    select * from {{ ref('dim_agents') }}
),

dim_dates as (
    select * from {{ ref('dim_dates') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['a.agent_id', 'a.report_period']) }} AS fact_agent_month_key,
    da.dim_agent_key,
    dd.date_day AS dim_date_key,
    a.agent_id,
    a.report_period, 
    a.calls_presented_agent,
    a.calls_handled_agent, 
    a.handle_ratio_agent,
    a.avg_handle_time,
    a.avg_talk_time,
    a.work_time,
    a.not_ready_time_hours,
    a.ready_percent,
    a.not_ready_percent,
    a.logged_in_time_hours,
    a.talk_time_hours,
    a.outbound_calls,
    a.transfer_to_agent,
    a.conference
from agents a
left join dim_agents da
    on a.agent_id = da.agent_id
left join dim_dates dd
    on a.report_period = dd.month_name
