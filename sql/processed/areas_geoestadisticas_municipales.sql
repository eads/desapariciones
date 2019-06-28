create table processed.areas_geoestadisticas_municipales as

select
    gid,
    concat(cve_ent, '-', cve_mun) as cve_geoid,
    cve_ent,
    cve_mun,
    nom_mun,
    ST_Transform(ST_SetSRID(geom, 6372), 3857) as geom,
    case
      when (cve_ent = '06' and cve_mun = '009') then ST_SetSRID(ST_MakePoint(-103.803, 18.854), 3857)
      else st_centroid(ST_Transform(ST_SetSRID(geom, 6372), 3857))
    end as centroid_geom

from
    raw.areas_geoestadisticas_municipales;

alter table processed.areas_geoestadisticas_municipales add primary key(gid);

create unique index idx_areas_geoestadisticas_municipales_cve_geoid
    on processed.areas_geoestadisticas_municipales(cve_geoid);

create unique index idx_areas_geoestadisticas_municipales_cve_ent_cve_mun
    on processed.areas_geoestadisticas_municipales(cve_ent, cve_mun);