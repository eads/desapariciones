create view views.cenapi_audit as

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
  columns as (
    select
      missing_state_count,
      missing_municipality_count,
      missing_state_and_municipality_count
    from
      missing_state,
      missing_municipality,
      missing_state_and_municipality
  )

  select (x).key as test, (x).value
  from
    (select each(hstore(columns)) as x from columns) q
;
