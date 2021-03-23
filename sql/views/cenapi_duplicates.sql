create table views.cenapi_duplicates as

with processed as (
    select
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

select * from (
  SELECT cve_geoid, cve_ent, cve_mun, cve_ent_localizado, cve_mun_localizado, fecha_de_ingreso, fecha_de_localizacion, fecha_de_nacimiento, fecha_de_ultimo_avistamiento, fecha_evento, fecha_probable_de_fallecimiento, fecha_reporte, edad, causal, causas_de_fallecimiento, clasificacion_causal, condicion_encontrado, descripcion_senas_particulares, entidad, estado, estado_localizado, estatus_migratorio, hora_de_ingreso, hora_de_localizacion, hora_de_ultimo_avistamiento, hora_evento, hora_reporte, municipio, municipio_localizado, nacionalidad, ocupacion, pais_de_origen, posible_causa_desaparicion, procedencia, senas_particulares, sexo, situacion_de_la_persona_en_el_registro_nacional, tipo_casual, tipo_de_evento, tipo_denuncia, vivo_o_muerto,
  ROW_NUMBER() OVER(PARTITION BY cve_geoid, cve_ent, cve_mun, cve_ent_localizado, cve_mun_localizado, fecha_de_ingreso, fecha_de_localizacion, fecha_de_nacimiento, fecha_de_ultimo_avistamiento, fecha_evento, fecha_probable_de_fallecimiento, fecha_reporte, edad, causal, causas_de_fallecimiento, clasificacion_causal, condicion_encontrado, descripcion_senas_particulares, entidad, estado, estado_localizado, estatus_migratorio, hora_de_ingreso, hora_de_localizacion, hora_de_ultimo_avistamiento, hora_evento, hora_reporte, municipio, municipio_localizado, nacionalidad, ocupacion, pais_de_origen, posible_causa_desaparicion, procedencia, senas_particulares, sexo, situacion_de_la_persona_en_el_registro_nacional, tipo_casual, tipo_de_evento, tipo_denuncia, vivo_o_muerto 
  ORDER BY cve_geoid, cve_ent, cve_mun, cve_ent_localizado, cve_mun_localizado, fecha_de_ingreso, fecha_de_localizacion, fecha_de_nacimiento, fecha_de_ultimo_avistamiento, fecha_evento, fecha_probable_de_fallecimiento, fecha_reporte, edad, causal, causas_de_fallecimiento, clasificacion_causal, condicion_encontrado, descripcion_senas_particulares, entidad, estado, estado_localizado, estatus_migratorio, hora_de_ingreso, hora_de_localizacion, hora_de_ultimo_avistamiento, hora_evento, hora_reporte, municipio, municipio_localizado, nacionalidad, ocupacion, pais_de_origen, posible_causa_desaparicion, procedencia, senas_particulares, sexo, situacion_de_la_persona_en_el_registro_nacional, tipo_casual, tipo_de_evento, tipo_denuncia, vivo_o_muerto) AS num_dupes
  FROM processed
) dups
    where 
dups.num_dupes > 1
;