create or replace function parse_geoid(arg text, pad integer)
returns character varying(3) language plpgsql
as $$
begin
    if arg = '0' or arg = '' then
      return LPAD('0', pad, '0');
    else
      return LPAD(arg, pad, '0');
    end if;
end $$;


