{% macro inspect_array_field(source_table, column_name) %}
    {% set query %}
        with unnested as (
            select 
                param.key,
                param.value.string_value as string_value,
                param.value.int_value as int_value,
                param.value.float_value as float_value,
                param.value.double_value as double_value
            from `{{ source_table }}`,
            unnest({{ column_name }}) as param
        ),
        stats as (
            select
                key,
                'string_value' as value_type,
                count(*) as total_count,
                countif(string_value is null) as null_count,
                count(distinct string_value) as unique_count,
                array_agg(distinct string_value ignore nulls limit 3) as sample_values
            from unnested
            group by key

            union all

            select
                key,
                'int_value' as value_type,
                count(*) as total_count,
                countif(int_value is null) as null_count,
                count(distinct int_value) as unique_count,
                array_agg(distinct cast(int_value as string) ignore nulls limit 3) as sample_values
            from unnested
            group by key

            union all

            select
                key,
                'float_value' as value_type,
                count(*) as total_count,
                countif(float_value is null) as null_count,
                count(distinct float_value) as unique_count,
                array_agg(distinct cast(float_value as string) ignore nulls limit 3) as sample_values
            from unnested
            group by key

            union all

            select
                key,
                'double_value' as value_type,
                count(*) as total_count,
                countif(double_value is null) as null_count,
                count(distinct double_value) as unique_count,
                array_agg(distinct cast(double_value as string) ignore nulls limit 3) as sample_values
            from unnested
            group by key
        )
        select * from stats
    {% endset %}

    {% set table = run_query(query) %}

    {% if execute %}
        {% set rows = [] %}
        {% for i in range(table.columns[table.column_names[0]] | length) %}
            {% set row = {} %}
            {% for col in table.column_names %}
                {% do row.update({ col: table.columns[col][i] }) %}
            {% endfor %}
            {{ log(row, info=True) }}
        {% endfor %}
    {% endif %}
{% endmacro %}
