create table views.municipales_summary_ctr as

WITH counts AS (
  SELECT
    row_number() OVER (PARTITION BY true) as id,
    c.cve_ent,
    c.cve_mun,
    m.nom_mun,
    e.nom_ent,
    count(*) AS disappearance_count
  FROM
      cenapi c
  JOIN
      areas_geoestadisticas_municipales m
  ON
      c.cve_ent = m.cve_ent AND c.cve_mun = m.cve_mun
  JOIN
      areas_geoestadisticas_estatales e
  ON
      c.cve_ent = e.cve_ent
  GROUP BY
      c.cve_ent, c.cve_mun, m.nom_mun, e.nom_ent
  )
SELECT
    c.*,
    m.centroid_geom as geom
FROM
    counts c
JOIN
    areas_geoestadisticas_municipales m
ON
    c.cve_ent = m.cve_ent AND c.cve_mun = m.cve_mun
ORDER BY
    c.disappearance_count DESC
;

