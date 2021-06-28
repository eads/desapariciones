create table views.municipales as

select
  replace(m.cve_geoid, '-', '') as cve_geoid,
  m.cve_ent,
  m.cve_mun,
  m.nom_mun,
  e.nom_ent,
  ST_SimplifyPreserveTopology(m.geom, 0.0001) as geom,
  ST_SimplifyPreserveTopology(m.geom, 0.0005) as geom_simple,
  m.centroid_geom as centroid_geom
from
  processed.areas_geoestadisticas_municipales m
join
  processed.areas_geoestadisticas_estatales e
    on
      m.cve_ent = e.cve_ent
;

alter table views.municipales add primary key (cve_geoid);
create index idx_municipales_cve_ent_cve_mun on views.municipales(cve_ent, cve_mun);