SELECT
    user_pseudo_id,
    ga_session_id,
    COUNT(*) AS row_count
FROM
    {{ ref('int_sessions_aggregated_from_events') }}
GROUP BY
    user_pseudo_id,
    ga_session_id
HAVING
    row_count > 1
