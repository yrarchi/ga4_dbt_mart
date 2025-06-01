SELECT *
FROM
    {{ ref('int_sessions_aggregated_from_events') }}
WHERE
    cv_page_path = landing_page_path
    AND is_cv = TRUE
