create table processed.censo_2010 as

select
    i_entidad as cve_ent,
    mun as cve_mun,
    loc,
    nom_loc,
    case
        when (pobtot = '*') THEN -1
        else pobtot::int
    end as pobtot
from raw.censo_2010
where loc = '0000'
;

alter table processed.censo_2010 add column seq_id serial primary key;