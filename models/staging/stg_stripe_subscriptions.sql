select
    sub_id,
    lower(trim(customer_email)) as email,
    plan_name,
    cast(mrr_amount as decimal(10,2)) as mrr_amount,
    event_type,
    cast(event_timestamp as timestamp_ntz) as event_timestamp_utc
from {{ ref('raw_stripe_subscriptions') }}