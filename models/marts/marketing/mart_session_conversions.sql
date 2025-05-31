WITH sessions AS (
    SELECT
        session_date,
        session_source,
        landing_page_path,
        device_category,
        cv_page_path,
        CASE WHEN is_cv THEN 1 ELSE 0 END AS cv_flag
    FROM
        {{ ref('int_sessions_aggregated_from_events') }}
)

SELECT
    session_date,
    session_source,
    landing_page_path,
    cv_page_path,
    device_category,
    COUNT(*) AS session_count,
    SUM(cv_flag) AS cv_count
FROM
    sessions
GROUP BY
    session_date,
    session_source,
    landing_page_path,
    cv_page_path,
    device_category
