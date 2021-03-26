
create table processed.enfrentamientos_violentas_sedena as 

select 
    id,
    LPAD(clave_municipio, 5, '0') as cve_geoid,
    make_date(ano::int, mes_num::int, 1) as date,
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