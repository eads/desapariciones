create or replace function parse_nan_text(arg text)
returns character varying language plpgsql
as $$
begin
    if arg = 'nan' or arg = 'NO ESPECIFICADO' or arg = 'SIN DATO' then
      return null;
    else
      return arg;
    end if;
end $$;

