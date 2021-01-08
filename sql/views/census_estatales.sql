create table views.census_estatales as

select
    e.cve_ent,
    e.nom_ent,
    ano,
    sum(pob)
from
    processed.base_municipios_datos d
join views.estatales e on
    d.nom_ent = e.nom_ent
group by
    e.cve_ent,
    e.nom_ent,
    ano
;

alter table views.census_estatales add column seq_id serial primary key;
create index idx_census_estatales_ano_cve_ent on views.census_estatales(ano, cve_ent);