create table processed.areas_geoestadisticas_municipales as

select
    gid,
    cve_ent,
    cve_mun,
    nom_mun,
    ST_Transform(ST_SetSRID(geom, 6372), 3857) as geom
from
    raw.areas_geoestadisticas_municipales;

alter table processed.areas_geoestadisticas_municipales add primary key(gid);

create unique index idx_areas_geoestadisticas_municipales_cve_ent_cve_mun
    on processed.areas_geoestadisticas_municipales(cve_ent, cve_mun);
