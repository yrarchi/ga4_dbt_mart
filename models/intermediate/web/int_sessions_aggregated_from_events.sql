WITH events AS (
    SELECT
        user_pseudo_id,
        ga_session_id,
        event_date,
        event_at,
        event_name,
        page_location,
        {{ extract_url_path('page_location') }} AS page_path,
        device_category,
        session_campaign
    FROM
        {{ ref('stg_ga4_events') }}
    WHERE
        ga_session_id IS NOT NULL
),

landing_info AS (
    SELECT
        user_pseudo_id,
        ga_session_id,
        MIN_BY(device_category, event_at) AS device_category,
        MIN_BY(session_campaign, event_at) AS session_source,
        ANY_VALUE(event_date) AS session_date,
        COALESCE(
            MIN(IF(event_name = 'session_start', page_location, NULL)),
            MIN(IF(event_name = 'page_view', page_location, NULL))
        ) AS landing_page_location,
        COALESCE(
            MIN(IF(event_name = 'session_start', page_path, NULL)),
            MIN(IF(event_name = 'page_view', page_path, NULL))
        ) AS landing_page_path
    FROM
        events
    WHERE
        event_name IN ('page_view', 'session_start')
    GROUP BY
        user_pseudo_id,
        ga_session_id
),

cv_sessions AS (
    SELECT
        events.user_pseudo_id,
        events.ga_session_id,
        events.page_location AS cv_page_location,
        events.page_path AS cv_page_path
    FROM
        events
    INNER JOIN
        landing_info
        ON
            events.user_pseudo_id = landing_info.user_pseudo_id
            AND
            events.ga_session_id = landing_info.ga_session_id
    WHERE
        events.page_path != landing_info.landing_page_path
    QUALIFY
        ROW_NUMBER() OVER (
            PARTITION BY events.user_pseudo_id, events.ga_session_id
            ORDER BY events.event_at
        ) = 1
)

SELECT
    landing_info.user_pseudo_id,
    landing_info.ga_session_id,
    landing_info.session_date,
    landing_info.session_source,
    landing_info.device_category,
    landing_info.landing_page_location,
    landing_info.landing_page_path,
    cv_sessions.cv_page_location,
    cv_sessions.cv_page_path,
    IF(cv_sessions.user_pseudo_id IS NOT NULL, TRUE, FALSE) AS is_cv
FROM
    landing_info
LEFT JOIN
    cv_sessions
    ON
        landing_info.user_pseudo_id = cv_sessions.user_pseudo_id
        AND
        landing_info.ga_session_id = cv_sessions.ga_session_id
