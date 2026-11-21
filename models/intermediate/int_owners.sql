with bookings as (
    select
        booking_id, hull_id, email, phone, customer_name_clean,
        split_part(replace(customer_name_clean, '.', ''), ' ', -1) as last_name,
        left(replace(customer_name_clean, '.', ''), 1) as first_initial
    from {{ ref('stg_marina_pms') }}
),

keyed as (
    select *,
        md5(concat_ws('|', hull_id, last_name, first_initial)) as owner_id
    from bookings
)

select
    owner_id,
    max_by(customer_name_clean, length(customer_name_clean)) as owner_name,
    max(email) as email,
    max(phone) as phone,
    hull_id,
    count(distinct booking_id) as booking_count
from keyed
group by owner_id, hull_id