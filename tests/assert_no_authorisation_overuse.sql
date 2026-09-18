select *
from {{ ref('bv_authorisation_utilisation') }}
where remaining_sessions < 0
