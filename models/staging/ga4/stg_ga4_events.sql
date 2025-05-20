{% set start_date = var('start_date', (modules.datetime.date.today() - modules.datetime.timedelta(days=30)).isoformat()) %}
{% set end_date = var('end_date', modules.datetime.date.today().isoformat()) %}

WITH base AS (
  SELECT
    event_date,
    event_name,
    TIMESTAMP_MICROS(event_timestamp) AS event_at,
    TIMESTAMP_MICROS(user_first_touch_timestamp) AS first_touch_at,
    event_bundle_sequence_id,

    traffic_source.source AS first_touch_source,
    traffic_source.medium AS first_touch_medium,
    traffic_source.name AS first_touch_campaign,

    device.category AS device_category,
    device.operating_system AS device_os,

    ep.key,
    ep.value.string_value,
    ep.value.int_value
  FROM 
    {{ source('ga4', 'events') }},
    UNNEST(event_params) AS ep

  WHERE 
    event_date BETWEEN '{{ start_date }}' AND '{{ end_date }}'
    AND ep.key IN (
      'page_location',
      'page_title',
      'session_engaged',
      'engagement_time_msec',
      'source',
      'medium',
      'campaign'
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
  MAX(IF(key = 'engagement_time_msec', int_value, NULL)) AS engagement_time_msec
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
