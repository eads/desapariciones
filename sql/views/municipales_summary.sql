create table views.municipales_summary AS

WITH
  counts AS (
    SELECT
      m.cve_geoid AS id,
      m.nom_mun,
      e.nom_ent,
      count(*) AS disappearance_count
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
  ),
  gender_fem_counts AS (
    SELECT
      c.cve_geoid AS id,
      count(*) AS gender_fem_ct
    FROM
      processed.cenapi c
    WHERE
      c.sexo = 'FEMENINO'
    GROUP BY
      c.cve_geoid
  ),
  gender_masc_counts AS (
    SELECT
      c.cve_geoid AS id,
      count(*) AS gender_masc_ct
    FROM
      processed.cenapi c
    WHERE
      c.sexo = 'MASCULINO'
    GROUP BY
      c.cve_geoid
  ),
  gender_null_counts AS (
    SELECT
      c.cve_geoid AS id,
      count(*) AS gender_null_ct
    FROM
      processed.cenapi c
    WHERE
      c.sexo IS NULL
    GROUP BY
      c.cve_geoid
  )

  SELECT
      c.*,
      f.gender_fem_ct,
      msc.gender_masc_ct,
      n.gender_null_ct,
      m.geom
  FROM
      counts c
  JOIN
      processed.areas_geoestadisticas_municipales m
        ON
            c.id = m.cve_geoid
  LEFT JOIN
      gender_fem_counts f
        ON
            c.id = f.id
  LEFT JOIN
      gender_masc_counts msc
        ON
            c.id = msc.id
  LEFT JOIN
      gender_null_counts n
        ON
            c.id = n.id
  ORDER BY
      c.disappearance_count DESC
;

