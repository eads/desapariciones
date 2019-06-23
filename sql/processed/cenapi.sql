create table processed.cenapi as

select
    /* Create geo identifiers */
    parse_geoid(clave_estado, 2) as cve_ent,
    -- LPAD(clave_estado, 2, '0') as cve_ent,
    LPAD(clave_municipio, 3, '0') as cve_mun,
    LPAD(clave_estado_localizado, 2, '0') as cve_ent_localizado,
    LPAD(clave_municipio_localizado, 3, '0') as cve_mun_localizado,

    /* Cast dates to timestamp */
    parse_timestamp(fecha_de_ingreso) as fecha_de_ingreso,
    parse_timestamp(fecha_de_localizacion) as fecha_de_localizacion,
    parse_timestamp(fecha_de_nacimiento) as fecha_de_nacimiento,
    parse_timestamp(fecha_de_ultimo_avistamiento) as fecha_de_ultimo_avistamiento,
    parse_timestamp(fecha_evento) as fecha_evento,
    parse_timestamp(fecha_probable_de_fallecimiento) as fecha_probable_de_fallecimiento,
    parse_timestamp(fecha_reporte) as fecha_reporte,

    /* Parse numbers */
    parse_nan_number(estatura) as estatura,
    parse_nan_number(edad) as edad,
    parse_nan_number(peso) as peso,

    /* Parse boolean */
    parse_es_boolean(contaba_con_aparatos_de_comunicacion) as contaba_con_aparatos_de_comunicacion,
    parse_es_boolean(discapacidad_fisica) as discapacidad_fisica,
    parse_es_boolean(discapacidad_mental) as discapacidad_mental,
    parse_es_boolean(relacion_con_grupos_delictivos) as relacion_con_grupos_delictivos,

    /* Parse text */
    parse_nan_text(ano_del_vehiculo) as ano_del_vehiculo,
    parse_nan_text(anteojos) as anteojos,
    parse_nan_text(barba) as barba,
    parse_nan_text(bigote) as bigote,
    parse_nan_text(causal) as causal,
    parse_nan_text(causas_de_fallecimiento) as causas_de_fallecimiento,
    parse_nan_text(cejas) as cejas,
    parse_nan_text(clasificacion_causal) as clasificacion_causal,
    parse_nan_text(color_de_ojos) as color_de_ojos,
    parse_nan_text(color_del_cabello) as color_del_cabello,
    parse_nan_text(condicion_encontrado) as condicion_encontrado,
    parse_nan_text(descripcion_de_vestimenta) as descripcion_de_vestimenta,
    parse_nan_text(descripcion_media_filiacion) as descripcion_media_filiacion,
    parse_nan_text(descripcion_senas_particulares) as descripcion_senas_particulares,
    parse_nan_text(ente_que_localiza) as ente_que_localiza,
    parse_nan_text(entidad) as entidad,
    parse_nan_text(estado) as estado,
    parse_nan_text(estado_localizado) as estado_localizado,
    parse_nan_text(estatus_migratorio) as estatus_migratorio,
    parse_nan_text(etnia) as etnia,
    parse_nan_text(forma_de_la_cara) as forma_de_la_cara,
    parse_nan_text(forma_del_cabello) as forma_del_cabello,
    parse_nan_text(forma_del_menton) as forma_del_menton,
    parse_nan_text(grosor_de_labios) as grosor_de_labios,
    parse_nan_text(hora_de_ingreso) as hora_de_ingreso,
    parse_nan_text(hora_de_localizacion) as hora_de_localizacion,
    parse_nan_text(hora_de_ultimo_avistamiento) as hora_de_ultimo_avistamiento,
    parse_nan_text(hora_evento) as hora_evento,
    parse_nan_text(hora_reporte) as hora_reporte,
    parse_nan_text(largo_del_cabello) as largo_del_cabello,
    parse_nan_text(marca_de_vehiculo) as marca_de_vehiculo,
    parse_nan_text(municipio) as municipio,
    parse_nan_text(municipio_localizado) as municipio_localizado,
    parse_nan_text(nacionalidad) as nacionalidad,
    parse_nan_text(ocupacion) as ocupacion,
    parse_nan_text(padecimiento_o_enfermedad) as padecimiento_o_enfermedad,
    parse_nan_text(pais_de_origen) as pais_de_origen,
    parse_nan_text(posible_causa_desaparicion) as posible_causa_desaparicion,
    parse_nan_text(procedencia) as procedencia,
    parse_nan_text(senas_particulares) as senas_particulares,
    parse_nan_text(sexo) as sexo,
    parse_nan_text(situacion_de_la_persona_en_el_registro_nacional) as situacion_de_la_persona_en_el_registro_nacional,
    parse_nan_text(submarca) as submarca,
    parse_nan_text(tamano_de_la_boca) as tamano_de_la_boca,
    parse_nan_text(tamano_de_la_nariz) as tamano_de_la_nariz,
    parse_nan_text(tamano_de_orejas) as tamano_de_orejas,
    parse_nan_text(tez) as tez,
    parse_nan_text(tipo_casual) as tipo_casual,
    parse_nan_text(tipo_de_cejas) as tipo_de_cejas,
    parse_nan_text(tipo_de_discapacidad_mental) as tipo_de_discapacidad_mental,
    parse_nan_text(tipo_de_evento) as tipo_de_evento,
    parse_nan_text(tipo_de_frente) as tipo_de_frente,
    parse_nan_text(tipo_de_nariz) as tipo_de_nariz,
    parse_nan_text(tipo_de_ojos) as tipo_de_ojos,
    parse_nan_text(tipo_de_vehiculo) as tipo_de_vehiculo,
    parse_nan_text(tipo_denuncia) as tipo_denuncia,
    parse_nan_text(vivo_o_muerto) as vivo_o_muerto
from raw.cenapi;

create index idx_cenapi_cve_ent on processed.cenapi(cve_ent);
create index idx_cenapi_cve_mun on processed.cenapi(cve_mun);
create index idx_cenapi_cve_ent_cve_mun on processed.cenapi(cve_ent, cve_mun);
