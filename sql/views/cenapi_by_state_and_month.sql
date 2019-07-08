create table views.cenapi_by_state_and_month as

select
    c.cve_ent,
    a.nom_ent,
    extract(year from fecha_reporte) as year,
    to_char(fecha_reporte, 'YYYY-MM') as year_month,
    extract(month from fecha_reporte) as month,
    count(*)
from
    processed.cenapi c
join
  areas_geoestadisticas_estatales a
    on a.cve_ent = c.cve_ent
where
    c.cve_ent != '0'
group by
    c.cve_ent,
    a.nom_ent,
    year,
    year_month,
    month
order by
    cve_ent,
    year,
    month
;


