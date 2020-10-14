create table views.municipales as

select
  m.cve_geoid,
  m.cve_ent,
  m.cve_mun,
  m.nom_mun,
  e.nom_ent,
  ST_SimplifyPreserveTopology(m.geom, 0.005) as geom,
  m.centroid_geom as centroid_geom
from
  processed.areas_geoestadisticas_municipales m
join
  processed.areas_geoestadisticas_estatales e
    on
      m.cve_ent = e.cve_ent
;

