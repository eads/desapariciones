
create table processed.municipal_delitos as 

select 
    LPAD(clave_ent, 2, '0') as cve_ent,
    RIGHT(cve_municipio, 3) as cve_mun,
    concat(LPAD(clave_ent, 2, '0'), RIGHT(cve_municipio, 3)) as cve_geoid,
    entidad,
    municipio,
    ano::int,
    bien_juridico_afectado,
    tipo_de_delito,
    subtipo_de_delito,
    modalidad,
    unnest(array[1,2,3,4,5,6,7,8,9,10,11,12]) AS month,
    unnest(array[enero, febrero, marzo, abril, mayo, junio, julio, agosto, septiembre, octubre, noviembre, diciembre]::int[]) AS ct
from raw.municipal_delitos;

-- with processed as (
--     select 
--         LPAD(clave_ent, 2, '0') as cve_ent,
--         RIGHT(cve_municipio, 3) as cve_mun,
--         ano::int,
--         bien_juridico_afectado,
--         tipo_de_delito,
--         subtipo_de_delito,
--         modalidad,
--         enero::int,
--         febrero::int,
--         marzo::int,
--         abril::int,
--         mayo::int,
--         junio::int,
--         julio::int,
--         agosto::int,
--         septiembre::int,
--         octubre::int,
--         noviembre::int,
--         diciembre::int
--     from raw.municipal_delitos
-- )

-- select
--     p.cve_ent,
--     p.cve_mun,
--     concat(p.cve_ent, p.cve_mun) as cve_geoid,
--     p.ano,
--     p.bien_juridico_afectado,
--     p.tipo_de_delito,
--     p.subtipo_de_delito,
--     p.modalidad,
--     t.*
-- from processed p
--   cross join lateral (
--      values 
--        (p.enero, 1),
--        (p.febrero, 2),
--        (p.marzo, 3),
--        (p.abril, 4),
--        (p.mayo, 5),
--        (p.junio, 6),
--        (p.julio, 7),
--        (p.agosto, 8),
--        (p.septiembre, 9),
--        (p.octubre, 10),
--        (p.noviembre, 11),
--        (p.diciembre, 12)
--   ) as t(ct, month);

alter table processed.municipal_delitos add column seq_id serial primary key;