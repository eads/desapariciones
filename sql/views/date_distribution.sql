create table views.date_distribution as 

select * from calculate_percentiles('diff_fecha_reporte_fecha_evento')
union
select * from calculate_percentiles('diff_fecha_reporte_fecha_de_ultimo_avistamiento')
union
select * from calculate_percentiles('diff_fecha_reporte_fecha_de_localizacion')
union
select * from calculate_percentiles('diff_fecha_evento_fecha_de_localizacion')
union
select * from calculate_percentiles('diff_fecha_de_ultimo_avistamiento_fecha_de_localizacion')
union
select * from calculate_percentiles('diff_fecha_evento_fecha_probable_de_fallecimiento')
union
select * from calculate_percentiles('diff_fecha_de_localizacion_fecha_probable_de_fallecimiento')
;