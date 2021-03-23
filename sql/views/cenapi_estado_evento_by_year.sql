create table views.cenapi_estado_evento_by_year as

SELECT
  c.cve_ent,
  e.nom_ent,
  extract(year from c.fecha_evento) as year,
  extract(epoch 
    from make_date(extract(year from c.fecha_evento)::int, 1, 1)
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
  processed.areas_geoestadisticas_estatales e
ON
  c.cve_ent = e.cve_ent
WHERE
  c.fecha_evento >= '2006-01-01' AND
  c.fecha_evento <= c.fecha_reporte
GROUP BY
  c.cve_ent,
  e.nom_ent,
  year
ORDER BY
  c.cve_ent,
  e.nom_ent,
  year
;

alter table views.cenapi_estado_evento_by_year add column seq_id serial primary key;
create index idx_cenapi_estado_evento_by_year_cve_ent_year on views.cenapi_estado_evento_by_year(cve_ent, year);