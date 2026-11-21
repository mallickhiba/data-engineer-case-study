select
    w.work_order_id,
    w.vendor_name,
    w.raw_service_type,
    coalesce(m.service_category, 'Unmapped') as service_category,
    w.hours_spent,
    w.status,
    cast(w.created_at as timestamp_ntz) as created_at_utc,
    cast(w.completed_at as timestamp_ntz) as completed_at_utc
from {{ ref('raw_vendor_work_orders') }} w
left join {{ ref('service_type_map') }} m
    on lower(trim(w.raw_service_type)) = lower(trim(m.raw_service_type))