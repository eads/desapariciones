create table views.cenapi_by_year as

SELECT
  c.cve_geoid,
  extract(year from c.fecha_reporte) as year,
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
  processed.areas_geoestadisticas_municipales m
ON
  c.cve_ent = m.cve_ent AND c.cve_mun = m.cve_mun
GROUP BY
  c.cve_geoid,
  year
ORDER BY
  c.cve_geoid,
  year
;

alter table views.cenapi_by_year add column seq_id serial primary key;
create index idx_cenapi_by_year_cve_geoid_year on views.cenapi_by_year(cve_geoid, year);