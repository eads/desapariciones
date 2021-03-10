create table views.cenapi_distributed as

WITH counts AS (
  SELECT
    cve_geoid,
    COUNT(seq_id) AS count
  FROM
    processed.cenapi
  GROUP BY
    cve_geoid
),
points AS (
  SELECT
    row_number() over (partition by m.cve_ent, m.cve_mun) as cve_geoid_seq_id,
    m.cve_geoid,
    m.nom_mun,
    randompoint as geom
  FROM
    processed.areas_geoestadisticas_municipales m
  join
    counts c
        on
            c.cve_geoid = m.cve_geoid
  ,
  LATERAL
    random_points_in_polygon(m.geom, c.count::int) AS randompoint
)
SELECT
  p.cve_geoid_seq_id,
  p.cve_geoid,
  p.nom_mun,
  p.geom
FROM
  points p
;