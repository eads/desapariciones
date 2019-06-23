create or replace function parse_timestamp(arg text)
returns timestamp language plpgsql
as $$
begin
    begin
        return arg::timestamp;
    exception when others then
        return null;
    end;
end $$;
