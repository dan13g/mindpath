select *
from {{ ref('fact_invoice_line') }}
where abs(line_amount - (quantity * unit_price)) > 0.01
