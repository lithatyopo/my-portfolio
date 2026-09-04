with source as (

    select * from {{ source('raw', 'agent_all_fields') }}

),

renamed as (

    select
        source."Report_Period"::text                           as report_period,
        source."Agent_ID"::text                                as agent_id,
        source."Agent_Name"::text                              as agent_name,
        source."Agent_Extension"::text                         as agent_extension,
        source."Calls_Presented"::int                          as calls_presented_agent,
        source."Calls_Handled"::int                            as calls_handled_agent,
        source."Calls_Abandoned"::int                          as calls_abandoned_agent,
        source."Handle_Ratio"::float                           as handle_ratio_agent,
        extract (epoch from source."Work_Time"::time)          as work_time,
        extract (epoch from source."Avg_Handle_Time"::time)    as avg_handle_time,
        extract (epoch from source."Avg_Talk_Time"::time)      as avg_talk_time,
        split_part(source."Total_Logged_In_Time", ':', 1)::int as logged_in_time_hours,
        split_part(source."Not_Ready_Time", ':', 1)::int        as not_ready_time_hours,   
        split_part(source."Talk_Time", ':', 1)::int             as talk_time_hours,
        source."Outbound_On_IPCC-Total"::int                       as outbound_calls,
        source."ACD-Transfer_In"::int                          as transfer_to_agent, 
        source."ACD-Conference"::int                           as conference,
        source."Ready_Time_(%)"::float                          as ready_percent,
        source."Not_Ready_Time_(%)"::float                             as not_ready_percent
    from source

)

select * from renamed
