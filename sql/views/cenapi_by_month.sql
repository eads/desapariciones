create table views.cenapi_by_month as

SELECT
  m.cve_geoid,
  m.cve_ent,
  m.cve_mun,
  m.nom_mun,
  m.nom_ent,
  extract(year from c.fecha_reporte) as year,
  extract(month from c.fecha_reporte) as month,
  extract(epoch 
    from make_date(extract(year from c.fecha_reporte)::int, extract(month from c.fecha_reporte)::int, 1)
  ) as date,
  count(*) AS disappearance_ct,
  count(*) filter (where c.sexo = 'FEMENINO') AS gender_fem_ct,
  count(*) filter (where c.sexo = 'MASCULINO') AS gender_masc_ct,
  count(*) filter (where c.vivo_o_muerto = 'VIVO') as status_alive_ct,
  count(*) filter (where c.vivo_o_muerto = 'AUN SIN LOCALIZAR') as status_not_found_ct,
  count(*) filter (where c.vivo_o_muerto = 'MUERTO') as status_dead_ct
FROM
  processed.cenapi c
JOIN
  views.municipales m
ON
  c.cve_ent = m.cve_ent AND c.cve_mun = m.cve_mun
GROUP BY
  m.cve_geoid,
  m.cve_ent,
  m.cve_mun,
  m.nom_mun,
  m.nom_ent,
  year,
  month
ORDER BY
  m.cve_geoid,
  m.cve_ent,
  m.cve_mun,
  m.nom_mun,
  m.nom_ent,
  year,
  month
;
