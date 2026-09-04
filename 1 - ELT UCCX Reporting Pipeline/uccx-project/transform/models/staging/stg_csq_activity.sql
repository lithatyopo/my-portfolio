with source as (

    select * from {{ source('raw', 'csq_activity') }}

),
renamed as (

    select
        source."Report_Period"::text                           as report_period,
        source."CSQ_ID" ::int                                      as csq_id,
        source."CSQ_Name"::text                                    as csq_name,
        source."Calls_Presented"::int                              as calls_presented_csq,
        source."Calls_Handled"::int                                as calls_handled_csq,
        source."Calls_Abandoned"::int                              as calls_abandoned_csq,
        extract (epoch FROM source."Avg_Queue_Time"::time)         as avg_queue_time,
        extract (epoch FROM source."Max_Queue_Time"::time)         as max_queue_time,
        extract (epoch FROM source."Avg_Speed_of_Answer"::time)    as avg_speed_of_answer
    from source
)

select * from renamed