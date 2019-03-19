DROP MATERIALIZED VIEW IF EXISTS mv_linestrings;
CREATE MATERIALIZED VIEW mv_linestrings AS
SELECT
  name,
  name_hu,
  alternative_names,
  'way'::TEXT as osm_type,
  osm_id::VARCHAR AS osm_id,
  class,
  type,
  round(ST_X(ST_LineInterpolatePoint(ST_Transform(geometry, 4326), 0.5))::numeric, 7) AS lon,
  round(ST_Y(ST_LineInterpolatePoint(ST_Transform(geometry, 4326), 0.5))::numeric, 7) AS lat,
  place_rank,
  get_importance(place_rank, wikipedia, parentInfo.country_code) AS importance,
  CASE WHEN class = 'highway' THEN name ELSE NULL::TEXT END AS street,
  parentInfo.city AS city,
  parentInfo.county AS county,
  parentInfo.state AS state,
  get_country_name(parentInfo.country_code) AS country,
  parentInfo.country_code AS country_code,
  parentInfo.displayName AS display_name,
  round(ST_XMIN(ST_Transform(geometry, 4326))::numeric, 7) AS west,
  round(ST_YMIN(ST_Transform(geometry, 4326))::numeric, 7) AS south,
  round(ST_XMAX(ST_Transform(geometry, 4326))::numeric, 7) AS east,
  round(ST_YMAX(ST_Transform(geometry, 4326))::numeric, 7) AS north,
  NULLIF(wikidata, '') AS wikidata,
  NULLIF(wikipedia, '') AS wikipedia
FROM
  osm_linestring,
  determine_class(type) AS class,
  get_parent_info(parent_id, name) as parentInfo
WHERE merged_into IS NULL;
