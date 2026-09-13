{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['invoice_id','contract_id']) }} AS hk_invoice_contract,
        hk_invoice, hk_contract, load_datetime, record_source
    FROM {{ ref('stg_invoices') }}
    WHERE invoice_id IS NOT NULL AND contract_id IS NOT NULL
)
SELECT i.* FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (SELECT 1 FROM {{ this }} t WHERE t.hk_invoice_contract = i.hk_invoice_contract)
{% endif %}
