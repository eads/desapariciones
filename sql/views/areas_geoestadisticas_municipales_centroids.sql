create table views.areas_geoestadisticas_municipales_centroids as

select
  ST_X(m.centroid_geom) as lng,
  ST_Y(m.centroid_geom) as lat,
  m.cve_geoid,
  m.cve_ent,
  m.cve_mun,
  m.nom_mun,
  e.nom_ent
from
  processed.areas_geoestadisticas_municipales m
join
  processed.areas_geoestadisticas_estatales e
    on
      m.cve_ent = e.cve_ent
;
