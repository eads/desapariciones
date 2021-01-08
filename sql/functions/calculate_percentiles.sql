create or replace function calculate_percentiles(tablename text)
returns table(name text, percentile int, max interval) language plpgsql
as $$

begin
return query execute

format('
    select 
        ''%I'' as name,
        ntile as percentile,
        max(value)::interval
    from (
        select 
            %I as value, 
            ntile(100) over (order by %I) 
        from processed.cenapi
    ) as buckets
    group by name, percentile order by percentile desc
', $1, $1, $1);

end $$;