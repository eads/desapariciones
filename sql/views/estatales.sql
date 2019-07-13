create table views.estatales as

select
  e.cve_ent,
  e.nom_ent,
  e.geom as geom
from
  processed.areas_geoestadisticas_estatales e
;


