create table processed.cenapi as

with deduped as (
    select distinct
        /* Create geo identifiers */
        parse_geoid(clave_estado, 2) as cve_ent,
        parse_geoid(clave_municipio, 3) as cve_mun,
        parse_geoid(clave_estado_localizado, 2) as cve_ent_localizado,
        parse_geoid(clave_municipio_localizado, 3) as cve_mun_localizado,

        /* Hasura no longer needs a single column to join on, but lots now depends on this ID */
        concat(parse_geoid(clave_estado, 2), parse_geoid(clave_municipio, 3)) as cve_geoid,
        concat(parse_geoid(clave_estado_localizado, 2), parse_geoid(clave_municipio_localizado, 3)) as cve_geoid_localizado,

        /* Cast dates to timestamp */
        parse_timestamp(fecha_de_ingreso) as fecha_de_ingreso,
        parse_timestamp(fecha_de_localizacion) as fecha_de_localizacion,
        parse_timestamp(fecha_de_nacimiento) as fecha_de_nacimiento,
        parse_timestamp(fecha_de_ultimo_avistamiento) as fecha_de_ultimo_avistamiento,
        parse_timestamp(fecha_evento) as fecha_evento,
        parse_timestamp(fecha_probable_de_fallecimiento) as fecha_probable_de_fallecimiento,
        parse_timestamp(fecha_reporte) as fecha_reporte,

        /* Parse numbers */
        parse_null_number(estatura) as estatura,
        parse_null_number(edad) as edad,
        parse_null_number(peso) as peso,

        /* Parse boolean */
        parse_es_boolean(contaba_con_aparatos_de_comunicacion) as contaba_con_aparatos_de_comunicacion,
        parse_es_boolean(discapacidad_fisica) as discapacidad_fisica,
        parse_es_boolean(discapacidad_mental) as discapacidad_mental,
        parse_es_boolean(relacion_con_grupos_delictivos) as relacion_con_grupos_delictivos,

        /* Parse text */
        parse_null_text(ano_del_vehiculo) as ano_del_vehiculo,
        parse_null_text(anteojos) as anteojos,
        parse_null_text(barba) as barba,
        parse_null_text(bigote) as bigote,
        parse_null_text(causal) as causal,
        parse_null_text(causas_de_fallecimiento) as causas_de_fallecimiento,
        parse_null_text(cejas) as cejas,
        parse_null_text(clasificacion_causal) as clasificacion_causal,
        parse_null_text(color_de_ojos) as color_de_ojos,
        parse_null_text(color_del_cabello) as color_del_cabello,
        parse_null_text(condicion_encontrado) as condicion_encontrado,
        parse_null_text(descripcion_de_vestimenta) as descripcion_de_vestimenta,
        parse_null_text(descripcion_media_filiacion) as descripcion_media_filiacion,
        parse_null_text(descripcion_senas_particulares) as descripcion_senas_particulares,
        parse_null_text(ente_que_localiza) as ente_que_localiza,
        parse_null_text(entidad) as entidad,
        parse_null_text(estado) as estado,
        parse_null_text(estado_localizado) as estado_localizado,
        parse_null_text(estatus_migratorio) as estatus_migratorio,
        parse_null_text(etnia) as etnia,
        parse_null_text(forma_de_la_cara) as forma_de_la_cara,
        parse_null_text(forma_del_cabello) as forma_del_cabello,
        parse_null_text(forma_del_menton) as forma_del_menton,
        parse_null_text(grosor_de_labios) as grosor_de_labios,
        parse_null_text(hora_de_ingreso) as hora_de_ingreso,
        parse_null_text(hora_de_localizacion) as hora_de_localizacion,
        parse_null_text(hora_de_ultimo_avistamiento) as hora_de_ultimo_avistamiento,
        parse_null_text(hora_evento) as hora_evento,
        parse_null_text(hora_reporte) as hora_reporte,
        parse_null_text(largo_del_cabello) as largo_del_cabello,
        parse_null_text(marca_de_vehiculo) as marca_de_vehiculo,
        parse_null_text(municipio) as municipio,
        parse_null_text(municipio_localizado) as municipio_localizado,
        parse_null_text(nacionalidad) as nacionalidad,
        parse_null_text(ocupacion) as ocupacion,
        parse_null_text(padecimiento_o_enfermedad) as padecimiento_o_enfermedad,
        parse_null_text(pais_de_origen) as pais_de_origen,
        parse_null_text(posible_causa_desaparicion) as posible_causa_desaparicion,
        parse_null_text(procedencia) as procedencia,
        parse_null_text(senas_particulares) as senas_particulares,
        parse_null_text(sexo) as sexo,
        parse_null_text(situacion_de_la_persona_en_el_registro_nacional) as situacion_de_la_persona_en_el_registro_nacional,
        parse_null_text(submarca) as submarca,
        parse_null_text(tamano_de_la_boca) as tamano_de_la_boca,
        parse_null_text(tamano_de_la_nariz) as tamano_de_la_nariz,
        parse_null_text(tamano_de_orejas) as tamano_de_orejas,
        parse_null_text(tez) as tez,
        parse_null_text(tipo_casual) as tipo_casual,
        parse_null_text(tipo_de_cejas) as tipo_de_cejas,
        parse_null_text(tipo_de_discapacidad_mental) as tipo_de_discapacidad_mental,
        parse_null_text(tipo_de_evento) as tipo_de_evento,
        parse_null_text(tipo_de_frente) as tipo_de_frente,
        parse_null_text(tipo_de_nariz) as tipo_de_nariz,
        parse_null_text(tipo_de_ojos) as tipo_de_ojos,
        parse_null_text(tipo_de_vehiculo) as tipo_de_vehiculo,
        parse_null_text(tipo_denuncia) as tipo_denuncia,
        parse_null_text(vivo_o_muerto) as vivo_o_muerto
    from raw.cenapi
)
select 
    -- This id is unique to municipalities; this is used to join with randomly generated
    -- points in the cenapi_distributed view (make db/views/cenapi_distributed)
    row_number() over (partition by cve_ent, cve_mun) as cve_geoid_seq_id,
    cve_geoid,
    cve_ent,
    cve_mun,
    cve_ent_localizado,
    cve_mun_localizado,

    fecha_de_ingreso,
    fecha_de_localizacion,
    fecha_de_nacimiento,
    fecha_de_ultimo_avistamiento,
    fecha_evento,
    fecha_probable_de_fallecimiento,
    fecha_reporte,

    extract(epoch from fecha_de_ingreso) as fecha_de_ingreso_ts,
    extract(epoch from fecha_de_localizacion) as fecha_de_localizacion_ts,
    extract(epoch from fecha_de_nacimiento) as fecha_de_nacimiento_ts,
    extract(epoch from fecha_de_ultimo_avistamiento) as fecha_de_ultimo_avistamiento_ts,
    extract(epoch from fecha_evento) as fecha_evento_ts,
    extract(epoch from fecha_probable_de_fallecimiento) as fecha_probable_de_fallecimiento_ts,
    extract(epoch from fecha_reporte) as fecha_reporte_ts,

    extract(year from fecha_de_ingreso) as fecha_de_ingreso_year,
    extract(year from fecha_de_localizacion) as fecha_de_localizacion_year,
    extract(year from fecha_de_nacimiento) as fecha_de_nacimiento_year,
    extract(year from fecha_de_ultimo_avistamiento) as fecha_de_ultimo_avistamiento_year,
    extract(year from fecha_evento) as fecha_evento_year,
    extract(year from fecha_probable_de_fallecimiento) as fecha_probable_de_fallecimiento_year,
    extract(year from fecha_reporte) as fecha_reporte_year,

    extract(month from fecha_de_ingreso) as fecha_de_ingreso_month,
    extract(month from fecha_de_localizacion) as fecha_de_localizacion_month,
    extract(month from fecha_de_nacimiento) as fecha_de_nacimiento_month,
    extract(month from fecha_de_ultimo_avistamiento) as fecha_de_ultimo_avistamiento_month,
    extract(month from fecha_evento) as fecha_evento_month,
    extract(month from fecha_probable_de_fallecimiento) as fecha_probable_de_fallecimiento_month,
    extract(month from fecha_reporte) as fecha_reporte_month,
    
    extract(day from fecha_de_ingreso) as fecha_de_ingreso_day,
    extract(day from fecha_de_localizacion) as fecha_de_localizacion_day,
    extract(day from fecha_de_nacimiento) as fecha_de_nacimiento_day,
    extract(day from fecha_de_ultimo_avistamiento) as fecha_de_ultimo_avistamiento_day,
    extract(day from fecha_evento) as fecha_evento_day,
    extract(day from fecha_probable_de_fallecimiento) as fecha_probable_de_fallecimiento_day,
    extract(day from fecha_reporte) as fecha_reporte_day,

    -- Time between FECHA REPORTE and FECHA EVENTO
    extract(day from (fecha_reporte - fecha_evento)) as diff_fecha_reporte_fecha_evento,
    -- Time between FECHA REPORTE and FECHA DE ÚLTIMO AVISTAMIENTO 
    extract(day from (fecha_reporte - fecha_de_ultimo_avistamiento)) as diff_fecha_reporte_fecha_de_ultimo_avistamiento,
    -- Time between FECHA REPORTE and FECHA DE LOCALIZACIÓN
    extract(day from (fecha_reporte - fecha_de_localizacion)) as diff_fecha_reporte_fecha_de_localizacion,
    -- Time between FECHA EVENTO and FECHA DE LOCALIZACIÓN
    extract(day from (fecha_evento - fecha_de_localizacion)) as diff_fecha_evento_fecha_de_localizacion,
    -- Time between FECHA DE ÚLTIMO AVISTAMIENTO and FECHA DE LOCALIZACIÓN
    extract(day from (fecha_de_ultimo_avistamiento - fecha_de_localizacion)) as diff_fecha_de_ultimo_avistamiento_fecha_de_localizacion,
    -- Time between event date and FECHA PROBABLE DE FALLECIMIENTO
    extract(day from (fecha_evento - fecha_probable_de_fallecimiento)) as diff_fecha_evento_fecha_probable_de_fallecimiento,
    -- Time between FECHA DE LOCALIZACIÓN and FECHA PROBABLE DE FALLECIMIENTO
    extract(day from (fecha_de_localizacion - fecha_probable_de_fallecimiento)) as diff_fecha_de_localizacion_fecha_probable_de_fallecimiento,

    estatura,
    edad,
    peso,
    discapacidad_fisica,
    discapacidad_mental,
    relacion_con_grupos_delictivos,
    ano_del_vehiculo,
    anteojos,
    barba,
    bigote,
    causal,
    causas_de_fallecimiento,
    cejas,
    clasificacion_causal,
    color_de_ojos,
    color_del_cabello,
    condicion_encontrado,
    descripcion_de_vestimenta,
    descripcion_media_filiacion,
    descripcion_senas_particulares,
    ente_que_localiza,
    entidad,
    estado,
    estado_localizado,
    estatus_migratorio,
    etnia,
    forma_de_la_cara,
    forma_del_cabello,
    forma_del_menton,
    grosor_de_labios,
    hora_de_ingreso,
    hora_de_localizacion,
    hora_de_ultimo_avistamiento,
    hora_evento,
    hora_reporte,
    largo_del_cabello,
    marca_de_vehiculo,
    municipio,
    municipio_localizado,
    nacionalidad,
    ocupacion,
    padecimiento_o_enfermedad,
    pais_de_origen,
    posible_causa_desaparicion,
    procedencia,
    senas_particulares,
    sexo,
    situacion_de_la_persona_en_el_registro_nacional,
    submarca,
    tamano_de_la_boca,
    tamano_de_la_nariz,
    tamano_de_orejas,
    tez,
    tipo_casual,
    tipo_de_cejas,
    tipo_de_discapacidad_mental,
    tipo_de_evento,
    tipo_de_frente,
    tipo_de_nariz,
    tipo_de_ojos,
    tipo_de_vehiculo,
    tipo_denuncia,
    vivo_o_muerto

from deduped;

alter table processed.cenapi add column seq_id serial primary key;

create index idx_cenapi_cve_geoid on processed.cenapi(cve_geoid);
create index idx_cenapi_cve_ent on processed.cenapi(cve_ent);
create index idx_cenapi_cve_mun on processed.cenapi(cve_mun);
create index idx_cenapi_cve_ent_cve_mun on processed.cenapi(cve_ent, cve_mun);

comment on column processed.cenapi.estado is 'estado donde la persona fue reportada como desaparecida';
comment on column processed.cenapi.municipio is 'municipio donde la persona fue reportada como desaparecida';
comment on column processed.cenapi.estado_localizado is 'estado donde la persona se reportó como localizada';
comment on column processed.cenapi.municipio_localizado is 'municipio donde la persona se reportó como localizada';
comment on column processed.cenapi.fecha_reporte_year is 'año en que se presentó el reporte de deesaparición';
comment on column processed.cenapi.fecha_reporte_month is 'mes en que se presentó el reporte';
comment on column processed.cenapi.fecha_reporte_day is 'día en que se presentó el reporte de desaparición';
comment on column processed.cenapi.sexo is 'género de la persona reportada como desaparecida';
comment on column processed.cenapi.estatus is 'estatus de la persona reportada al XX de abril de 2018 (vivo, muerto, aun sin localizar)';
comment on column processed.cenapi.edad is 'edad de la persona a la fecha de desaparición';
comment on column processed.cenapi.fecha_evento_year is 'año en el que la persona desapareció';
comment on column processed.cenapi.fecha_evento_month is 'mes en el que la persona desapareció';
comment on column processed.cenapi.fecha_evento_day is 'día en el que la persona desapareció';
comment on column processed.cenapi.fecha_de_localizacion_year is 'año de localización de la persona';
comment on column processed.cenapi.fecha_de_localizacion_month is 'mes de localización de la persona';
comment on column processed.cenapi.fecha_de_localizacion_day is 'día de localización de la persona';
comment on column processed.cenapi.etnia is 'grupo étnico de la persona reportada como desaparecida';
comment on column processed.cenapi.ocupacion is 'ocupación de la persona reportada como desaparecida';
