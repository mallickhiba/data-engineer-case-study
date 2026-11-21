{{ config(materialized='table') }}

with latest_subs as (
    select *
    from {{ ref('stg_stripe_subscriptions') }}
    qualify row_number() over (
        partition by sub_id order by event_timestamp_utc desc) = 1
),

active as (
    select * from latest_subs
    where lower(event_type) not in ('cancel', 'cancelled', 'churn')
),

mrr as (
    select sum(mrr_amount) as active_mrr from active
),

orders as (
    select * from {{ ref('stg_vendor_orders') }}
)

select 'active_mrr' as metric,
       cast(null as varchar) as vendor_name,
       cast(active_mrr as decimal(12,2)) as value,
       'USD' as unit
from mrr

union all
select 'arr', null, cast(active_mrr * 12 as decimal(12,2)), 'USD'
from mrr

union all
select 'avg_response_time_hours', null,
       cast(avg(datediff('minute', created_at_utc, completed_at_utc)) / 60.0 as decimal(12,2)),
       'hours'
from orders
where status = 'Completed' and completed_at_utc is not null

union all
select 'vendor_utilization', vendor_name,
       cast(sum(case when status = 'Completed' then hours_spent else 0 end)
            / count(*) as decimal(12,2)),
       'billable hours per logged job'
from orders
group by vendor_name