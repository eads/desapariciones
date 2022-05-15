create table processed.rnpndo as

with processed as (
    select
        anio::numeric as ano,
        parse_timestamp(fecha) as fecha,
        cod_inegi,
        edo_mun,
        id_mun,
        id_edo,
        hombres_mun::numeric as hombres_mun,
        mujeres_mun::numeric as mujeres_mun,
        indeterminado_mun::numeric as indeterminado_mun,
        reportes::numeric as reportes
    from raw.rnpndo
)
select 
    ano,
    fecha,
    extract(year from fecha) as fecha_ano,
    extract(month from fecha) as fecha_mes,
    extract(day from fecha) as fecha_dia,
    cod_inegi,
    edo_mun,
    id_mun,
    id_edo,
    hombres_mun,
    mujeres_mun,
    indeterminado_mun,
    reportes
from processed
;

alter table processed.rnpndo add column seq_id serial primary key;
create index idx_rnpndo_cod_inegi on processed.rnpndo(cod_inegi);