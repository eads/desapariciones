##############
### QUINTO ELEMENTO LAB
### A DÓNDE VAN LOS DESAPARECIDOS
### MAPA
### OBJETIVO: RELACIONAR CADA REGISTRO DE LA BASE DE DATOS DEL CENAPI
### CON LOS REGISTROS DEL EXTINTO REGISTRO NACIONAL DE DATOS DE PERSONAS EXTRAVIADAS Y DESAPARECIDAS (RNPED), FUERO COMÚN
##############

# POR CUESTIONES DE CONFIGURACIÓN DEL PROGRAMA SE TUVO QUE CORRES ESTE CÓDIGO PARA PODER LEER
# LAS BASES DE DATOS EN FORMATO CSV Y XLSX, ESTO DEBIDO AL USO DE TILDES Y «Ñ» EN EL NOMBRE DE MUNICIPIOS.

# first try Windows CP1252, although that's almost surely not supported on Mac:
Sys.setlocale("LC_ALL", "pt_PT.1252") # Make sure not to omit the `"LC_ALL",` first argument, it will fail.
Sys.setlocale("LC_ALL", "pt_PT.CP1252") # the name might need to be 'CP1252'

# next try IS08859-1(/'latin1'), this works for me:
Sys.setlocale("LC_ALL", "pt_PT.ISO8859-1")


# PAQUETES QUE SE REQUIEREN PARA CORRER EL CÓDIGO
require(pacman)
p_load(ggmosaic, ggrepel, treemapify)
require(tidyverse)
require(readxl)
p_load(stringr, foreign)


# DIRECTORIOS
inp <- "/Users/macbookpro8/Documents/Proyecto/Datos Proyecto/Prueba/Match RNPED-CENAPI/input"
out = "/Users/macbookpro8/Documents/Proyecto/Datos Proyecto/Prueba/Match RNPED-CENAPI/out"
cat_mun = "/Users/macbookpro8/Documents/Proyecto/Datos Proyecto/Prueba/Match RNPED-CENAPI/input/municipios"
cat_edo = "/Users/macbookpro8/Documents/Proyecto/Datos Proyecto/Prueba/Match RNPED-CENAPI/input/estados"

# LA BASE DEL RNPED SE TUVO QUE COPIAR A FORMATO EXCEL Y MODIFICAR DE ACUERDO A LA NOTA METODOLÓGICA ANTES DE
# ABRIRLO EN R.
rnped = read_excel(paste(inp, "RNPEDFC.xlsx", sep="/"))


#############
####INEGI####
#############

# ESTOS CATÁLOGOS DE INEGI FUERON COPIADOS A FORMATO EXCEL PARA FACILITAR SU USO, NO SE ALTERÓ
# SU CONTENIDO
inegi <- read_excel(paste(inp, "cat_municipios.xlsx", sep="/"))
inegi_edo <- read_excel(paste(inp, "cat_estados.xlsx", sep="/"))


###############
#####RNPED#####
###############

#PONER EN MINÚSCULAS LOS NOMBRES DE LAS VARIABLES
names(rnped) = tolower(names(rnped))
names(rnped)


#SELECCIONAR VARIABLES DE INTERÉS
names(rnped)
rnped <- select(rnped, "fecha en que se le vio por ultima vez", "entidad en que se le vio por ultima vez",
                "municipio en que se le vio por ultima vez", "localidad en que se le vio por ultima vez",
                nacionalidad, sexo, edad)

#RENOMBRAR LAS VARIABLES
nom_rnped = c("fecha_avista", "edo", "mun","localidad","nacionalidad", "sexo", "edad")
names(rnped)= nom_rnped
names(rnped)

#MODIFICAR NOMBRES DE LOS SIGUIENTES ESTADOS PARA QUE COINCIDAN CON LOS CATÁLOGOS DE INEGI
rnped$edo <- gsub("ESTADO DE MEXICO", "MEXICO", rnped$edo)
rnped$edo <- gsub("CIUDAD DE MEXICO", "DISTRITO FEDERAL", rnped$edo)
rnped$edo <- gsub("VERACRUZ", "VERACRUZ DE IGNACIO DE LA LLAVE", rnped$edo)
rnped$edo <- gsub("MICHOACAN", "MICHOACAN DE OCAMPO", rnped$edo)

#UNIR RNPED CON CATÁLOGOS DE INEGI POR LA VIARABLE «edo», ES DECIR, POR EL NOMBRE DEL ESTADO
rnped = left_join (rnped, inegi_edo, by = "edo")

#EN EL CATÁLOGO DE INEGI CON MUNICIPIOS, UNIR EL CATÁLOGO DE INEGI POR ESTADO PARA CONTAR CON LA CLAVE DEL ESTADO (id_edo)
inegi = left_join(inegi, inegi_edo, by="id_edo")

#EN RNPED Y EL CATÁLOGO DE MUNICIPIO, CREAR UNA NUEVA VARIABLE CON LOS NOMBRES DE ESTADO Y MUNICIPIO PARA
#POSTERIORMENTE UNIR AMBAS BASES A PARTIR DE ESTA NUEVA VARIABLE
rnped$mun_edo = paste(rnped$mun, rnped$edo, sep=" ")
inegi$mun_edo = paste(inegi$mun, inegi$edo, sep=" ")

rnped = left_join(rnped, inegi, by="mun_edo")

#SELECCIONAR Y RENOMBRAR VARIABLES NUEVAMENTE
names(rnped)
rnped <- select(rnped, fecha_avista, edo.x, mun.x, sexo, edad, id_edo.x, id_mun)

rnped = rename(rnped, id_edo=id_edo.x)
rnped = rename(rnped, mun=mun.x)
rnped = rename(rnped, edo=edo.x)

table(rnped$id_edo)

#CREAR VARIABLE QUE CONTENGAN LA CLAVE DEL ESTADO Y DEL MUNICIPIO
rnped$id = paste(rnped$id_edo, rnped$id_mun, sep="")

#CREAR VARIABLE DEL AÑO DE ÚLTIMO AVISTAMIENTO
rnped$ano_avista = substr(rnped$fecha_avista, 1, 4)


#CREAR VARIABLE GPO DE EDAD
rnped$edad <- as.numeric(rnped$edad)
rnped = mutate(rnped, gpo_edad = if_else(edad>=60, "mas de 60",
                                 if_else(edad>=55, "55 - 59",
                                 if_else(edad>=50, "50 - 54",
                                 if_else(edad>=45, "45 - 49",
                                 if_else(edad>=40, "40 - 44",
                                 if_else(edad>=35, "35 - 39",
                                 if_else(edad>=30, "30 - 34",
                                 if_else(edad>=25, "25 - 29",
                                 if_else(edad>=18, "18 - 24",
                                 if_else(edad>=10, "10 - 17",
                                 if_else(edad>=6, "6 - 9",
                                 if_else(edad>=0, "0 - 5",  "NO ESPECIFICADO")))))))))))))


rnped <- rnped[, c("id", "id_edo", "id_mun", "edo", "mun", "fecha_avista",
                   "sexo", "edad", "gpo_edad")]

#CAMBIAR GÉNERO
rnped$sexo <- gsub("MUJER", "F", rnped$sexo)
rnped$sexo <- gsub("HOMBRE", "M", rnped$sexo)

#CREAR NUEVA VARIABLE SOBRE LA FUENTE DEL REGISTRO (RNPED)
rnped$fuente <- "RNPED"

str(rnped)
rnped <- as.data.frame(rnped)
rnped$fecha_avista <- as.character(rnped$fecha_avista)

#CREAR NUEVA VARIABLE CON «COD_R» PARA IDENTIFICAR LA FUENTE DEL REGISTRO
rnped$cod_r <- seq.int(nrow(rnped))

#EXPORTAR
#write.csv(rnped, paste(out, "rnped_2.csv", sep="/"), row.names = F, fileEncoding = "UTF-8")

################
#####CENAPI#####
################

# SE REALIZARON MODIFICACIONES ANTES DE ABRIRLO EN R DE ACUERDO A LA NOTA METODOLÓGICA

cenapi = read.csv("/Users/macbookpro8/Documents/Proyecto/Datos Proyecto/Prueba/Match RNPED-CENAPI/input/cenapi.csv", encoding = "UTF-8")

#SELECCIONAR VARIABLES Y MODIFICAR EL NOMBRE DE LAS MISMAS
cenapi <- select(cenapi, FECHA.REPORTE, FECHA.EVENTO, ESTADO:NACIONALIDAD, SEXO, EDAD:PROCEDENCIA, ANTEOJOS:CAUSAS.DE.FALLECIMIENTO)
nom_cenapi = c("fecha_den", "fecha_hechos", "edo", "id_edo", "mun", "id_mun", "nacionalidad", "sexo", "edad", "senas_part", "descrip_sen",
              "desc_1", "pad","disc","t_disc","vest","aparato","ocupacion","relacion_gdo", "fecha_avista", "h_av", "v", "v1", "v2",
              "dis_f", "proc", "anteojos", "fecha_localizacion", "h_e", "estatus", "causa_desap", "condicion_localizado", "edo_localizado",
              "id_edo_localizado", "mun_localizado", "id_mun_localizado", "ente", "f_ingreso", "h-in", "fecha_fallecimiento", "causa_fallecimiento")
names(cenapi)= nom_cenapi
names(cenapi)
cenapi <- select(cenapi, fecha_den:edad, ocupacion, relacion_gdo, fecha_avista, fecha_localizacion, estatus, causa_desap,
                 condicion_localizado:id_mun_localizado, fecha_fallecimiento, causa_fallecimiento)


#ARREGLAR BASE
#1. ELIMINAR EDADES EN CELDAS 9682 (250 AÑOS), 67179 (501 AÑOS), 79873 (172 AÑOS), 85244 (444 AÑOS),
# 93421 (2017 AÑOS) Y 98921 (346 AÑOS)
cenapi$edad[ cenapi$edad >120 ] <- NA

#2. Modificar 0 en «CLAVE.ESTADO» por NA
cenapi$id_edo[ cenapi$id_edo == "0" ] <- NA

#3. Modificar 0 en «CLAVE.MUNICIPIO» por NA
cenapi$id_mun[ cenapi$id_mun == "0" ] <- NA

#4. Agregar clave de estado a celda 2879 de Zacatecas que tiene NA en vez de 32;
# 28 a Tamulipas celda 93,698 y 16 a Michoacán celda 10,983
cenapi$id_edo[cenapi$edo == "ZACATECAS"] = 32
cenapi$id_edo[cenapi$edo == "MICHOACAN"] = 16
cenapi$id_edo[cenapi$edo == "TAMAULIPAS"] = 28

#5. Modificar «NaN» por «NO ESPECIFICADO» en SEXO para homologar con RNPED
cenapi$sexo <- gsub("nan", "NO ESPECIFICADO", cenapi$sexo)

#6. Modificar «NaN» por «NO ESPECIFICADO» en EDAD para homologar con RNPED
cenapi$edad <- gsub("NaN", "NO ESPECIFICADO", cenapi$edad)

#7. Modificar «nan» por «NO ESPECIFICADO» en MUNICIPIO para homologar con RNPED
cenapi$mun <- gsub("nan", "NO ESPECIFICADO", cenapi$mun)

#8. Modificar «nan» por NA en FECHA.LOCALIZACIÓN
cenapi$fecha_localizacion[ cenapi$fecha_localizacion == "nan" ] <- NA

#9. Modificar 0 por NA en CLAVE DE ESTADO DE LOCALIZACIÓN
cenapi$id_edo_localizado[ cenapi$id_edo_localizado == "0" ] <- NA

#10. Modificar 0 por NA en CLAVE DE MUNICIPIO DE LOCALIZACIÓN
cenapi$id_mun_localizado[ cenapi$id_mun_localizado == "0" ] <- NA

#11. Modificr «nan» a «NO ESPECIFICADO» en estado de localización
cenapi$edo_localizado <- gsub("nan", "NO ESPECIFICADO", cenapi$edo_localizado)

#12. Modificar «nan» a «NO ESPECIFICADO» en posible causa de desaparición y estado de localización
cenapi$causa_desap <- gsub("nan", "NO ESPECIFICADO", cenapi$causa_desap)
cenapi$condicion_localizado <- gsub("nan", "NO ESPECIFICADO", cenapi$condicion_localizado)
cenapi$causa_fallecimiento <- gsub("nan", "NO ESPECIFICADO", cenapi$causa_fallecimiento)

#13. Convertir EDAD en número para eliminar «NO ESPECIFICADOS» como en RNPED
cenapi$edad <- as.numeric(cenapi$edad)

#14. Convertir 0 a NA en «EDAD» porque RNPED no tiene ningún registro con 0 edad.
cenapi$edad[ cenapi$edad == "0" ] <- NA

#15. Poner NA en vez de vacío en fecha de avistamiento
cenapi$fecha_avista[ cenapi$fecha_avista == " " ] <- NA

#16. Poner NA en vez de vacío en fecha de hechos
cenapi$fecha_hechos[ cenapi$fecha_hechos == " " ] <- NA


#17. SUSTITUIR LOS SIGUIENTES NOMBRES DE ESTADOS PARA QUE COINCIDAN CON LOS DE LOS CATÁLOGOS DE INEGI.
cenapi$edo <- gsub("ESTADO DE MEXICO", "MEXICO", cenapi$edo)
cenapi$edo <- gsub("CIUDAD DE MEXICO", "DISTRITO FEDERAL", cenapi$edo)
cenapi$edo <- gsub("VERACRUZ", "VERACRUZ DE IGNACIO DE LA LLAVE", cenapi$edo)
cenapi$edo <- gsub("MICHOACAN", "MICHOACAN DE OCAMPO", cenapi$edo)


#CREAR VARIABLE CON CLAVE EDO/MUN EN BASE CENAPI
cenapi$id <- paste(cenapi$id_edo, cenapi$id_mun, sep="")
cenapi$id_localizado <- paste(cenapi$id_edo_localizado, cenapi$id_mun_localizado, sep = "")

#CREAR VARIABLE GPO DE EDAD
cenapi = mutate(cenapi, gpo_edad = (if_else(edad>=60, "mas de 60",
                                    if_else(edad>=55, "55 - 59",
                                    if_else(edad>=50, "50 - 54",
                                    if_else(edad>=45, "45 - 49",
                                    if_else(edad>=40, "40 - 44",
                                    if_else(edad>=35, "35 - 39",
                                    if_else(edad>=30, "30 - 34",
                                    if_else(edad>=25, "25 - 29",
                                    if_else(edad>=18, "18 - 24",
                                    if_else(edad>=10, "10 - 17",
                                    if_else(edad>=6, "6 - 9",
                                    if_else(edad>=0, "0 - 5", "NO ESPECIFICADO"))))))))))))))

#CAMBIAR GÉNERO
cenapi$sexo <- gsub("FEMENINO", "F", cenapi$sexo)
cenapi$sexo <- gsub("MASCULINO", "M", cenapi$sexo)


#SELECCIONAR LAS VARIABLES QUE NECESITAMOS
names(cenapi)
cenapi <- select(cenapi,id, edo, mun, sexo, edad, gpo_edad, fecha_den, fecha_avista,
                 fecha_hechos,estatus,causa_desap,id_edo, id_mun,gpo_edad, nacionalidad, ocupacion, relacion_gdo,
                 fecha_localizacion, condicion_localizado,
                 edo_localizado, id_edo_localizado,
                 mun_localizado, id_mun_localizado, fecha_fallecimiento, causa_fallecimiento)

names(cenapi)

#CREAR UNA VARIABLE CON LA FUENTE DE LOS REGISTROS
cenapi$fuente_c <- "CENAPI"

#CONVERTIR LA BASE EN DATA FRAME
cenapi <- as.data.frame(cenapi)
str(cenapi)

#MODIFICAR EL FORMATO DE LAS FECHAS A CARACTERES
cenapi$fecha_avista <- as.character(cenapi$fecha_avista)
cenapi$fecha_den <- as.character(cenapi$fecha_den)
cenapi$fecha_hechos <- as.character(cenapi$fecha_hechos)
cenapi$fecha_localizacion <- as.character(cenapi$fecha_localizacion)
cenapi$fecha_fallecimiento <- as.character(cenapi$fecha_fallecimiento)

#MODIFICAR FORMATO DE VARIABLES A CARACTERES
cenapi$mun <- as.character(cenapi$mun)
cenapi$estatus <- as.character(cenapi$estatus)
cenapi$causa_desap <- as.character(cenapi$causa_desap)
cenapi$condicion_localizado <- as.character(cenapi$condicion_localizado)
cenapi$edo_localizado <- as.character(cenapi$edo_localizado)
cenapi$mun_localizado <- as.character(cenapi$mun_localizado)
cenapi$causa_fallecimiento <- as.character(cenapi$causa_fallecimiento)

#ELEGIR ÚNICAMENTE LOS CARACTERES EN LAS FECHAS DESDE EL DÍA HASTA EL AÑO, DEJANDO FUERA LA HORA.
cenapi$fecha_avista <- substring(cenapi$fecha_avista, 1, 10)
cenapi$fecha_den <- substring(cenapi$fecha_den, 1, 10)
cenapi$fecha_hechos <- substring(cenapi$fecha_hechos, 1, 10)
cenapi$fecha_localizacion <- substring(cenapi$fecha_localizacion, 1, 10)

#RENOMBRAR LA VARIABLE DE FUENTE COMO FUENTE_C
cenapi <- rename(cenapi, fuente = fuente_c)

# CREAR UNA VARIABLE CON NÚMERO ÚNICO A PARTIR DEL 1 HASTA EL 26,693 PARA CADA REGISTRO
cenapi$cod_c <- seq.int(nrow(cenapi))


#EXPORTAR
#write.csv(cenapi, paste(out, "cenapi_modificado_2.csv", sep="/"), row.names = F, fileEncoding = "UTF-8")


#SOLO SIN LOCALIZAR
cenapi_sl <- cenapi[cenapi$estatus=="AUN SIN LOCALIZAR",]

names(cenapi_sl)
cenapi_sl <- select(cenapi_sl, c(id:fecha_hechos), id_edo, id_mun, fuente, cod_c)



#GUARDAR CENAPI SIN LOCALIZAR
#write.csv(cenapi_sl, paste(out, "cenapi sin localizar_2.csv", sep="/"), row.names = F, fileEncoding = "UTF-8")

#############################
### HACER CÓDIGOS ÚNICOS ##
#############################

#CONVERTIR EN NÚMEROS ID PARA DESCARTAR LOS ID QUE CONTENGAN CARACTERES, ES DECIR, LOS QUE NO CORRESPONDEN
#A ALGUNA ENTIDAD FEDERQATIVA. EL ID PROVIENE DE UN PASTE ENTRE ID EDO Y ID MUN, EN LOS CASOS QUE EL ESTADO
#O EL MUNICIPIO ES «NO ESPECIFICADO» SE COLOCABA AUTOMÁTICAMENTE UN «NA» QUE IMPOSIBILITABA UN JOIN EFECTIVO
cenapi_sl$id <- as.numeric(cenapi_sl$id)
rnped$id <- as.numeric(rnped$id)

cenapi_tempo <- cenapi_sl
#AGREGAR VARIABLE DE AÑOS PARA ELIMINAR FECHAS DE AVISTAMIENTO Y DE HECHOS MENORES A 1905

cenapi_tempo$ano <- substr(cenapi_tempo$fecha_avista, 1, 4)
cenapi_tempo$ano_hechos <- substr(cenapi_tempo$fecha_hechos, 1, 4)

#ELIMINAMOS LAS FECHAS FEAS
cenapi_tempo$ano <- as.numeric(cenapi_tempo$ano)
cenapi_tempo$ano_hechos <- as.numeric(cenapi_tempo$ano_hechos)
cenapi_tempo$fecha_avista[ cenapi_tempo$ano <1906 ] <- NA
cenapi_tempo$fecha_hechos[ cenapi_tempo$ano_hechos <1906 ] <- NA

cenapi_tempo$ano <- NULL
cenapi_tempo$ano_hechos <- NULL


############################
############################
####     
####         MATCH 1:
#### ID+ FECHA AVISTAMIENTO + SEXO + EDAD
#### VUELTA 1
############################
############################


cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(id>0 & fecha_avista != 0  & edad>0,
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_avista, cenapi_tempo$sexo,
                                      cenapi_tempo$edad, sep=""), "NO" ))


#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO Y EDAD
rnped$id <- as.numeric(rnped$id)
rnped$clave_unica = paste(rnped$id, rnped$fecha_avista, rnped$sexo, rnped$edad, sep="")


cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA SE HIZO UN JOINT
cenapi_tempo <- left_join(cenapi_tempo, rnped, by="clave_unica")

#LA BASE CON EL JOIN CUENTA CON 37,441 REGISTROS, ES DECIR 748 REGISTROS MÁS QUE SURGIERON A PARTIR
#DE CONTAR CON CLAVES ÚNICAS REPETIDAS.

#USANDO LA FUNCIÓN DUPLICATED PODEMOS VER QUE EXISTEN 36,693 REGISTROS ÚNICOS DE CENAPI Y JUSTO 748 REPETIDOS
table(duplicated(cenapi_tempo$cod_c))

#USANDO LA FUNCIÓN DUPLICATED PODEMOS VER QUE EXISTEN 25,781 REGISTROS ÚNICOS Y 11,660 REPETIDOS.
table(duplicated(cenapi_tempo$cod_r))

#CREAMOS UNA VARIABLE PARA IDENTIFICAR LOS REGISTROS DUPLICADOS DE LA BASE DE CENAPI A PARTIR DE LA VIARABLE
#«COD_C»
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#NOS QUEDAMOS ÚNICAMENTE CON LOS REGISTROS NO DUPLICADOS CON UN FILTRO
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")

#CREAMOS UNA NUEVA VARIABLE PARA CONTAR CON REGISTROS NO DUPLICADOS DE RNPED, ES DECIR, COD_R.
cenapi_tempo$dup_r <- duplicated(cenapi_tempo$cod_r)

#CREAMOS UNA NUEVA VARIABLE «COD_R_» QUE ÚNICAMENTE TENGA DATOS DE CÓDIGO RNPED CUANDO NO ESTÁN REPETIDOS (TRUE)
cenapi_tempo = mutate(cenapi_tempo, cod_r_ =
                        ifelse(dup_r=="FALSE",cod_r, NA))

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")

#SELECCIONAMOS VARIABLES DE INTERÉS
cenapi_tempo <- select(cenapi_tempo, id.x:fecha_hechos, id_edo.x, id_mun.x, fuente.x, gpo_edad.x, cod_c,
                       clave_unica, fecha_avista.y, cod_r_)

#RENOMBRAR LAS VARIABLES
cenapi_tempo <- rename(cenapi_tempo, edo = edo.x, mun = mun.x, id = id.x, sexo = sexo.x, edad = edad.x,
                       id_edo = id_edo.x, id_mun = id_mun.x, gpo_edad = gpo_edad.x,
                       fecha_avista_rnped = fecha_avista.y, fecha_avista = fecha_avista.x, cod_r=cod_r_,
                       fuente=fuente.x)

#RESULTADOS: REGISTROS QUE HICIERON MATCH: 25,426, REGISTROS QUE NO HICIERON MATCH: 11,267
table(duplicated(cenapi_tempo$cod_r))

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA

#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                            rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)

table(duplicated(cenapi_tempo$cod_r))

###############################
#MATCH 1:
#ID+FECHA AVISTAMIENTO+SEX0+EDAD = MATCH 25,426 | NO MATCH: 11,267 | RNPED 10,840



############################
############################
####     
####         MATCH 2:
#### ID+ FECHA AVISTAMIENTO + SEXO + EDAD
####  REPETIMOS PROCEDIMIENTO POR SI HAY DUPLICADOS
####   EXCLUYENDO A LOS QUE YA HICIERON MATCH
#### 4 VUELTAS
############################
############################


#NUEVAMENTE HACEMOS UN JOIN CON LA FECHA DE AVISTAMIENTO Y DATOS DE ID, SEXO Y EDAD COMPLETOS POR SI EXISTEN
#REGISTROS CON EXACTAMENTE LA MISMA INFORMACIÓN. VERIFICAMOS QUE LA CLAVE ÚNICA PARA CENEPI TEMPO SEA
#SOLO DE LOS REGISTROS QUE NO HAN HECHO MATCH CON RNPED
#PRIMERO SUSTITUIMOS LOS «NA» EN «COD_R» CON LA PALABRA «CENAPI» 
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#MODIFICAMOS LA VARIABLE CLAVE ÚNICA PARA QUE SOLO SE GENERE CUANDO EXISTE «CENAPI» EN COD_R, ES DECIR,
#CON LOS REGISTROS DEL CÓDIGO R QUE NO HAN HECHO «MATCH»
cenapi_tempo <- mutate(cenapi_tempo, clave_unica =
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_hechos != 0 & edad>0,
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_hechos, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                             cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#HACER JOIN CON RNPED
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
#PARA PODER TRASLADAR LOS CÓDIGOS R QUE HICIERON MATCH EN ESTE NUEVO JOIN ES NECESARIO QUE ESTÉN COMO «NA»
#LOS REGISTROS DE COD R (X) QUE NO HICIERON MATCH EN EL ANTERIOR Y QUE AHORA TIENEN «CENAPI», PARA ELLO SE
#CONVIERTE LA VARIABLE COD_R.X EN NUMÉRICA
cenapi_tempo$cod_r.x <- as.numeric(cenapi_tempo$cod_r.x)


#AHORA SÍ SUSTITUIMOS LOS «NA» EN COD_R.X POR LOS DATOS QUE HICIERON «MATCH» EN ESTA VUELTA Y QUE ESTÁN
#EN COD_R.Y
cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)
cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#CREAMOS UNA NUEVA VARIABLE PARA IDENTIFICAR LOS REGISTROS DEL CÓDIGO CENAPI (COD_C) DUPLICADOS Y POSTERIORMENTE
#ELIMINARLOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
cenapi_tempo <- filter(cenapi_tempo, dup== "FALSE")

cenapi_tempo<- select(cenapi_tempo, id.x, edo.x:fecha_avista_rnped, cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

table(duplicated(cenapi_tempo$cod_r))

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA

#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")


#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))

###############################
#MATCH 2:
#ID+FECHA AVISTAMIENTO+SEX0+EDAD = MATCH 32,108 | NO MATCH: 4,585 | RNPED 4,158



############################
############################
####     
####         MATCH 4:
#### ID+ FECHA HECHOS + SEXO + EDAD
#### 1 VUELTA
############################
############################

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_hechos != 0 & edad>0,
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_hechos, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo$clave_unica <- paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, rnped_tempo$edad, sep="")

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)


#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA



#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)

table(duplicated(cenapi_tempo$cod_r))

############################
#MATCH 4:
####ID+FECHA HECHOS+SEX0+EDAD = MATCH: 32,183 | NO MATCH: 4,510 | RNPED: 4,083


############################
############################
####     
####         MATCH 6:
#### ID+ FECHA DENUNCIA + SEXO + EDAD
####  1 VUELTA
############################
############################


#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_den != 0 & edad>0,
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_den, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo$clave_unica <- paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, rnped_tempo$edad, sep="")

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA



#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 6: ID+FECHA DENUNCIA+SEX0+EDAD = MATCH: 32,192 | NO MATCH: 4,501 | RNPED: 4,074



############################
############################
####         MATCH 7:
#### ID+ FECHA AVISTAMIENTO + SEXO  <- (SIN EDAD)
#### SOLO REGISTROS QUE NO CONTABAN CON INFORMACIÓN SOBRE EDAD
#### 1 VUELTA
############################
############################

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR Y SOLO REGISTROS SIN EDAD
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_avista != 0 & is.na(edad),
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_avista, cenapi_tempo$sexo, sep=""), "ERROR" ))

cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                     ifelse(id>0 & fecha_avista != 0 & is.na(edad),
                            paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "NO"))

###NO CONSIDERAR LOS NA
cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                cenapi_tempo$clave_unica,cenapi_tempo$fuente)

cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")


##SABER CUÁNTOS HICIERON MATCH
#CREAR VARIABLE PARA IDENTIFICAR LOS REGISTROS QUE HICIERON MATCH
cenapi_tempo <- mutate(cenapi_tempo, match =
                        ifelse(cod_r.x == "CENAPI" & cod_r.y == "RNPED", "match", "no match"))

cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")

cenapi_tempo <- select(cenapi_tempo, id.x:cod_r.x)

cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)


#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 6: ID+FECHA AVISTA+SEX0 = 0


############################
############################
####     
####         MATCH 8:
#### ID + FECHA HECHOS + SEXO <- SIN EDAD
#### 11 VUELTA 
#### 
############################
############################


#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_hechos != 0 & is.na(edad),
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_hechos, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista != 0 & is.na(edad),
                               paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))


cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA


#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 34,495 | NO MATCH: 2,198 | RNPED: 1,085 


############################
############################
####     
####         MATCH 9:
#### ID + FECHA DENUNCIA + SEXO <- SIN EDAD
#### VUELTA I
############################
############################


#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_den != 0 & is.na(edad),
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_den, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista != 0 & is.na(edad),
                               paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)



#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA


#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 9: ID+FECHA DENINCIA +SEX0 <- SIN EDAD = MATCH: 0 


############################
############################
####     
####         MATCH 10:
#### ID_EDO + FECHA AVISTA + SEXO + EDAD <- SIN MUNICIPIO
#### 2 VUELTAS
#### AQUÍ SOLO SE HARÁN CLAVES UNICAS DE LOS REGISTROS QUE NO CUENTEN CON DATOS DE MUNICIPIO
############################
############################

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id_edo>0 & fecha_avista != 0 & edad>0 & is.na(id_mun),
                                paste(cenapi_tempo$id_edo, cenapi_tempo$fecha_avista, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & fecha_avista != 0 & edad>0 & is.na(id_mun),
                               paste(rnped_tempo$id_edo, rnped_tempo$fecha_avista, rnped_tempo$sexo, rnped_tempo$edad, sep=""), "ERROR"))

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA


#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 10: ID_EDO +FECHA AVISTA +SEX0 + EDAD <- SIN MUNICIPIO = MATCH: 35,228 | NO MATCH: 1,465 | RNPED: 1,038

############################
############################
####     
####         MATCH 11:
#### ID_EDO + FECHA HECHOS + SEXO + EDAD <- SIN MUNICIPIOS
#### 1 VUELTA
#### AQUÍ SOLO SE HARÁN CLAVES UNICAS DE LOS REGISTROS QUE NO CUENTEN CON DATOS DE MUNICIPIO
############################
############################

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id_edo>0 & fecha_hechos != 0 & edad>0 & is.na(id_mun),
                                paste(cenapi_tempo$id_edo, cenapi_tempo$fecha_hechos, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & fecha_avista != 0 & edad>0 & is.na(id_mun),
                               paste(rnped_tempo$id_edo, rnped_tempo$fecha_avista, rnped_tempo$sexo, rnped_tempo$edad, sep=""), "ERROR"))

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA


#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 11: ID_EDO +FECHA HECHOS +SEX0 + EDAD <- SIN MUNICIPIO = MATCH: 35,333 | NO MATCH: 1,360 | RNPED: 933

############################
############################
####     
####         MATCH 12:
#### ID_EDO + FECHA DENUNCIA + SEXO + EDAD <- SIN MUNICIPIOS
#### 1 VUELTA
#### AQUÍ SOLO SE HARÁN CLAVES UNICAS DE LOS REGISTROS QUE NO CUENTEN CON DATOS DE MUNICIPIO
############################
############################

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id_edo>0 & fecha_den != 0 & edad>0 & is.na(id_mun),
                                paste(cenapi_tempo$id_edo, cenapi_tempo$fecha_den, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & fecha_avista != 0 & edad>0 & is.na(id_mun),
                               paste(rnped_tempo$id_edo, rnped_tempo$fecha_avista, rnped_tempo$sexo, rnped_tempo$edad, sep=""), "ERROR"))


cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA


#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 12: ID_EDO +FECHA AVISTA +SEX0 + EDAD <- SIN MUNICIPIO =  0 MATCH: 35,328 | NO MATCH: 1,365 | RNPED: 938


############################
############################
####     
####         MATCH 13:
#### ID + SEXO + EDAD <- SIN FECHA DE AVISTAMIENTO
#### 3 VUELTAS
#### AQUÍ SOLO SE HARÁN CLAVES UNICAS DE LOS REGISTROS QUE NO CUENTEN CON DATOS DE FECHA
############################
############################




#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & edad>0 & is.na(fecha_avista),
                                paste(cenapi_tempo$id, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & edad>0 & is.na(fecha_avista),
                               paste(rnped_tempo$id, rnped_tempo$sexo, rnped_tempo$edad, sep=""), "ERROR"))


cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA


#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 10: ID_EDO +FECHA AVISTA +SEX0 + EDAD <- SIN MUNICIPIO = MATCH: 35,433 | NO MATCH: 1,260 | RNPED: 838


############################
############################
####     
####         MATCH 14:
#### ID + SEXO + EDAD <- SIN FECHA DE HECHOS
#### 9 VUELTAS
#### AQUÍ SOLO SE HARÁN CLAVES UNICAS DE LOS REGISTROS QUE NO CUENTEN CON DATOS DE FECHA
############################
############################

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & edad>0 & is.na(fecha_hechos),
                                paste(cenapi_tempo$id, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & edad>0 & is.na(fecha_avista),
                               paste(rnped_tempo$id, rnped_tempo$sexo, rnped_tempo$edad, sep=""), "ERROR"))

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA


#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 14: ID_EDO +FECHA HECHOS +SEX0 + EDAD <- SIN MUNICIPIO = MATCH: 35,521 | NO MATCH: 1,172 | RNPED: 745


############################
############################
####     
####         MATCH 15:
#### ID + SEXO + EDAD <- SIN FECHA DE DENUNCIA
#### 1 VUELTA
#### AQUÍ SOLO SE HARÁN CLAVES UNICAS DE LOS REGISTROS QUE NO CUENTEN CON DATOS DE FECHA
############################
############################

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & edad>0 & is.na(fecha_den),
                                paste(cenapi_tempo$id, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0  & edad>0 & is.na(fecha_avista),
                               paste(rnped_tempo$id, rnped_tempo$sexo, rnped_tempo$edad, sep=""), "ERROR"))


cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE")


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA


#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 15: 0


############################
############################
####     
#### QUITAR REGISTROS DE PERSONAS LOCALIZADAS CON VIDA
#### CLAVE UNICA HECHA CON FECHA DE AVISTAMIENTO
#### 
############################
############################


rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista>0,
                               paste(rnped_tempo$id,rnped_tempo$fecha_avista, rnped_tempo$sexo, rnped_tempo$edad, sep=""), "ERROR"))

cenapi <- mutate(cenapi, clave_unica =
                   ifelse(estatus != "AUN SIN LOCALIZAR",
                          paste(cenapi$id, cenapi$fecha_avista, cenapi$sexo, cenapi$edad, sep = ""), "ERROR"))

rnped_tempo <- left_join(rnped_tempo, cenapi, by ="clave_unica")

rnped_tempo <- select(rnped_tempo, id.x:clave_unica, id.y,estatus, cod_c)
rnped_tempo$dup <- duplicated(rnped_tempo$cod_r)
rnped_tempo <- filter(rnped_tempo, dup=="FALSE")

rnped_tempo$dup <- duplicated(rnped_tempo$cod_c)
rnped_tempo$cod_c[rnped_tempo$dup == "TRUE"] = NA

table(rnped_tempo$estatus)
#### 11 muertos, 49 vivos, es decir, 60 menos por hacer match. TOTAL: 567

rnped_tempo <- select(rnped_tempo, id.x:clave_unica, estatus, cod_c)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      fuente= fuente.x)

rnped_tempo$cod_c[rnped_tempo$cod_r == 34826] = 88248
rnped_tempo$cod_c[rnped_tempo$cod_r == 35317] = 98812

rnped_tempo$estatus <- ifelse(!is.na(rnped_tempo$estatus),
                               rnped_tempo$estatus,rnped_tempo$fuente)


rnped_localizados <- filter(rnped_tempo, estatus == "VIVO" | estatus== "MUERTO")
rnped_tempo <- filter(rnped_tempo, estatus == "RNPED")
rnped_tempo <- select(rnped_tempo, id:clave_unica)


############################
############################
####     
#### QUITAR REGISTROS DE PERSONAS LOCALIZADAS CON VIDA
#### CLAVE UNICA HECHA CON FECHA DE HECHOS
#### 
############################
############################


rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista>0,
                               paste(rnped_tempo$id,rnped_tempo$fecha_avista, rnped_tempo$sexo, rnped_tempo$edad, sep=""), "ERROR"))

cenapi <- mutate(cenapi, clave_unica =
                   ifelse(estatus != "AUN SIN LOCALIZAR",
                          paste(cenapi$id, cenapi$fecha_hechos, cenapi$sexo, cenapi$edad, sep = ""), "ERROR"))

rnped_tempo <- left_join(rnped_tempo, cenapi, by ="clave_unica")

rnped_tempo <- select(rnped_tempo, id.x:clave_unica, id.y,estatus, cod_c)
rnped_tempo$dup <- duplicated(rnped_tempo$cod_r)
rnped_tempo <- filter(rnped_tempo, dup=="FALSE")

rnped_tempo$dup <- duplicated(rnped_tempo$cod_c)
rnped_tempo$cod_c[rnped_tempo$dup == "TRUE"] = NA

table(rnped_tempo$estatus)
#### 11 muertos, 49 vivos, es decir, 60 menos por hacer match. TOTAL: 567

rnped_tempo <- select(rnped_tempo, id.x:clave_unica, estatus, cod_c)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      fuente= fuente.x)

rnped_tempo$estatus <- ifelse(!is.na(rnped_tempo$estatus),
                              rnped_tempo$estatus,rnped_tempo$fuente)


rnped_loca_t <- filter(rnped_tempo, estatus == "VIVO" | estatus== "MUERTO")
rnped_tempo <- filter(rnped_tempo, estatus == "RNPED")
rnped_tempo <- select(rnped_tempo, id:clave_unica)

rnped_localizados <- bind_rows(rnped_localizados, rnped_loca_t)
rnped_loca_t <- NULL


##########################################
##########################################
###### CENAPI EDAD, RNPED NO EDAD
###### FECHA AVISTAMIENTO


#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_avista != 0 & edad>0,
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_avista, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista != 0 & is.na(edad),
                               paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"
  
rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
##########################################
###### CENAPI EDAD, RNPED NO EDAD
###### FECHA HECHOS


#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_hechos != 0 & edad>0,
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_hechos, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista != 0 & is.na(edad),
                               paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
##########################################
###### CENAPI EDAD, RNPED NO EDAD
###### FECHA DENUNCIA


#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_den != 0 & edad>0,
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_den, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista != 0 & is.na(edad),
                               paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS


#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0

##########################################
##########################################
###### CENAPI NO EDAD, RNPED SÍ
###### FECHA AVISTAMIENTO

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_avista != 0 & is.na(edad),
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_avista, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista != 0 & edad>0,
                               paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0

##########################################
##########################################
###### CENAPI NO EDAD, RNPED SÍ
###### FECHA HECHOS

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_hechos != 0 & is.na(edad),
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_hechos, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista != 0 & edad>0,
                               paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
##########################################
###### CENAPI NO EDAD, RNPED SÍ
###### FECHA DENUNCIA

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_den != 0 & is.na(edad),
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_den, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista != 0 & edad>0,
                               paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0



##########################################
##########################################
###### CENAPI NO EDAD, RNPED NO EDAD
###### FECHA AVISTA


#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_avista != 0,
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_avista, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista != 0,
                               paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad <- cenapi_tempo$edad.x - cenapi_tempo$edad.y

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
##########################################
###### CENAPI NO EDAD, RNPED NO EDAD
###### FECHA HECHOS


#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_hechos != 0,
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_hechos, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista != 0,
                               paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
##########################################
###### CENAPI NO EDAD, RNPED NO EDAD
###### FECHA DENUNCIA


#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI" &  id>0 & fecha_den != 0,
                                paste(cenapi_tempo$id, cenapi_tempo$fecha_den, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & fecha_avista != 0,
                               paste(rnped_tempo$id, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
###### EDO NO ESPECIFICADO + MUN NO ESPECIFICADO + FECHA AVISTAMIENTO + SEXO + EDAD
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& edo =="NO ESPECIFICADO" &  mun == "NO ESPECIFICADO" & fecha_avista != 0 & edad>0,
                                paste( cenapi_tempo$fecha_avista, cenapi_tempo$sexo,cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(edo == "NO ESPECIFICADO" & mun == "NO ESPECIFICADO" & fecha_avista != 0 & edad>0,
                               paste(rnped_tempo$fecha_avista, rnped_tempo$sexo,rnped_tempo$edad,  sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
###### EDO NO ESPECIFICADO + MUN NO ESPECIFICADO + FECHA HECHOS + SEXO + EDAD
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& edo =="NO ESPECIFICADO" &  mun == "NO ESPECIFICADO" & fecha_hechos != 0 & edad>0,
                                paste( cenapi_tempo$fecha_hechos, cenapi_tempo$sexo,cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(edo == "NO ESPECIFICADO" & mun == "NO ESPECIFICADO" & fecha_avista != 0 & edad>0,
                               paste(rnped_tempo$fecha_avista, rnped_tempo$sexo,rnped_tempo$edad,  sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0

##########################################
######  
###### EDO NO ESPECIFICADO + MUN NO ESPECIFICADO + FECHA DENUNCIA + SEXO + EDAD
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& edo =="NO ESPECIFICADO" &  mun == "NO ESPECIFICADO" & fecha_den != 0 & edad>0,
                                paste( cenapi_tempo$fecha_den, cenapi_tempo$sexo,cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(edo == "NO ESPECIFICADO" & mun == "NO ESPECIFICADO" & fecha_avista != 0 & edad>0,
                               paste(rnped_tempo$fecha_avista, rnped_tempo$sexo,rnped_tempo$edad,  sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
######  EDO NO ESPECIFICADO + MUN NO ESPECIFICADO+  FECHA AVISTA + SEXO <- SIN EDAD
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& edo =="NO ESPECIFICADO" &  mun == "NO ESPECIFICADO" & fecha_avista != 0 ,
                                paste( cenapi_tempo$fecha_avista, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(edo == "NO ESPECIFICADO" & mun == "NO ESPECIFICADO" & fecha_avista != 0 ,
                               paste(rnped_tempo$fecha_avista, rnped_tempo$sexo,  sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
######  EDO NO ESPECIFICADO + MUN NO ESPECIFICADO+  FECHA HECHOS + SEXO <- SIN EDAD
###### 


#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& edo =="NO ESPECIFICADO" &  mun == "NO ESPECIFICADO" & fecha_hechos != 0 ,
                                paste( cenapi_tempo$fecha_hechos, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(edo == "NO ESPECIFICADO" & mun == "NO ESPECIFICADO" & fecha_avista != 0 ,
                               paste(rnped_tempo$fecha_avista, rnped_tempo$sexo,  sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0

##########################################
######  
######  EDO NO ESPECIFICADO + MUN NO ESPECIFICADO+  FECHA DENUNCIA + SEXO <- SIN EDAD
###### 


#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& edo =="NO ESPECIFICADO" &  mun == "NO ESPECIFICADO" & fecha_den != 0 ,
                                paste( cenapi_tempo$fecha_den, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(edo == "NO ESPECIFICADO" & mun == "NO ESPECIFICADO" & fecha_avista != 0 ,
                               paste(rnped_tempo$fecha_avista, rnped_tempo$sexo,  sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0

##########################################
######  
######  EDO + MUN NO ESPECIFICADO + FECHA AVISTA + SEXO  + EDAD
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id_edo>0 &  mun == "NO ESPECIFICADO" & fecha_avista != 0 & edad>0,
                                paste( cenapi_tempo$id_edo, cenapi_tempo$fecha_avista, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & mun == "NO ESPECIFICADO" & fecha_avista != 0 & edad>0,
                               paste(rnped_tempo$id_edo, rnped_tempo$fecha_avista, rnped_tempo$sexo,rnped_tempo$edad,  sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
######  EDO + MUN NO ESPECIFICADO + FECHA HECHOS + SEXO  + EDAD
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id_edo>0 &  mun == "NO ESPECIFICADO" & fecha_hechos != 0 & edad>0,
                                paste( cenapi_tempo$id_edo, cenapi_tempo$fecha_hechos, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & mun == "NO ESPECIFICADO" & fecha_avista != 0 & edad>0,
                               paste(rnped_tempo$id_edo, rnped_tempo$fecha_avista, rnped_tempo$sexo,rnped_tempo$edad,  sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
######  EDO + MUN NO ESPECIFICADO + FECHA DENUNCIA + SEXO  + EDAD
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id_edo>0 &  mun == "NO ESPECIFICADO" & fecha_den != 0 & edad>0,
                                paste( cenapi_tempo$id_edo, cenapi_tempo$fecha_den, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & mun == "NO ESPECIFICADO" & fecha_avista != 0 & edad>0,
                               paste(rnped_tempo$id_edo, rnped_tempo$fecha_avista, rnped_tempo$sexo,rnped_tempo$edad,  sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0

##########################################
######  
######  EDO + MUN NO ESPECIFICADO + FECHA AVISTA + SEXO   <- EDAD = NA
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id_edo>0 &  mun == "NO ESPECIFICADO" & fecha_avista != 0 & is.na(edad),
                                paste( cenapi_tempo$id_edo, cenapi_tempo$fecha_avista, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & mun == "NO ESPECIFICADO" & fecha_avista != 0 & is.na(edad),
                               paste(rnped_tempo$id_edo, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0




##########################################
######  
######  EDO + MUN NO ESPECIFICADO + FECHA HECHOS + SEXO   <- EDAD = NA
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id_edo>0 &  mun == "NO ESPECIFICADO" & fecha_hechos != 0 & is.na(edad),
                                paste( cenapi_tempo$id_edo, cenapi_tempo$fecha_hechos, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & mun == "NO ESPECIFICADO" & fecha_avista != 0 & is.na(edad),
                               paste(rnped_tempo$id_edo, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
######  EDO + MUN NO ESPECIFICADO + FECHA DENUNCIA + SEXO  <- EDAD = NA
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id_edo>0 &  mun == "NO ESPECIFICADO" & fecha_den != 0 & is.na(edad),
                                paste( cenapi_tempo$id_edo, cenapi_tempo$fecha_den, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & mun == "NO ESPECIFICADO" & fecha_avista != 0 & is.na(edad),
                               paste(rnped_tempo$id_edo, rnped_tempo$fecha_avista, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
######  EDO = NA + MUN NO ESPECIFICADO + FECHA AVISTA + SEXO  + EDAD = NA
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& is.na(id_edo) &  mun == "NO ESPECIFICADO" & fecha_avista != 0 & edad>0,
                                paste(cenapi_tempo$fecha_avista, cenapi_tempo$sexo,cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(is.na(id_edo) & mun == "NO ESPECIFICADO" & fecha_avista != 0 & edad>0,
                               paste(rnped_tempo$fecha_avista, rnped_tempo$sexo,rnped_tempo$edad, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0

##########################################
######  
######  EDO = NA + MUN NO ESPECIFICADO + FECHA HECHOS + SEXO  + EDAD = NA
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& is.na(id_edo) &  mun == "NO ESPECIFICADO" & fecha_hechos != 0 & edad>0,
                                paste(cenapi_tempo$fecha_hechos, cenapi_tempo$sexo,cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(is.na(id_edo) & mun == "NO ESPECIFICADO" & fecha_avista != 0 & edad>0,
                               paste(rnped_tempo$fecha_avista, rnped_tempo$sexo,rnped_tempo$edad, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0

##########################################
######  
######  EDO + MUN NO ESPECIFICADO + FECHA AVISTA (CENAPI SÍ, RNPED = NA) + SEXO  + EDAD 
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& is.na(id_edo) &  mun == "NO ESPECIFICADO" & fecha_den != 0 & edad>0,
                                paste(cenapi_tempo$fecha_den, cenapi_tempo$sexo,cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(is.na(id_edo) & mun == "NO ESPECIFICADO" & fecha_avista != 0 & edad>0,
                               paste(rnped_tempo$fecha_avista, rnped_tempo$sexo,rnped_tempo$edad, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0



##########################################
######  
######  EDO + MUN NO ESPECIFICADO + FECHA HECHOS (CENAPI SÍ, RNPED = NA) + SEXO  + EDAD 
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id_edo>0 &  fecha_hechos>0 &mun == "NO ESPECIFICADO" & edad>0,
                                paste(cenapi_tempo$id_edo, cenapi_tempo$sexo, cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & mun == "NO ESPECIFICADO" & is.na(fecha_avista) & edad>0,
                               paste(rnped_tempo$id_edo, rnped_tempo$sexo,rnped_tempo$edad, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0

##########################################
######  
######  EDO + MUN NO ESPECIFICADO + FECHA AVISTA=NA + SEXO  + EDAD
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id_edo>0 &mun == "NO ESPECIFICADO" & is.na(fecha_avista) & edad>0,
                                paste(cenapi_tempo$id_edo, cenapi_tempo$sexo,cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & mun == "NO ESPECIFICADO" & is.na(fecha_avista) & edad>0,
                               paste(rnped_tempo$id_edo, rnped_tempo$sexo,rnped_tempo$edad, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0

##########################################
######  
######  EDO + MUN NO ESPECIFICADO + FECHA HECHOS=NA + SEXO  + EDAD
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id_edo>0 &mun == "NO ESPECIFICADO" & is.na(fecha_hechos) & edad>0,
                                paste(cenapi_tempo$id_edo, cenapi_tempo$sexo,cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & mun == "NO ESPECIFICADO" & is.na(fecha_avista) & edad>0,
                               paste(rnped_tempo$id_edo, rnped_tempo$sexo,rnped_tempo$edad, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
######  EDO + MUN NO ESPECIFICADO  + SEXO <- AVISTA Y EDAD = NA
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id_edo>0 &mun == "NO ESPECIFICADO" & is.na(fecha_avista) & is.na(edad),
                                paste(cenapi_tempo$id_edo, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & mun == "NO ESPECIFICADO" & is.na(fecha_avista) & is.na(edad),
                               paste(rnped_tempo$id_edo, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0

##########################################
######  
######  EDO + MUN NO ESPECIFICADO  + SEXO <- AVISTA Y EDAD = NA
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id_edo>0 &mun == "NO ESPECIFICADO" & is.na(fecha_avista) & is.na(edad),
                                paste(cenapi_tempo$id_edo, cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & mun == "NO ESPECIFICADO" & is.na(fecha_avista) & is.na(edad),
                               paste(rnped_tempo$id_edo, rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0





##########################################
######  
######  ID + SIN FECHA AVISTA EN RNPED  + SEXO Y EDAD
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id>0 & fecha_avista>0 & edad>0,
                                paste(cenapi_tempo$id, cenapi_tempo$sexo,cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & is.na(fecha_avista) & edad>0,
                               paste(rnped_tempo$id, rnped_tempo$sexo,rnped_tempo$edad, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0

##########################################
######  
######  ID + SIN FECHA AVISTA EN RNPED  + SEXO Y EDAD
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id>0 & fecha_avista>0 & edad>0,
                                paste(cenapi_tempo$id, cenapi_tempo$sexo,cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & is.na(fecha_avista) & edad>0,
                               paste(rnped_tempo$id, rnped_tempo$sexo,rnped_tempo$edad, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
######  ID EDO + MUN = NO ESPECIFICADO  + SEXO  <- EDAD Y FECHA AVISTA = NA EN RNPED
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& mun == "NO ESPECIFICADO" & id_edo>0,
                                paste(cenapi_tempo$id_edo,cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id_edo>0 & mun == "NO ESPECIFICADO" & is.na(fecha_avista) & is.na(edad),
                               paste(rnped_tempo$id_edo,rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0



##########################################
######  
###### EDO=  NO ESPECIFICADO + MUN = NO ESPECIFICADO  + SEXO  + EDAD 
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& edo == "NO ESPECIFICADO" & mun == "NO ESPECIFICADO" & edad>0,
                                paste(cenapi_tempo$sexo,cenapi_tempo$edad, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(edo == "NO ESPECIFICADO" & mun == "NO ESPECIFICADO" & edad>0,
                               paste(rnped_tempo$sexo,rnped_tempo$edad, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
###### ID   + SEXO  + EDAD <- SIN DATOS DE FECHA EN AMBAS BASES
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id>0 & is.na(fecha_avista) & is.na(edad),
                                paste(cenapi_tempo$id,cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & is.na(fecha_avista) & is.na(edad),
                               paste(rnped_tempo$id,rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0




##########################################
######  
###### ID   + SEXO  + FECHA AVISTA EN CENAPI Y NO EN RNPED <- SIN DATOS DE EDAD EN AMBAS BASES
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id>0 & fecha_avista>0 & is.na(edad),
                                paste(cenapi_tempo$id,cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & is.na(fecha_avista) & is.na(edad),
                               paste(rnped_tempo$id,rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0




##########################################
######  
###### ID   + SEXO  + FECHA AVISTA EN CENAPI Y NO EN RNPED <- SIN DATOS DE EDAD EN AMBAS BASES
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& id>0 & fecha_avista>0,
                                paste(cenapi_tempo$id,cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(id>0 & is.na(fecha_avista) & is.na(edad),
                               paste(rnped_tempo$id,rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
###### EDO NO ESPECIFICADO  + MUN NO ESPECIFICADO + SEXO  
###### 

#SE AGREGÓ FUENTE «CENAPI» A COD_R PARA PODER CREAR LA CLAVE SIN CONSIDERAR LOS REGISTROS QUE YA HICIERON
#MATCH
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)
cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)

#SE PUSO QUE LA FECHA DE AVISTAMIENTO NO SEA IGUAL A 1900-01-01 PORQUE CORRESPONDE A UN ERROR
cenapi_tempo <- mutate(cenapi_tempo, clave_unica=
                         ifelse(cod_r =="CENAPI"& edo == "NO ESPECIFICADO" & mun== "NO ESPECIFICADO",
                                paste(cenapi_tempo$sexo, sep=""), "NO" ))

#REGRESAR COD_R A NUMÉRICO PARA ELIMINAR CENAPI
cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#SE CREÓ UN CLAVE ÚNICA PARA EL RNPED TEMPO CON DATOS DE ID, FECHA DE AVISTAMIENTO, SEXO
rnped_tempo <- mutate(rnped_tempo, clave_unica = 
                        ifelse(cod_r =="CENAPI"& edo == "NO ESPECIFICADO" & mun== "NO ESPECIFICADO",
                               paste(rnped_tempo$sexo, sep=""), "ERROR"))

rnped_tempo$dup <- duplicated(rnped_tempo$clave_unica)
rnped_tempo$clave_unica[rnped_tempo$dup == "TRUE"] = "ERROR"

rnped_tempo$clave_unica <- ifelse(!is.na(rnped_tempo$clave_unica),
                                  rnped_tempo$clave_unica,rnped_tempo$fuente)

cenapi_tempo$clave_unica <- ifelse(!is.na(cenapi_tempo$clave_unica),
                                   cenapi_tempo$clave_unica,cenapi_tempo$fuente)


#UNA VEZ QUE AMBAS BASES TIENEN CLAVE ÚNICA HACEMOS EL JOIN
cenapi_tempo <- left_join(cenapi_tempo, rnped_tempo, by="clave_unica")
cenapi_tempo$dif_edad_tempo <- cenapi_tempo$edad.x - cenapi_tempo$edad.y
cenapi_tempo$dif_edad <- ifelse(!is.na(cenapi_tempo$dif_edad),
                                cenapi_tempo$dif_edad,cenapi_tempo$dif_edad_tempo)

#SUSTITUIMOS LOS VALORES «NA» EN COD_R.X CON LOS VALORES DE CÓDIGO RNPED (COD_R.Y) QUE HICIERON «MATCH»
#TAMBIÉN LOS DE FECHA DE AVISTAMIENTO

cenapi_tempo$cod_r.x <- ifelse(!is.na(cenapi_tempo$cod_r.x),
                               cenapi_tempo$cod_r.x,cenapi_tempo$cod_r.y)

cenapi_tempo$fecha_avista_rnped <- ifelse(!is.na(cenapi_tempo$fecha_avista_rnped),
                                          cenapi_tempo$fecha_avista_rnped,cenapi_tempo$fecha_avista.y)

#FILTRAMOS LA BASE ÚNICAMENTE CON LOS REGISTROS DE CENAPI QUE NO ESTÁN REPETIDOS
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_c)
#cenapi_tempo <- filter(cenapi_tempo, dup == "FALSE") <- NO HAY DUPLICADOS

#SELECCIONAR VARIABLES
cenapi_tempo<- select(cenapi_tempo, id.x:cod_r.x, dif_edad)
cenapi_tempo <- rename(cenapi_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                       fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, fuente =fuente.x,
                       cod_r=cod_r.x, gpo_edad=gpo_edad.x)

#ELIMINAR LOS REGISTROS DUPLICADOS DE COD_R
cenapi_tempo$dup <- duplicated(cenapi_tempo$cod_r)
cenapi_tempo$cod_r[cenapi_tempo$dup == "TRUE"] = NA
cenapi_tempo$dup <- NULL

cenapi_tempo$cod_r <- ifelse(!is.na(cenapi_tempo$cod_r),
                             cenapi_tempo$cod_r,cenapi_tempo$fuente)
cenapi_tempo$cod_r <- as.character(cenapi_tempo$cod_r)
rnped_tempo$cod_r <- as.character(rnped_tempo$cod_r)
#PARA ELIMINAR LOS REGISTROS DE RNPED QUE YA HICIERON MATCH CON CENAPI, HACEMOS UN JOIN A PARTIR DE LA
#VARIABLE COD_R.
rnped_tempo <- left_join(rnped_tempo, cenapi_tempo, by="cod_r")

#SUSTITUIT LOS «NA» EN MATCH CON RNPED EN VARIABLE «FUENTE»
rnped_tempo$fuente.y <- ifelse(!is.na(rnped_tempo$fuente.y),
                               rnped_tempo$fuente.y,rnped_tempo$fuente.x)

#FILTAR LOS DATOS ÚNICAMENTE QUE SON «RNPED» EN LA VARIABLE «COD_R». LOS OTROS DATOS SON LOS QUE HICIERON
#MATCH EN CENAPI ASÍ QUE ES NECESARIO ELIMINARLOS.
rnped_tempo <- filter(rnped_tempo, fuente.y == "RNPED")

#SELECCIONAR VARIABLES PARA RNPED_TEMPO
rnped_tempo <- select(rnped_tempo, id.x:clave_unica.x)
rnped_tempo <- rename(rnped_tempo, id=id.x, id_edo=id_edo.x, id_mun=id_mun.x, edo=edo.x, mun=mun.x,
                      fecha_avista=fecha_avista.x, sexo=sexo.x, edad=edad.x, gpo_edad =gpo_edad.x,
                      clave_unica=clave_unica.x, fuente= fuente.x)


table(duplicated(cenapi_tempo$cod_r))
#MATCH 8: ID+FECHA HECHOS +SEX0 <- SIN EDAD = MATCH: 0


##########################################
######  
###### MANUAL
###### SE CORROBORÓ QUE NO EXISTA UN REGISTRO CON CARACTERÍSTICAS SIMILARES Y SIN HABER HECHO «MATCH» EN CADA UNO DE LOS 41 CASOS
###### VER METODOLOGÍA

#HACER UNA COLUMNA DE CONTROL
rnped_tempo$match_manual <- NA

cenapi_tempo$cod_r <- as.numeric(cenapi_tempo$cod_r)

#CHIAPAS - 6317
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 52847] = 6317
rnped_tempo$match_manual[rnped_tempo$cod_r == 6317] = "match manual"

#CHIHUAHUA JUÁREZ - 8275
rnped_tempo$match_manual[rnped_tempo$cod_r == 8275] = "sin match"

#CHIHUAHUA JUÁREZ - 16236
rnped_tempo$match_manual[rnped_tempo$cod_r == 16236] = "sin match"

#CHIHUAHUA JUÁREZ - 16245
rnped_tempo$match_manual[rnped_tempo$cod_r == 16245] = "sin match"

#CHIHUAHUA JUÁREZ - 28050
rnped_tempo$match_manual[rnped_tempo$cod_r == 28050] = "sin match"

#CHIHUAHUA URUACHI - 28620 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, FECHA, SEXO Y EDAD
# Y QUE NO HA HECHO MATCH ES UNO CORRESPONDIENTE AL MUNICIPIO DE CHIHHUAHUA
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 84742] = 28620
rnped_tempo$match_manual[rnped_tempo$cod_r == 28620] = "match manual"

#COAHUILA SALTILLO - 10349
rnped_tempo$match_manual[rnped_tempo$cod_r == 10349] = "sin match"

#COAHUILA PIEDRAS NEGRAS - 10605 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, FECHA, SEXO Y EDAD
# Y QUE NO HA HECHO MATCH ES UNO CORRESPONDIENTE AL MUNICIPIO DE ALLENDE
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 91709] = 10605
rnped_tempo$match_manual[rnped_tempo$cod_r == 10605] = "match manual"

#COAHUILA TORREÓN - 10750
rnped_tempo$match_manual[rnped_tempo$cod_r == 10750] = "sin match"

#COAHUILA ALLENDE - 10929
rnped_tempo$match_manual[rnped_tempo$cod_r == 10929] = "sin match"

#COAHUILA TORREÓN - 25340 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, MUN, FECHA Y EDAD
# Y QUE NO HA HECHO MATCH ES UNO CORRESPONDIENTE A UNA PERSONA DE SEXO FEMENINO
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 73957] = 25340
rnped_tempo$match_manual[rnped_tempo$cod_r == 25340] = "match manual"

#COAHUILA NO ESPECIFICADO - 25341 [MUNICIPIO EN RNPED ES «TORREÓN»]
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 87351] = 25341
rnped_tempo$match_manual[rnped_tempo$cod_r == 25341] = "match manual"

#DF NO ESPECIFICADO - 30797 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, EN FECHA DE HECHOS Y DENUNCIA, EN EDAD = NA
# ES EL 80443
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 80443] = 30797
rnped_tempo$match_manual[rnped_tempo$cod_r == 30797] = "match manual"

#GUERRERO NO ESPECIFICADO - 1837
rnped_tempo$match_manual[rnped_tempo$cod_r == 1837] = "sin match"

#HIDALGO PACHUCA DE SOTO - 2894 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, FECHA AVISTA SEXO Y EDAD
# Y QUE NO HA HECHO MATCH ES UNO CORRESPONDIENTE A MUNICIPIO DE MINERAL DE LA REFORMA
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 6255] = 2894
rnped_tempo$match_manual[rnped_tempo$cod_r == 2894] = "match manual"

#HIDALGO PACHUCA DE SOTO - 2895 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, FECHA AVISTA SEXO Y EDAD
# Y QUE NO HA HECHO MATCH ES UNO CORRESPONDIENTE A MUNICIPIO DE MINERAL DE LA REFORMA
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 8714] = 2895
rnped_tempo$match_manual[rnped_tempo$cod_r == 2895] = "match manual"

#HIDALGO TULANCINGO DE BRAVO - 2895 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, MUN, SEXO Y EDAD
# Y QUE NO HA HECHO MATCH ES UNO CORRESPONDIENTE A FECHA DE AVISTA CON UN DÍA DE DIFERENCIA
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 44821] = 2896
rnped_tempo$match_manual[rnped_tempo$cod_r == 2896] = "match manual"

#HIDALGO ATITALAQUIA - 2897 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, FECHA AVISTA SEXO Y EDAD
# Y QUE NO HA HECHO MATCH ES UNO CORRESPONDIENTE A MUNICIPIO DE PACHUCA DE SOTO
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 7034] = 2897
rnped_tempo$match_manual[rnped_tempo$cod_r == 2897] = "match manual"


#HIDALGO NO ESPECIFICADO - 2898 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, MUN, FECHA AVISTA SEXO Y EDAD
# Y QUE NO HA HECHO MATCH ES UNO CORRESPONDIENTE A MUNICIPIO DE PACHUCA DE SOTO
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 8715] = 2898
rnped_tempo$match_manual[rnped_tempo$cod_r == 2898] = "match manual"

#JALISCO ZAPOPAN - 22729 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, MUN, FECHA Y EDAD
# Y QUE NO HA HECHO MATCH ES UNO CORRESPONDIENTE A UNA PERSONA DE SEXO FEMENINO
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 62168] = 22729
rnped_tempo$match_manual[rnped_tempo$cod_r == 22729] = "match manual"

#JALISCO NO ESPECIFICADO - 30981 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, MUN = NO ESPECIFICADO, FECHA
# Y QUE NO HA HECHO MATCH ES UNO CORRESPONDIENTE A UNA PERSONA CON REGISTRO DE EDAD A DIFERECIA DEL REGISTRO RNPED CON EDAD = NA
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 72618] = 30981
rnped_tempo$match_manual[rnped_tempo$cod_r == 30981] = "match manual"

#JALISCO NO ESPECIFICADO - 34431 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, MUN = NO ESPECIFICADO, FECHA
# Y QUE NO HA HECHO MATCH ES UNO CORRESPONDIENTE A UNA PERSONA CON REGISTRO DE EDAD A DIFERECIA DEL REGISTRO RNPED CON EDAD = NA
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 70760] = 34431
rnped_tempo$match_manual[rnped_tempo$cod_r == 34431] = "match manual"

#MICHOACÁN ZAMORA - 2192
rnped_tempo$match_manual[rnped_tempo$cod_r == 2192] = "sin match"

#NAYARIT TEPIC - 30296
rnped_tempo$match_manual[rnped_tempo$cod_r == 30296] = "sin match"

#NAYARIT TEPIC - 30587
rnped_tempo$match_manual[rnped_tempo$cod_r == 30587] = "sin match"

#NAYARIT TEPIC - 30983
rnped_tempo$match_manual[rnped_tempo$cod_r == 30983] = "sin match"

#NAYARIT TEPIC - 30126
rnped_tempo$match_manual[rnped_tempo$cod_r == 30126] = "sin match"

#NO ESPECIFICADO NO ESPECIFICADO - 539 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO = NO ESPECIFICADO,
# MUN = NO ESPECIFICADO, FECHA SEXO Y EDAD Y QUE NO HA HECHO MATCH
# ES UNO CORRESPONDIENTE A UNA PERSONA CON REGISTRO EN CALIFORNIA SAN JOSÉ
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 1132] = 539
rnped_tempo$match_manual[rnped_tempo$cod_r == 539] = "match manual"

#NO ESPECIFICADO NO ESPECIFICADO - 31440 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO = NO ESPECIFICADO,
# MUN = NO ESPECIFICADO, Y EDAD= NA. SIN EMBARGO SÍ CUENTA CON FECHAS DE AVISTAMIENTO, HECHOS Y DENUNCIA.
# OTROS DOS REGISTROS SON SIMILARES EN CUANTO A EDO Y MUN NO ESPECIFICADOS PERO SÍ CUENTAN CON REGISTRO DE EDAD Y FECHAS.
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 72631] = 31440
rnped_tempo$match_manual[rnped_tempo$cod_r == 31440] = "match manual"


#NO ESPECIFICADO NO ESPECIFICADO - 31562 NO SE ESTABLECIÓ ALGÚN MATCH PORQUE SOLO EXISTEN DOS REGISTROS MÁS QUE COINCIDEN EN
# EDO Y MUN NO ESPECIFICADO PERO CUENTAN CON REGISTRO DE EDAD, A DIFERENCIA DEL REGISTRO DE RNPED
rnped_tempo$match_manual[rnped_tempo$cod_r == 31562] = "sin match"


# NUEVO LEÓN MONTERREY - 8589 
rnped_tempo$match_manual[rnped_tempo$cod_r == 8589] = "sin match"

# NUEVO LEÓN MONTERREY - 10316 
rnped_tempo$match_manual[rnped_tempo$cod_r == 10316] = "sin match"

# NUEVO LEÓN MONTERREY - 8586 
rnped_tempo$match_manual[rnped_tempo$cod_r == 8586] = "sin match"

# PUEBLA PUEBLA - 1359 
rnped_tempo$match_manual[rnped_tempo$cod_r == 1359] = "sin match"

# PUEBLA NO ESPECIFICADO - 31331 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, MUN = NO ESPECIFICADO,
# FECHA Y SEXO. 
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 67252] = 31331
rnped_tempo$match_manual[rnped_tempo$cod_r == 31331] = "match manual"

# SAN LUIS POTOSÍ SAN LUIS POTOSÍ- 11275 
rnped_tempo$match_manual[rnped_tempo$cod_r == 11275] = "sin match"

# TAMAULIPAS NUEVO LAREDO - 3342
rnped_tempo$match_manual[rnped_tempo$cod_r == 3342] = "sin match"

# TAMAULIPAS NO ESPECIFICADO - 22429 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, MUN = NO ESPECIFICADO
# FECHA DE AVISTAMIENTO Y SEXO CORRESPONDE A UN REGISTRO CON EDAD A DIFERENCIA DEL REGISTRO DE RNPED CON EDAD = NA
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 93992] = 22429
rnped_tempo$match_manual[rnped_tempo$cod_r == 22429] = "match manual"

# TAMAULIPAS TAMPICO - 28822 EL ÚNICO REGISTRO DE LA BASE DE CENAPI QUE COINCIDEN EN EDO, MUN, SEXO, EDAD =NA
#  CORRESPONDE A UN REGISTRO  CON REGISTRO DE AVISTAMIENTO COMO REGISTRO DE HECHOS Y DENUNCIA
cenapi_tempo$cod_r[cenapi_tempo$cod_c == 93698] = 28822
rnped_tempo$match_manual[rnped_tempo$cod_r == 28822] = "match manual"

# TAMAULIPAS REYNOSA - 31252
rnped_tempo$match_manual[rnped_tempo$cod_r == 31252] = "sin match"

# TAMAULIPAS REYNOSA - 31859
rnped_tempo$match_manual[rnped_tempo$cod_r == 31859] = "sin match"

# ZACATECAS ZACATECAS - 1246
rnped_tempo$match_manual[rnped_tempo$cod_r == 1246] = "sin match"

# ZACATECAS ZACATECAS - 1247
rnped_tempo$match_manual[rnped_tempo$cod_r == 1247] = "sin match"

rnped_sin_match <- filter(rnped_tempo, match_manual == "sin match")
rnped_match_manual <- filter(rnped_tempo, match_manual == "match manual")

