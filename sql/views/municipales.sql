create table views.municipales as

select
  m.cve_geoid,
  m.cve_ent,
  m.cve_mun,
  m.nom_mun,
  e.nom_ent,
  m.geom as geom
from
  processed.areas_geoestadisticas_municipales m
join
  processed.areas_geoestadisticas_estatales e
    on
      m.cve_ent = e.cve_ent
;

