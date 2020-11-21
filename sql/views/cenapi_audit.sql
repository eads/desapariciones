create table public.cenapi_audit as

with
  missing_state as (
    select
      count(*) as missing_state_count
    from
      processed.cenapi
    where
      cve_ent = '00'
  ),
  missing_municipality as (
    select
      count(*) as missing_municipality_count
    from
      processed.cenapi
    where
      cve_mun = '000'
  ),
  missing_state_and_municipality as (
    select
      count(*) as missing_state_and_municipality_count
    from
      processed.cenapi
    where
      cve_ent = '00' and cve_mun = '000'
  ),
  missing_fecha_evento as (
    select
      count(*) as missing_fecha_evento_count
    from
      processed.cenapi
    where
      fecha_evento is null
  ),
  missing_fecha_reporte as (
    select
      count(*) as missing_fecha_reporte_count
    from
      processed.cenapi
    where
      fecha_reporte is null
  ),
  columns as (
    select
      missing_state_count,
      missing_municipality_count,
      missing_state_and_municipality_count,
      missing_fecha_evento_count,
      missing_fecha_reporte_count
    from
      missing_state,
      missing_municipality,
      missing_state_and_municipality,
      missing_fecha_evento,
      missing_fecha_reporte
  )

  select (x).key as test, (x).value
  from
    (select each(hstore(columns)) as x from columns) q
;
