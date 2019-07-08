create table views.cenapi_by_year as

select
    cve_geoid,
    extract(year from fecha_reporte) as year,
    count(*)
from
    processed.cenapi
where
    cve_ent != '0'
group by
    cve_geoid,
    year
order by
    cve_geoid,
    year
;
