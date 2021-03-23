create table views.cenapi_estado_evento_by_month as

SELECT
  c.cve_ent,
  e.nom_ent,
  extract(year from c.fecha_evento) as year,
  extract(month from c.fecha_evento) as month,
  extract(epoch 
    from make_date(extract(year from c.fecha_evento)::int, extract(month from c.fecha_evento)::int, 1)
  ) as date,
  count(*) AS disappearance_ct,
  count(*) filter (where c.sexo = 'FEMENINO') AS gender_fem_ct,
  count(*) filter (where c.sexo = 'MASCULINO') AS gender_masc_ct,
  count(*) filter (where c.vivo_o_muerto = 'VIVO') as status_alive_ct,
  count(*) filter (where c.vivo_o_muerto = 'AUN SIN LOCALIZAR') as status_not_found_ct,
  count(*) filter (where c.vivo_o_muerto = 'MUERTO') as status_dead_ct,
  count(*) filter (where c.sexo = 'FEMENINO' and c.vivo_o_muerto = 'AUN SIN LOCALIZAR') as femenino_aun_sin_localizar,
  count(*) filter (where c.sexo = 'FEMENINO' and c.vivo_o_muerto = 'VIVO') as femenino_vivo,
  count(*) filter (where c.sexo = 'FEMENINO' and c.vivo_o_muerto = 'MUERTO') as femenino_muerto,
  count(*) filter (where c.sexo = 'MASCULINO' and c.vivo_o_muerto = 'AUN SIN LOCALIZAR') as masculino_aun_sin_localizar,
  count(*) filter (where c.sexo = 'MASCULINO' and c.vivo_o_muerto = 'VIVO') as masculino_vivo,
  count(*) filter (where c.sexo = 'MASCULINO' and c.vivo_o_muerto = 'MUERTO') as masculino_muerto
  
FROM
  processed.cenapi c
JOIN
  views.estatales e
ON
  c.cve_ent = e.cve_ent
WHERE
  c.fecha_evento >= '2006-01-01' AND
  c.fecha_evento <= c.fecha_reporte
GROUP BY
  c.cve_ent,
  e.nom_ent,
  year,
  month
ORDER BY
  c.cve_ent,
  e.nom_ent,
  year,
  month
;