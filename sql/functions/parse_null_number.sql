create or replace function parse_null_number(arg text)
returns numeric language plpgsql
as $$
begin
    if arg = 'nan' then
      return null;
    else
      return arg::numeric;
    end if;
end $$;

