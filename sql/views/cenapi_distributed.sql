create table views.cenapi_distributed as

WITH counts AS (
  SELECT
    cve_geoid,
    COUNT(seq_id) AS COUNT
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
    e.nom_ent,
    randompoint as geom
  FROM
    processed.areas_geoestadisticas_municipales m
  JOIN
    processed.areas_geoestadisticas_estatales e
      ON
        m.cve_ent = e.cve_ent
  JOIN
    counts c
      ON
        c.cve_geoid = m.cve_geoid
  ,
  LATERAL
    RandomPointsInPolygon(m.geom, c.count::int) AS randompoint
)
SELECT
  p.cve_geoid_seq_id,
  p.nom_mun,
  p.nom_ent,
  cn.fecha_de_ingreso,
  cn.fecha_de_localizacion,
  cn.fecha_de_nacimiento,
  cn.fecha_de_ultimo_avistamiento,
  cn.fecha_evento,
  cn.fecha_probable_de_fallecimiento,
  cn.fecha_reporte,
  cn.sexo,
  cn.vivo_o_muerto,
  p.geom
FROM
  points p
JOIN
  cenapi cn
    ON
      cn.cve_geoid_seq_id = p.cve_geoid_seq_id
    AND
      cn.cve_geoid = p.cve_geoid
;
