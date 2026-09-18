select *
from {{ ref('fact_invoice_line') }}
where line_amount < 0
   or unit_price < 0
   or quantity < 0
