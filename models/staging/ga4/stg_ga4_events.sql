{% set start_date = var('start_date') %}
{% set end_date   = var('end_date') %}

WITH base AS (
    SELECT
        events.event_date,
        events.event_name,
        events.event_bundle_sequence_id,
        events.user_pseudo_id,

        events.traffic_source.source AS first_touch_source,
        events.traffic_source.medium AS first_touch_medium,
        events.traffic_source.name AS first_touch_campaign,

        events.device.category AS device_category,
        events.device.operating_system AS device_os,

        events.session_traffic_source_last_click AS last_click,

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
            'ga_session_id'
        )
)

SELECT
    event_date,
    event_name,
    event_at,
    first_touch_at,
    event_bundle_sequence_id,
    user_pseudo_id,

    first_touch_source,
    first_touch_medium,
    first_touch_campaign,

    device_category,
    device_os,

    COALESCE(
        last_click.manual_campaign.source,
        last_click.cross_channel_campaign.source
    ) AS session_source,
    COALESCE(
        last_click.manual_campaign.medium,
        last_click.cross_channel_campaign.medium
    ) AS session_medium,
    COALESCE(
        last_click.manual_campaign.campaign_name,
        last_click.cross_channel_campaign.campaign_name
    ) AS session_campaign,

    MAX(IF(key = 'page_location', string_value, NULL)) AS page_location,
    MAX(IF(key = 'page_title', string_value, NULL)) AS page_title,
    MAX(IF(key = 'session_engaged', string_value, NULL)) AS session_engaged,
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
    user_pseudo_id,
    first_touch_source,
    first_touch_medium,
    first_touch_campaign,
    session_source,
    session_medium,
    session_campaign,
    device_category,
    device_os
