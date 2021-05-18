
create table processed.enfrentamientos_violentas_sedena as 

select 
    id,
    LPAD(clave_municipio, 5, '0') as cve_geoid,
    row_number() over (partition by LPAD(clave_estado, 2, '0'), RIGHT(clave_municipio, 3)) as cve_geoid_seq_id,
    make_date(ano::int, mes_num::int, 1) as fecha,
    extract(epoch from make_date(ano::int, mes_num::int, 1)) as fecha_ts,
    parse_geoid(clave_estado, '2') as cve_ent,
    ano::int,
    mes_num::int,
    militar_muerto_num::int,
    militar_herido_num::int,
    agresor_muerto_num::int,
    agresor_herido_num::int,
    agresor_detenido_num::int,
    enfren
from raw.enfrentamientos_violentas_sedena;

alter table processed.enfrentamientos_violentas_sedena add column seq_id serial primary key;