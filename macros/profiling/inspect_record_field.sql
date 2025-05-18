{% macro inspect_record_fields(source_table, struct_column, fields, limit=3) %}
  {% set queries = [] %}

  {% for field in fields %}
    {% set field_query %}
      select
        '{{ field }}' as column_name,
        count(*) as total_count,
        countif({{ struct_column }}.{{ field }} is null) as null_count,
        count(distinct {{ struct_column }}.{{ field }}) as unique_count,
        array_agg(distinct cast({{ struct_column }}.{{ field }} as string) ignore nulls limit {{ limit }}) as sample_values
      from `{{ source_table }}`
    {% endset %}
    {% do queries.append(field_query) %}
  {% endfor %}

  {% set full_query %}
    {{ queries | join(" union all\n") }}
  {% endset %}

  {% set table = run_query(full_query) %}

  {% if execute %}
    {% for i in range(table.columns[table.column_names[0]] | length) %}
      {% set row = {} %}
      {% for col in table.column_names %}
        {% do row.update({ col: table.columns[col][i] }) %}
      {% endfor %}
      {{ log(row, info=True) }}
    {% endfor %}
  {% endif %}
{% endmacro %}
