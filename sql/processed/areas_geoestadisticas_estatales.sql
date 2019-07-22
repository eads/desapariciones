create table processed.areas_geoestadisticas_estatales as

select
    gid,
    cve_ent,
    nom_ent,
    ST_MakeValid(ST_Transform(ST_SetSRID(geom, 6372), 4326)) as geom
from
    raw.areas_geoestadisticas_estatales;

alter table processed.areas_geoestadisticas_estatales add primary key(gid);

create unique index idx_areas_geoestadisticas_estatales_cve_ent
    on processed.areas_geoestadisticas_estatales(cve_ent);
