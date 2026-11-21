select
    booking_id,
    lower(trim(customer_full_name)) as customer_name_clean,
    case when raw_contact like '%@%'
         then lower(trim(raw_contact)) end as email,
    case when raw_contact not like '%@%'
         then regexp_replace(raw_contact, '[^0-9]', '') end as phone,
    trim(boat_name) as boat_name,
    upper(regexp_replace(hull_id, '[^A-Za-z0-9]', '')) as hull_id,
    try_to_decimal(
        replace(replace(cast(slip_fee as varchar), '$', ''), ',', ''),
        10, 2) as slip_fee,
    marina_code
from {{ ref('raw_marina_pms') }}