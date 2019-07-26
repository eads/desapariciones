create table views.municipales_summary_ctr AS

WITH
  counts AS (
    SELECT
      m.cve_geoid AS id,
      m.nom_mun,
      e.nom_ent,
      count(*) AS disappearance_ct,
      count(*) filter (where c.sexo = 'FEMENINO') AS gender_fem_ct,
      count(*) filter (where c.sexo = 'MASCULINO') AS gender_masc_ct,
      count(*) filter (where c.vivo_o_muerto = 'VIVO') as status_alive_ct,
      count(*) filter (where c.vivo_o_muerto = 'AUN SIN LOCALIZAR') as status_not_found_ct,
      count(*) filter (where c.vivo_o_muerto = 'MUERTO') as status_dead_ct
    FROM
      processed.cenapi c
    JOIN
      processed.areas_geoestadisticas_municipales m
    ON
      c.cve_ent = m.cve_ent AND c.cve_mun = m.cve_mun
    JOIN
      processed.areas_geoestadisticas_estatales e
    ON
      c.cve_ent = e.cve_ent
    GROUP BY
      m.cve_geoid, m.nom_mun, e.nom_ent
    ORDER BY
      m.cve_geoid
  )
  SELECT
    c.*,
    m.centroid_geom as geom
  FROM
    counts c
  JOIN
    processed.areas_geoestadisticas_municipales m
      ON
        c.id = m.cve_geoid
;


