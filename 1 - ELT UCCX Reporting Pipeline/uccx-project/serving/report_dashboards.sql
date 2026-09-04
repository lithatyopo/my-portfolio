-- June Agent Leaderboard -- 
with agents as (select fa.agent_id, 
						dd.month_of_year,
						da.agent_id,
						da.agent_name,
						dd.month_name,
						fa.report_period,
						fa.calls_handled_agent,
						ntile(4) over (order by fa.calls_handled_agent desc) as categorized_agents
				from uccxmodels_marts.fact_agent_month as fa
				join uccxmodels_marts.dim_agents as da on fa.agent_id=da.agent_id
				join uccxmodels_marts.dim_dates as dd on fa.report_period=dd.month_name
				where report_period = 'June'
				order by 1,2
),

deduped as (select *,
					row_number() over (partition by agent_name, report_period) as row_num
			from agents

)

select agent_name as "Agent",
		report_period as "Month",
		calls_handled_agent as "Calls Handled", 
		case when categorized_agents = 1 then 'Top Performer'
			 when categorized_agents = 4 then 'Needs Support'
			 else 'On Track' end as "Performance Tier"
from deduped
where row_num = 1
order by categorized_agents asc, calls_handled_agent desc;


-- Monthly Agent Productivity Score Card -- 
with productivity_score as (select dd.month_name,
		dd.month_of_year,
		da.agent_name,
		da.agent_extension,
		fa.calls_handled_agent,
		fa.outbound_calls,
		fa.calls_presented_agent,
		fa.logged_in_time_hours,
		fa.not_ready_percent::numeric as "Not Ready (%)",
		fa.not_ready_time_hours as "Hours Not Ready",
		(round(fa."calls_handled_agent" *1.0 / COALESCE(fa."logged_in_time_hours",0),2)) *8 as productivity,
		ROUND(AVG(fa."ready_percent")::numeric *1.0, 2) AS "Ready (%)",
		fa.calls_presented_agent - fa.calls_handled_agent as "Calls Abandoned"
from uccxmodels_marts.fact_agent_month as fa 
join uccxmodels_marts.dim_dates as dd on fa.report_period=dd.month_name
join uccxmodels_marts.dim_agents as da on fa.agent_id=da.agent_id [[where {{agent}}]]
group by 1,2,3,4,5,6,7,8,9,10
order by da.agent_name, dd.month_of_year asc
),

productivity_comparison as (select month_name as "Month",
									agent_name as "Agent",
									productivity as "Productivity (Calls per Day)",
									productivity - lag(productivity, 1) over (partition by agent_name order by month_of_year) as "Productivity MoM Difference",
									case when productivity - lag(productivity, 1) over (partition by agent_name order by month_of_year) > 0 then 'Increase'
										 when productivity - lag(productivity, 1) over (partition by agent_name order by month_of_year) < 0 then 'Decrease' 
										 end as "Productivity Trend",
									calls_handled_agent as "Calls Handled",
									logged_in_time_hours as "Logged In Hours",
									"Ready (%)"
							from productivity_score
							order by agent_name, month_of_year

)

select * from productivity_comparison;



-- Monthly All Agents Average Productivity --
with productivity as (select fa.report_period as Month,
							 dd.month_name as MonthName,
							 dd.month_of_year as MonthNumber,
							 avg(fa.calls_handled_agent) as AvgCallsHandled,
							 (round(avg(fa."calls_handled_agent"::numeric / coalesce(fa."logged_in_time_hours",0)),2)) *8  as AverageProductivity
					  from uccxmodels_marts.fact_agent_month as fa
					  join uccxmodels_marts.dim_dates as dd on fa.report_period=dd.month_name
					  group by 1,2,3
					  order by 3					 
),

comparison as (select Month as "Month", 
					  AverageProductivity as "Average Productivity (Calls per Day)",
					  AvgCallsHandled as "Average Calls Handled Per Agent",
					  AverageProductivity - lag(AverageProductivity, 1) over (order by MonthNumber) as "MoM Difference",
					  case when AverageProductivity - lag(AverageProductivity, 1) over (order by MonthNumber) > 0 then 'Increase'
						   when AverageProductivity - lag(AverageProductivity, 1) over (order by MonthNumber) < 0 then 'Decrease' 
						   end as "Productivity Trend"
				from productivity
				order by MonthNumber

)

select "Month", "Average Productivity (Calls per Day)", "MoM Difference", "Productivity Trend", "Average Calls Handled Per Agent"
from comparison;


-- Monthly Agent Activity --
with productivity_score as (select dd.month_name as "Month",
		dd.month_of_year as "Month Number",
		da.agent_name as "Agent",
		fa.calls_handled_agent as "Calls Handled",
		fa.outbound_calls as "Private Outbound Calls",
		fa.calls_presented_agent as "Calls Presented",
		fa.logged_in_time_hours as "Hours Logged In",
		fa.ready_percent as "Ready (%)",
		fa.not_ready_percent as "Not Ready (%)",
		fa.not_ready_time_hours as "Hours Not Ready",
		fa.transfer_to_agent as "Calls Transferred to Agent",
		round("calls_handled_agent"::numeric / ("calls_handled_agent" + "outbound_calls")::numeric , 2) *100.0 as "Activity Ratio"
from uccxmodels_marts.fact_agent_month as fa 
join uccxmodels_marts.dim_agents as da on fa.agent_id=da.agent_id
join uccxmodels_marts.dim_dates as dd on fa.report_period=dd.month_name where {{selectagent}}
group by 1,2,3,4,5,6,7,8,9,10,11 
order by da.agent_name, dd.month_of_year asc)

select "Month", "Agent", "Hours Not Ready", "Private Outbound Calls", "Calls Presented", "Calls Handled", "Activity Ratio"
from productivity_score;


-- Monthly Queue Performance --
-- Busiest Month: Are we adequetly staffed during busy months?
with staffing_view as (select dc.csq_name as "Queue",
						 dd.month_of_year,
						 dd.month_name,
						 fc.csq_id,
						 fc.report_period as "Month",
						 fc.avg_speed_of_answer::int as "Average Speed of Answer (seconds)",
						 fc.calls_abandoned_csq as "Calls Abandoned",
						 fc.calls_presented_csq as "Calls Presented",
						 fc.calls_handled_csq as "Calls Handled",
						 fc.avg_queue_time::int as "Average Time In Queue (seconds)",
						 round(fc.calls_abandoned_csq *100.0 / calls_presented_csq,2) as "Abandon (%)",
						 round(fc.calls_handled_csq *100.0 / calls_presented_csq,2) as "Handle (%)"
				  from uccxmodels_marts.fact_csq_month as fc 
				  join uccxmodels_marts.dim_dates as dd on fc.report_period=dd.month_name
				  join uccxmodels_marts.dim_csq as dc on fc.csq_id=dc.csq_id
				  group by 1,2,3,4,5,6,7,8,9,10
				  order by 1,2

)

select "Month", "Queue", "Abandon (%)", "Handle (%)", "Average Speed of Answer (seconds)", "Average Time In Queue (seconds)", "Calls Handled"
from staffing_view;
-- Abandon Rate = Calls Abandoned * 100.0 / Calls Presented
-- Handled Rate = Calls Handled * 100.0 / Calls Presented
 