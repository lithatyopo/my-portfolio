with csq as (
    select * from {{ ref('stg_csq_activity') }}
),

dim_csq as (
    select * from {{ ref('dim_csq') }}
),

dim_dates as (
    select * from {{ ref('dim_dates') }}
)
  
select
    {{ dbt_utils.generate_surrogate_key(['c.csq_id', 'c.report_period']) }} AS fact_csq_month_key,
    dc.dim_csq_key,
    dd.date_day AS dim_date_key,
    c.csq_id,
    c.report_period, 
    c.calls_presented_csq,
    c.calls_handled_csq,
    c.calls_abandoned_csq,
    c.avg_queue_time,
    c.max_queue_time,
    c.avg_speed_of_answer
from csq c
left join dim_csq dc
    on c.csq_id = dc.csq_id
left join dim_dates dd
    on c.report_period = dd.month_name
