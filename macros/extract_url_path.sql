{% macro extract_url_path(url) -%}
  -- URLのパス部分を抜き出し、パラメータを除去する
  REGEXP_EXTRACT(
    {{ url }},
    r'^https?://[^/]+(/[^?]*)'
  )
{%- endmacro %}
