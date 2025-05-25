{% set start_date = var('start_date') %}
{% set end_date   = var('end_date') %}

WITH base AS (
    SELECT
        events.event_date,
        events.event_name,
        events.event_bundle_sequence_id,

        events.traffic_source.source AS first_touch_source,
        events.traffic_source.medium AS first_touch_medium,
        events.traffic_source.name AS first_touch_campaign,

        events.device.category AS device_category,
        events.device.operating_system AS device_os,

        event_params.key,
        event_params.value.string_value,
        event_params.value.int_value,

        TIMESTAMP_MICROS(events.event_timestamp) AS event_at,
        TIMESTAMP_MICROS(events.user_first_touch_timestamp) AS first_touch_at
    FROM
        {{ source('ga4', 'events') }} AS events,
        UNNEST(event_params) AS event_params

    WHERE
        events.event_date BETWEEN '{{ start_date }}' AND '{{ end_date }}'
        AND event_params.key IN (
            'page_location',
            'page_title',
            'session_engaged',
            'engagement_time_msec',
            'source',
            'medium',
            'campaign',
            'ga_session_id'
        )
)

SELECT
    event_date,
    event_name,
    event_at,
    first_touch_at,
    event_bundle_sequence_id,

    first_touch_source,
    first_touch_medium,
    first_touch_campaign,

    device_category,
    device_os,

    MAX(IF(key = 'page_location', string_value, NULL)) AS page_location,
    MAX(IF(key = 'page_title', string_value, NULL)) AS page_title,
    MAX(IF(key = 'session_engaged', string_value, NULL)) AS session_engaged,
    MAX(IF(key = 'source', string_value, NULL)) AS event_param_source,
    MAX(IF(key = 'medium', string_value, NULL)) AS event_param_medium,
    MAX(IF(key = 'campaign', string_value, NULL)) AS campaign,
    MAX(IF(key = 'ga_session_id', int_value, NULL)) AS ga_session_id,
    MAX(
        IF(
            key = 'engagement_time_msec', int_value, NULL
        )
    ) AS engagement_time_msec
FROM
    base
GROUP BY
    event_date,
    event_name,
    event_at,
    first_touch_at,
    event_bundle_sequence_id,
    first_touch_source,
    first_touch_medium,
    first_touch_campaign,
    device_category,
    device_os
