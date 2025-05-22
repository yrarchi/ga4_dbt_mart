{% macro inspect_scalar_columns(dataset, table) %}
    {% set relation = adapter.get_relation(
        database=target.database,
        schema=dataset,
        identifier=table
    ) %}

    {% set columns = adapter.get_columns_in_relation(relation) %}

    {% do log("=== Column Profile for " ~ relation ~ " ===", info=True) %}

    {% for col in columns %}
        {% if 'ARRAY' not in col.data_type and 'STRUCT' not in col.data_type %}
            {% set sql %}
                SELECT
                    COUNT(*) AS total_count,
                    COUNTIF({{ col.name }} IS NULL) AS null_count,
                    COUNT(DISTINCT {{ col.name }}) AS unique_count
                FROM {{ relation }}
            {% endset %}

            {% if execute %}
                {% set result = run_query(sql) %}
                {% set total = result.columns['total_count'][0] %}
                {% set nulls = result.columns['null_count'][0] %}
                {% set uniques = result.columns['unique_count'][0] %}
                {% do log(col.name ~ ": total=" ~ total ~ ", null=" ~ nulls ~ ", unique=" ~ uniques, info=True) %}
            {% endif %}
        {% endif %}
    {% endfor %}
{% endmacro %}
