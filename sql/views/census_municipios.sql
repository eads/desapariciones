create table views.census_municipios as

select
    m.cve_geoid,
    m.cve_ent,
    m.cve_mun,
    m.nom_mun,
    m.nom_ent,
    ano,
    sum(pob)
from
    processed.base_municipios_datos d
join views.municipales m on
    LPAD(d.clave::varchar(5), 5, '0') = m.cve_geoid
group by
    m.cve_geoid,
    ano
;

alter table views.census_municipios add column seq_id serial primary key;
create index idx_census_municipios_cve_ent_cve_mun on views.census_municipios(cve_ent, cve_mun);
create index idx_census_municipios_ano_cve_ent_cve_mun on views.census_municipios(ano, cve_ent, cve_mun);
create index idx_census_municipios_ano_cve_geoid on views.census_municipios(ano, cve_geoid);