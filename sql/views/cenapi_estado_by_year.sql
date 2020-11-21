create table public.cenapi_estado_by_year as

SELECT
  c.cve_ent,
  e.nom_ent,
  extract(year from c.fecha_reporte) as year,
  extract(epoch 
    from make_date(extract(year from c.fecha_reporte)::int, 1, 1)
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
  processed.areas_geoestadisticas_estatales e
ON
  c.cve_ent = e.cve_ent
GROUP BY
  c.cve_ent,
  e.nom_ent,
  year
ORDER BY
  c.cve_ent,
  e.nom_ent,
  year
;
