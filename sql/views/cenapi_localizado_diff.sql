create table views.cenapi_localizado_diff as

select
  c1.*
from
  processed.cenapi c1
join
  processed.cenapi c2 on c1.seq_id = c2.seq_id
where
  c1.cve_ent != c2.cve_ent_localizado or
  c1.cve_mun != c2.cve_mun_localizado;

alter table views.cenapi_localizado_diff add primary key (seq_id);

create index idx_cenapi_localizado_diff_cve_geoid on views.cenapi_localizado_diff(cve_geoid);
create index idx_cenapi_localizado_diff_cve_ent on views.cenapi_localizado_diff(cve_ent);
create index idx_cenapi_localizado_diff_cve_mun on views.cenapi_localizado_diff(cve_mun);
create index idx_cenapi_localizado_diff_cve_ent_cve_mun on views.cenapi_localizado_diff(cve_ent, cve_mun);
