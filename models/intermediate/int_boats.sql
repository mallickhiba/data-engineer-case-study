select
    md5(b.hull_id) as boat_id,
    b.hull_id,
    max_by(b.boat_name, length(b.boat_name)) as boat_name,
    o.owner_id,
    count(distinct b.booking_id) as booking_count
from {{ ref('stg_marina_pms') }} b
left join {{ ref('int_owners') }} o
    on b.hull_id = o.hull_id
group by b.hull_id, o.owner_id