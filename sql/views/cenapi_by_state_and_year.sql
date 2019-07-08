create table views.cenapi_by_state_and_year as

with agg as (
  select
      c.cve_ent,
      a.nom_ent,
      extract(year from fecha_reporte) as year,
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
      year
  order by
      cve_ent,
      year
)
select
  cve_ent,
  nom_ent,
  year,
  count,
  sum(count) OVER (PARTITION BY cve_ent ORDER BY year) AS cumulative_count
from agg
;


