create table views.estatales as

select
  e.cve_ent,
  e.nom_ent,
  e.geom as geom,
  ST_SimplifyPreserveTopology(e.geom, 0.0005) as geom_simple
from
  processed.areas_geoestadisticas_estatales e
;

create index idx_estatales_cve_ent on views.estatales(cve_ent);

