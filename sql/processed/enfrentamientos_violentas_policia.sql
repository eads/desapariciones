create table processed.enfrentamientos_violentas_policia as 

select 
    LPAD(clave_municipio, 5, '0') as cve_geoid,
    LPAD(clave_estado, 2, '0') as cve_ent,
    id,
    case
        when fecha = 'sin_informacion' THEN null
        else to_date(LPAD(fecha, 10, '0'), 'MM/DD/YYYY')
    end as fecha,
    case
        when year = 'sin_informacion' THEN null
        else year::int
    end as year,
    tipo_de_documento,
    clave_tipo_de_documento,
    tipo_de_evento,
    clave_tipo_de_evento,
    heridos_autoridades,
    muertos_autoridades,
    detenidos,
    heridos_delincuencia,
    muertos_delincuencia,
    heridos_civiles,
    muertos_civiles,
    policia_federal,
    semar,
    pgr,
    policia_estatal,
    policia_municipal,
    afi,
    estado_mayor
from raw.enfrentamientos_violentas_policia;

alter table processed.enfrentamientos_violentas_policia add column seq_id serial primary key;