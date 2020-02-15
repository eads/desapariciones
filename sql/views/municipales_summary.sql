create table views.municipales_summary AS

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
    CASE
      WHEN c.gender_masc_ct > 0 THEN
        c.gender_fem_ct::numeric / c.gender_masc_ct::numeric
      WHEN c.gender_masc_ct = 0 and c.gender_fem_ct > 0 THEN
        999
      ELSE
        0
    END as gender_f_to_m_ratio,
    CASE
      WHEN c.status_alive_ct > 0 THEN
        (c.status_dead_ct + c.status_not_found_ct)::numeric / c.status_alive_ct::numeric
      WHEN (c.status_dead_ct > 0 or c.status_not_found_ct > 0) and c.status_alive_ct = 0 THEN
        1
      ELSE
        0
    END as status_missingdead_to_alive_ratio,
    ST_SimplifyVW(m.geom, 0.001) as geom
  FROM
    counts c
  RIGHT JOIN
    processed.areas_geoestadisticas_municipales m
      ON
        c.id = m.cve_geoid
;

