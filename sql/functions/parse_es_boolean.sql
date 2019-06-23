create or replace function parse_es_boolean(arg text)
returns boolean language plpgsql
as $$
begin
    if arg = 'SI' then
      return true;
    elsif arg = 'NO' then
      return false;
    else
      return null;
    end if;
end $$;


