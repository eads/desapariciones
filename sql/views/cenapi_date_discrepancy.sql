create table views.cenapi_date_discrepancy as

select
    *,
    'reporte < evento' as discrepancy_type
from processed.cenapi c
where 
    c.fecha_reporte < c.fecha_evento
    
union all

select
    *,
    'localizacion < evento' as discrepancy_type
from processed.cenapi c
where 
    c.fecha_de_localizacion is not null and
    c.fecha_de_localizacion < c.fecha_evento

union all

select
    *,
    'localizacion < reporte' as discrepancy_type
from processed.cenapi c
where 
    c.fecha_de_localizacion is not null and
    c.fecha_de_localizacion < c.fecha_reporte     
;