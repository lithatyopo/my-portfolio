with source as (

    select * from {{ source('raw', 'agent_state_detail') }}

),

renamed as (

    select
        source."Agent_ID"::text                                as agent_id,
        source."Agent_Name"::text                              as agent_name,
        source."Extension"::text                               as agent_extension,
        source."Agent_State"::text                             as agent_state,
        source."Reason"::text                                  as state_reason,
        source."State_Transition_Time"::timestamp              as state_transition_time,
        extract (epoch from source."Duration"::time)           as state_duration
    from source
)

select * from renamed