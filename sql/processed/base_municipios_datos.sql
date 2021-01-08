create table processed.base_municipios_datos as 

select 
    renglon,
    clave::int,
    clave_ent::int,
    mun as nom_mun,
    nom_ent,
    sexo,
    ano::int,
    edad_quin,
    pob::int
from raw.base_municipios_datos;

alter table processed.base_municipios_datos add column seq_id serial primary key;