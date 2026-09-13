{{ config(materialized='incremental') }}
WITH incoming AS (
    SELECT DISTINCT
        {{ hash_key(['invoice_id','organisation_id']) }} AS hk_invoice_organisation,
        hk_invoice, hk_organisation, load_datetime, record_source
    FROM {{ ref('stg_invoices') }}
    WHERE invoice_id IS NOT NULL AND organisation_id IS NOT NULL
)
SELECT i.* FROM incoming i
{% if is_incremental() %}
WHERE NOT EXISTS (SELECT 1 FROM {{ this }} t WHERE t.hk_invoice_organisation = i.hk_invoice_organisation)
{% endif %}
