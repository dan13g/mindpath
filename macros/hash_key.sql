{% macro hash_key(columns) -%}
    SHA2_BINARY(
      CONCAT_WS('||'
        {%- for column in columns %}
        , COALESCE(NULLIF(UPPER(TRIM(CAST({{ column }} AS VARCHAR))), ''), '^^')
        {%- endfor %}
      ), 256
    )
{%- endmacro %}

{% macro hashdiff(columns) -%}
    {{ hash_key(columns) }}
{%- endmacro %}
