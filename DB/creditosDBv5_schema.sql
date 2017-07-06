--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.10
-- Dumped by pg_dump version 9.4.10
-- Started on 2017-05-15 17:50:21 -04

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 1 (class 3079 OID 11861)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2231 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 598 (class 1247 OID 19180)
-- Name: tipo_resultado_buscar_persona; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE tipo_resultado_buscar_persona AS (
	id_persona bigint,
	ci integer,
	nombres character varying,
	ap_paterno character varying,
	ap_materno character varying,
	sexo character(1),
	fecha_nacimiento date,
	telefono integer,
	tel_celular integer,
	email character varying,
	direccion character varying,
	ocupacion character varying
);


ALTER TYPE tipo_resultado_buscar_persona OWNER TO postgres;

--
-- TOC entry 219 (class 1255 OID 19181)
-- Name: actualizar_decimales_plan_pago(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION actualizar_decimales_plan_pago() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  estado_operacion bigint := 0;
BEGIN
	CREATE TEMP TABLE temp_plan_pago AS
		select pp.id_plan_pago,
		replace(pp.saldo_capital, ',', '.') AS saldo_capital,
			replace(pp.capital, ',', '.') AS capital,
			replace(pp.interes, ',', '.') AS interes,
			replace(pp.otros_cargos, ',', '.') AS otros_cargos,
			replace(pp.total_cuota, ',', '.') AS total_cuota
		from plan_pagos pp
		order by pp.id_plan_pago;

	UPDATE
	  plan_pagos
	SET
	  saldo_capital = subquery.saldo_capital,
	  capital = subquery.capital,
	  interes = subquery.interes,
	  otros_cargos = subquery.otros_cargos,
	  total_cuota = subquery.total_cuota
	FROM
	 (select id_plan_pago, saldo_capital, capital, interes, otros_cargos, total_cuota
		from temp_plan_pago) as subquery
	 where plan_pagos.id_plan_pago = subquery.id_plan_pago;

	drop table temp_plan_pago;


	CREATE TEMP TABLE temp_totales_plan_pagos AS
		select tpp.id_credito,
		replace(tpp.total_capital, ',', '.') AS total_capital,
			replace(tpp.total_interes, ',', '.') AS total_interes,
			replace(tpp.total_otros_cargos, ',', '.') AS total_otros_cargos,
			replace(tpp.total_cuota, ',', '.') AS total_cuota
		from totales_plan_pagos tpp
		order by tpp.id_credito;

	UPDATE
	  totales_plan_pagos
	SET
	  total_capital = subquery.total_capital,
	  total_interes = subquery.total_interes,
	  total_otros_cargos = subquery.total_otros_cargos,
	  total_cuota = subquery.total_cuota
	FROM
	 (select id_credito, total_capital, total_interes, total_otros_cargos, total_cuota
		from temp_totales_plan_pagos) as subquery
	 where totales_plan_pagos.id_credito = subquery.id_credito;

	drop table temp_totales_plan_pagos;
END;
$$;


ALTER FUNCTION public.actualizar_decimales_plan_pago() OWNER TO postgres;

--
-- TOC entry 220 (class 1255 OID 19182)
-- Name: actualizar_numeracion_plan_pago(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION actualizar_numeracion_plan_pago() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  estado_operacion bigint := 0;
BEGIN
	CREATE TEMP TABLE temp_plan_pago AS
	select row_number() OVER (PARTITION BY pp.id_credito ORDER BY pp.id_plan_pago) AS numero_cuota,
	pp.id_plan_pago
	from plan_pagos pp
	order by pp.id_plan_pago;

	UPDATE
	  plan_pagos
	SET
	  numero_cuota = subquery.numero_cuota
	FROM
	 (select numero_cuota, id_plan_pago from temp_plan_pago) as subquery
	 where plan_pagos.id_plan_pago = subquery.id_plan_pago;

	drop table temp_plan_pago;
END;
$$;


ALTER FUNCTION public.actualizar_numeracion_plan_pago() OWNER TO postgres;

--
-- TOC entry 221 (class 1255 OID 19183)
-- Name: actualizar_persona(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION actualizar_persona(parametros text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id_persona bigint := cast(parametros[1] AS bigint);
  _ci integer := cast(parametros[2] AS integer);
  _ci_expedido character varying := cast(parametros[3] AS character varying);
  _nombres character varying := cast(parametros[4] AS character varying);
  _ap_paterno character varying := cast(parametros[5] AS character varying);
  _ap_materno character varying := cast(parametros[6] AS character varying);
  _sexo character(1) := cast(parametros[7] AS character(1));
  _fecha_nacimiento date := cast(parametros[8] AS date);
  _telefono character varying := cast(parametros[9] AS character varying);
  _tel_celular character varying := cast(parametros[10] AS character varying);
  _email character varying := cast(parametros[11] AS character varying);
  _ocupacion character varying := cast(parametros[12] AS character varying);
  _datos_adicionales character varying := cast(parametros[13] AS character varying);
  _calle_domicilio  character varying := cast(parametros[14] AS character varying);
  _numero_calle_domicilio integer := cast(parametros[15] AS character varying); 
  _zona_domicilio character varying := cast(parametros[16] AS character varying);
  _ciudad_domicilio character varying := cast(parametros[17] AS character varying);
  _estado_civil character varying := cast(parametros[18] AS character varying);

  --Para el histórico:
  _id_historial_personas bigint := 0;
  
  _id_usuario bigint := cast(parametros[19] AS bigint);
  _tipo_cambio character varying := cast(parametros[20] AS character varying);
  _motivo_cambio character varying := cast(parametros[21] AS character varying);

  _id_persona_anterior bigint;
  _ci_anterior integer;
  _ci_expedido_anterior character varying;
  _nombres_anterior character varying;
  _ap_paterno_anterior character varying;
  _ap_materno_anterior character varying;
  _sexo_anterior character(1);
  _fecha_nacimiento_anterior date;
  _telefono_anterior character varying;
  _tel_celular_anterior character varying;
  _email_anterior character varying;
  _ocupacion_anterior character varying;
  _datos_adicionales_anterior character varying;
  _calle_domicilio_anterior  character varying;
  _numero_calle_domicilio_anterior integer; 
  _zona_domicilio_anterior character varying;
  _ciudad_domicilio_anterior character varying;
  _estado_civil_anterior character varying;
BEGIN
	SELECT ci, ci_expedido, nombres, ap_paterno, ap_materno, sexo,
		fecha_nacimiento, telefono, tel_celular, email, ocupacion, datos_adicionales,
		calle_domicilio, numero_calle_domicilio, zona_domicilio, ciudad_domicilio
	INTO _ci_anterior,
		_ci_expedido_anterior, 
		 _nombres_anterior, 
		_ap_paterno_anterior, 
		_ap_materno_anterior, 
		_sexo_anterior,
		_fecha_nacimiento_anterior, 
		_telefono_anterior, 
		_tel_celular_anterior, 
		_email_anterior, 
		_ocupacion_anterior, 
		_datos_adicionales_anterior,
		_calle_domicilio_anterior, 
		_numero_calle_domicilio_anterior, 
		_zona_domicilio_anterior, 
		_ciudad_domicilio_anterior,
		_estado_civil_anterior
	FROM personas 
	WHERE id_persona = _id_persona;
	
	UPDATE personas
		SET ci = _ci, 
		ci_expedido = _ci_expedido,
		nombres = _nombres, 
		ap_paterno = _ap_paterno, 
		ap_materno = _ap_materno, 
		sexo = _sexo, 
		fecha_nacimiento = _fecha_nacimiento,
		telefono = _telefono, 
		tel_celular = _tel_celular, 
		email = _email, 
		ocupacion = _ocupacion, 
		datos_adicionales = _datos_adicionales, 
		calle_domicilio = _calle_domicilio,
		numero_calle_domicilio = _numero_calle_domicilio, 
		zona_domicilio = _zona_domicilio, 
		ciudad_domicilio = _ciudad_domicilio,
		estado_civil = _estado_civil
	WHERE id_persona = _id_persona;

	
	INSERT INTO historial_personas (id_persona, ci, ci_expedido, nombres, ap_paterno, ap_materno, sexo,
		fecha_nacimiento, telefono, tel_celular, email, ocupacion, datos_adicionales,
		calle_domicilio, numero_calle_domicilio, zona_domicilio, ciudad_domicilio, estado_civil,
		id_usuario, tipo_cambio, motivo_cambio)
	VALUES (_id_persona,
		_ci_anterior,		
		_ci_expedido_anterior, 
		_nombres_anterior,
		_ap_paterno_anterior,
		_ap_materno_anterior,
		_sexo_anterior,
		_fecha_nacimiento_anterior,
		_telefono_anterior,
		_tel_celular_anterior,
		_email_anterior,
		_ocupacion_anterior,
		_datos_adicionales_anterior,
		_calle_domicilio_anterior,
		_numero_calle_domicilio_anterior,
		_zona_domicilio_anterior,
		_ciudad_domicilio_anterior,
		_estado_civil,
		_id_usuario,
		_tipo_cambio,
		_motivo_cambio)
	RETURNING id_historial_personas INTO _id_historial_personas;
--	EXCEPTION
--	  WHEN raise exception THEN
--	   return false;

 -- No es necesario devolver nada, pero se devuelve solo para no perder la capacidad de hacerlo
 -- en caso de necesitar en el futuro.
	RETURN _id_historial_personas;
END $$;


ALTER FUNCTION public.actualizar_persona(parametros text[]) OWNER TO postgres;

--
-- TOC entry 222 (class 1255 OID 19184)
-- Name: actualizar_usuario(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION actualizar_usuario(parametros text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id_usuario bigint := cast(parametros[1] AS bigint);
  _ci integer := cast(parametros[2] AS integer);
  _ci_expedido character varying := cast(parametros[3] AS character varying);
  _nombres character varying := cast(parametros[4] AS character varying);
  _ap_paterno character varying := cast(parametros[5] AS character varying);
  _ap_materno character varying := cast(parametros[6] AS character varying);
  _telefono character varying := cast(parametros[7] AS character varying);
  _tel_celular character varying := cast(parametros[8] AS character varying);
  _email character varying := cast(parametros[9] AS character varying);
  _direccion  character varying := cast(parametros[10] AS character varying);
  _datos_adicionales character varying := cast(parametros[11] AS character varying);
  _contrasenia character varying := cast(parametros[12] AS character varying);
  _nombre_usuario character varying := cast(parametros[13] AS character varying);
  _id_rol integer := cast(parametros[14] AS integer);
  _usuario_activo boolean := cast(parametros[15] AS boolean);

BEGIN
	IF _contrasenia = '66d39efd283de286c9192281666950b3' THEN --Sin contraseña
		UPDATE usuarios
			SET ci = _ci, 
			ci_expedido = _ci_expedido,
			nombres = _nombres, 
			ap_paterno = _ap_paterno, 
			ap_materno = _ap_materno, 
			telefono = _telefono, 
			tel_celular = _tel_celular, 
			email = _email, 
			direccion = _direccion,
			datos_adicionales = _datos_adicionales,
			nombre_usuario = _nombre_usuario,
			id_rol = _id_rol,
			usuario_activo = _usuario_activo
		WHERE id_usuario = _id_usuario;
	ELSE -- Tiene contraseña
		UPDATE usuarios
			SET ci = _ci, 
			ci_expedido = _ci_expedido,
			nombres = _nombres, 
			ap_paterno = _ap_paterno, 
			ap_materno = _ap_materno, 
			telefono = _telefono, 
			tel_celular = _tel_celular, 
			email = _email, 
			direccion = _direccion,
			datos_adicionales = _datos_adicionales,
			contrasenia = MD5(_contrasenia),
			nombre_usuario = _nombre_usuario,
			id_rol = _id_rol,
			usuario_activo = _usuario_activo
		WHERE id_usuario = _id_usuario;
	END IF;

--	EXCEPTION
--	  WHEN raise exception THEN
--	   return false;

 -- No es necesario devolver nada, pero se devuelve solo para no perder la capacidad de hacerlo
 -- en caso de necesitar en el futuro.
	RETURN _id_usuario;
END $$;


ALTER FUNCTION public.actualizar_usuario(parametros text[]) OWNER TO postgres;

--
-- TOC entry 223 (class 1255 OID 19185)
-- Name: buscar_persona(anyarray); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION buscar_persona(parametros anyarray) RETURNS TABLE(id_persona bigint, ci integer, ci_expedido character varying, nombres character varying, ap_paterno character varying, ap_materno character varying, sexo character, fecha_nacimiento date, telefono character varying, tel_celular character varying, email character varying, ocupacion character varying, datos_adicionales character varying, calle_domicilio character varying, numero_calle_domicilio integer, zona_domicilio character varying, ciudad_domicilio character varying, estado_civil character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
	sql text := '';
	condiciones text := '';
	_id_persona character varying := parametros[1];
	_ci character varying := parametros[2];
	_nombres character varying := UPPER(parametros[3]);
	_ap_paterno character varying := UPPER(parametros[4]);
	_ap_materno character varying := UPPER(parametros[5]);
	busquedaExacta boolean := parametros[6];
	_tipo_persona character varying := UPPER(parametros[7]); --TODOS, CLIENTE, GARANTE, CONYUGE
BEGIN
	IF _tipo_persona = 'TODOS' THEN
		sql := 'SELECT p.id_persona, p.ci, p.ci_expedido, p.nombres, p.ap_paterno, p.ap_materno, p.sexo,
				p.fecha_nacimiento, p.telefono, p.tel_celular, p.email, p.ocupacion,
				p.datos_adicionales, p.calle_domicilio, p.numero_calle_domicilio,
				p.zona_domicilio, p.ciudad_domicilio, p.estado_civil
			FROM personas p
			WHERE 1 = 1';
--		condiciones = condiciones ||  ' AND (pc.tipo_persona = ''CLIENTE'' OR pc.tipo_persona = ''GARANTE'') ';
	ELSE
		sql := 'SELECT p.id_persona, p.ci, p.ci_expedido, p.nombres, p.ap_paterno, p.ap_materno, p.sexo,
				p.fecha_nacimiento, p.telefono, p.tel_celular, p.email, p.ocupacion,
				p.datos_adicionales, p.calle_domicilio, p.numero_calle_domicilio,
				p.zona_domicilio, p.ciudad_domicilio, p.estado_civil
			FROM personas p
			INNER JOIN persona_credito pc ON p.id_persona = pc.id_persona
			INNER JOIN creditos c ON c.id_credito = pc.id_credito
			WHERE 1 = 1';
		condiciones = condiciones ||  ' AND c.credito_activo = true AND pc.tipo_persona = ''' || _tipo_persona || ''' ';	
	END IF;
		
	IF busquedaExacta IS TRUE THEN
		IF _id_persona IS NOT NULL OR _id_persona <> '' THEN
			condiciones = condiciones || ' AND p.id_persona = ' || _id_persona || ' ';
		END IF;
		IF _ci IS NOT NULL OR _ci <> '' THEN
			condiciones = condiciones || ' AND p.ci = ' || _ci || ' ';
		END IF;
		IF _nombres IS NOT NULL OR _nombres <> '' THEN
			condiciones = condiciones || ' AND UPPER(p.nombres) = ''' || _nombres || ''' ';
		END IF;	
		IF _ap_paterno IS NOT NULL OR _ap_paterno <> '' THEN
			condiciones = condiciones || ' AND UPPER(p.ap_paterno) = ''' || _ap_paterno || ''' ';
		END IF;
		IF _ap_materno IS NOT NULL OR _ap_materno <> '' THEN
			condiciones = condiciones || ' AND UPPER(p.ap_materno) = ''' || _ap_materno || ''' ';
		END IF;
	ELSE
		IF _id_persona IS NOT NULL OR _id_persona <> '' THEN
			condiciones = condiciones || ' AND p.id_persona::VARCHAR LIKE ''%' || _id_persona || '%'' ';
		END IF;
		IF _ci IS NOT NULL OR _ci <> '' THEN
			condiciones = condiciones || ' AND p.ci::VARCHAR LIKE ''%' || _ci || '%'' ';
		END IF;
		IF _nombres IS NOT NULL OR _nombres <> '' THEN
			condiciones = condiciones || ' AND UPPER(p.nombres) LIKE ''%' || _nombres || '%'' ';
		END IF;	
		IF _ap_paterno IS NOT NULL OR _ap_paterno <> '' THEN
			condiciones = condiciones || ' AND UPPER(p.ap_paterno) LIKE ''%' || _ap_paterno || '%'' ';
		END IF;
		IF _ap_materno IS NOT NULL OR _ap_materno <> '' THEN
			condiciones = condiciones || ' AND UPPER(p.ap_materno) LIKE ''%' || _ap_materno || '%'' ';
		END IF;
	END IF;

	IF condiciones = '' THEN
	--	condiciones = ' AND id_persona = -1';
	END IF;

	sql = sql || condiciones || ' ORDER BY p.ap_paterno, p.ap_materno, p.nombres ';
	
	--EXECUTE IMMEDIATE searchsql into resultado;
	RAISE NOTICE '%', sql; 
	RETURN QUERY EXECUTE sql;
END
$$;


ALTER FUNCTION public.buscar_persona(parametros anyarray) OWNER TO postgres;

--
-- TOC entry 224 (class 1255 OID 19186)
-- Name: buscar_persona_con_credito_asociado(bigint, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION buscar_persona_con_credito_asociado(_id_credito bigint, _tipo_persona character varying) RETURNS TABLE(id_persona bigint, ci integer, ci_expedido character varying, nombres character varying, ap_paterno character varying, ap_materno character varying, sexo character, fecha_nacimiento date, telefono character varying, tel_celular character varying, email character varying, ocupacion character varying, datos_adicionales character varying, calle_domicilio character varying, numero_calle_domicilio integer, zona_domicilio character varying, ciudad_domicilio character varying, estado_civil character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
--	_id_persona_encontrada bigint := 0;
	sql text := '';
	sqlCredito text := '';
BEGIN
	sqlCredito := 'SELECT pc.id_persona
	FROM persona_credito pc
	INNER JOIN creditos c
	ON pc.id_credito = c.id_credito
	WHERE PC.id_credito = ' || _id_credito || ' AND  c.credito_activo = TRUE AND pc.tipo_persona = '''
	 || _tipo_persona || '''';

	sql = 'SELECT id_persona, ci, ci_expedido, nombres, ap_paterno, ap_materno, sexo, fecha_nacimiento, 
	       telefono, tel_celular, email, ocupacion, datos_adicionales,
	       calle_domicilio, numero_calle_domicilio, zona_domicilio, ciudad_domicilio, estado_civil
	       FROM personas
	       WHERE id_persona  in (' || sqlCredito || ')';

	RAISE NOTICE '%', sql; 
	RETURN QUERY EXECUTE sql;	
END
$$;


ALTER FUNCTION public.buscar_persona_con_credito_asociado(_id_credito bigint, _tipo_persona character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 174 (class 1259 OID 19187)
-- Name: plan_pagos; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE plan_pagos (
    id_plan_pago bigint NOT NULL,
    id_credito bigint NOT NULL,
    numero_cuota integer,
    fecha_vencimiento_imprimir character varying,
    saldo_capital character varying,
    capital character varying,
    interes character varying,
    otros_cargos character varying,
    total_cuota character varying,
    pagado boolean DEFAULT false,
    fecha_pagado timestamp with time zone,
    fecha_vencimiento date
);


ALTER TABLE plan_pagos OWNER TO postgres;

--
-- TOC entry 218 (class 1255 OID 19194)
-- Name: buscar_plan_pago(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION buscar_plan_pago(_id_persona bigint) RETURNS SETOF plan_pagos
    LANGUAGE sql
    AS $$
	SELECT pp.id_plan_pago,
		pp.id_credito, 
		pp.numero_cuota, 
		pp.fecha_vencimiento_imprimir, 
		pp.saldo_capital, 
		pp.capital, 
		pp.interes, 
		pp.otros_cargos, 
		pp.total_cuota, 
		pp.pagado,
		pp.fecha_pagado, 
		pp.fecha_vencimiento
	FROM persona_credito AS p_c
	INNER JOIN creditos AS cr ON p_c.id_credito = cr.id_credito
	INNER JOIN plan_pagos AS pp ON pp.id_credito = cr.id_credito
	WHERE p_c.id_persona = _id_persona AND cr.credito_activo = TRUE AND p_c.tipo_persona = 'CLIENTE'
	ORDER BY pp.id_plan_pago;
$$;


ALTER FUNCTION public.buscar_plan_pago(_id_persona bigint) OWNER TO postgres;

--
-- TOC entry 225 (class 1255 OID 19195)
-- Name: cliente_tiene_creditos(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cliente_tiene_creditos(_id_persona bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id_credito bigint := 0;
BEGIN
	SELECT c.id_credito INTO _id_credito FROM persona_credito pc
	INNER JOIN creditos c
	ON pc.id_credito = c.id_credito
	WHERE PC.id_persona = _id_persona AND c.credito_activo = TRUE AND pc.tipo_persona = 'CLIENTE';

	IF _id_credito is null THEN
		_id_credito = -1;
	END IF;

--	EXCEPTION
--	  WHEN raise exception THEN
--	   return false;

	RETURN _id_credito;
END $$;


ALTER FUNCTION public.cliente_tiene_creditos(_id_persona bigint) OWNER TO postgres;

--
-- TOC entry 226 (class 1255 OID 19196)
-- Name: eliminar_firmas_contratos(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION eliminar_firmas_contratos(_id_persona bigint) RETURNS void
    LANGUAGE sql
    AS $$
	DELETE FROM firmas_contratos
	WHERE id_persona = _id_persona;
$$;


ALTER FUNCTION public.eliminar_firmas_contratos(_id_persona bigint) OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 19197)
-- Name: eliminar_tipos_firmas_contratos(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION eliminar_tipos_firmas_contratos(_id_tipo_firma_contrato integer) RETURNS void
    LANGUAGE sql
    AS $$
	DELETE FROM tipos_firmas_contratos
	WHERE id_tipo_firma_contrato = _id_tipo_firma_contrato;
$$;


ALTER FUNCTION public.eliminar_tipos_firmas_contratos(_id_tipo_firma_contrato integer) OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 19198)
-- Name: gestion_configuraciones(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gestion_configuraciones(parametros text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id_configuracion integer := -1;
  _ruta_visor_pdf character varying := cast(parametros[2] AS character varying);
  _ruta_destino_archivos_pdf character varying := cast(parametros[3] AS character varying);
  _solo_guadar_archivos_pdf boolean := cast(parametros[4] AS boolean);  
  _ruta_programas_pg character varying := cast(parametros[5] AS character varying);    
BEGIN
	IF UPPER(cast(parametros[1] AS character varying)) <> 'NULL' THEN--Se verifica que el id no sea nulo
		RAISE NOTICE 'ID: %', parametros[1];
		_id_configuracion := cast(parametros[1] AS integer);
	END IF;
	
	IF _id_configuracion > 0 THEN
		UPDATE configuraciones
		SET ruta_visor_pdf = _ruta_visor_pdf,
		    ruta_destino_archivos_pdf = _ruta_destino_archivos_pdf,
		    solo_guadar_archivos_pdf = _solo_guadar_archivos_pdf,
		    ruta_programas_pg = _ruta_programas_pg
		WHERE id_configuracion = _id_configuracion;
	ELSE
		INSERT INTO configuraciones (ruta_visor_pdf, ruta_destino_archivos_pdf, solo_guadar_archivos_pdf, ruta_programas_pg)
		VALUES (_ruta_visor_pdf, _ruta_destino_archivos_pdf, _solo_guadar_archivos_pdf, _ruta_programas_pg)
		RETURNING id_configuracion into _id_configuracion;
	END IF;
	
	RETURN _id_configuracion;
END $$;


ALTER FUNCTION public.gestion_configuraciones(parametros text[]) OWNER TO postgres;

--
-- TOC entry 229 (class 1255 OID 19199)
-- Name: gestion_firmas_contratos(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gestion_firmas_contratos(parametros text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id_persona integer := -1;
  _tipo_firma_contrato character varying := cast(parametros[2] AS character varying);
  _es_acreedor_representante character varying := cast(parametros[3] AS character varying);
BEGIN
	IF UPPER(cast(parametros[1] AS character varying)) <> 'NULL' THEN
		RAISE NOTICE 'ID: %', parametros[1];
		_id_persona := cast(parametros[1] AS bigint);
	END IF;
	
	IF _id_persona > 0 THEN
		UPDATE firmas_contratos
		SET
		    es_acreedor_representante = _es_acreedor_representante --Es el único campo que interesa actualizar.
		WHERE id_persona = _id_persona;
	ELSE
		INSERT INTO firmas_contratos (id_persona, tipo_firma_contrato, es_acreedor_representante)
		VALUES (_id_persona, _tipo_firma_contrato, _es_acreedor_representante)
		RETURNING id_persona into _id_persona;
	END IF;
	
	RETURN _id_persona;
END $$;


ALTER FUNCTION public.gestion_firmas_contratos(parametros text[]) OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 19200)
-- Name: gestion_tipos_firmas_contratos(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gestion_tipos_firmas_contratos(parametros text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id_tipo_firma_contrato integer := -1;
  _tipo_firma_contrato character varying := cast(parametros[2] AS character varying);
BEGIN
	IF UPPER(cast(parametros[1] AS character varying)) <> 'NULL' THEN
		RAISE NOTICE 'ID: %', parametros[1];
		_id_tipo_firma_contrato := cast(parametros[1] AS integer);
	END IF;
	
	IF _id_tipo_firma_contrato > 0 THEN
		UPDATE tipos_firmas_contratos
		SET tipo_firma_contrato = _tipo_firma_contrato
		WHERE id_tipo_firma_contrato = _id_tipo_firma_contrato;
	ELSE
		INSERT INTO tipos_firmas_contratos (tipo_firma_contrato)
		VALUES (_tipo_firma_contrato)
		RETURNING id_tipo_firma_contrato into _id_tipo_firma_contrato;
	END IF;
	
	RETURN _id_tipo_firma_contrato;
END $$;


ALTER FUNCTION public.gestion_tipos_firmas_contratos(parametros text[]) OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 19201)
-- Name: get_configuraciones(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_configuraciones() RETURNS TABLE(id_configuracion integer, ruta_visor_pdf character varying, ruta_destino_archivos_pdf character varying, solo_guadar_archivos_pdf boolean, ruta_programas_pg character varying)
    LANGUAGE sql
    AS $$
	SELECT id_configuracion,
	       ruta_visor_pdf, 
	       ruta_destino_archivos_pdf,
	       solo_guadar_archivos_pdf,
	       ruta_programas_pg
	FROM configuraciones;
$$;


ALTER FUNCTION public.get_configuraciones() OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 19202)
-- Name: get_contrato(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_contrato(_id_credito bigint) RETURNS TABLE(id_credito bigint, contrato_texto_html character varying, datos_personas_firmas character varying)
    LANGUAGE sql
    AS $$
	SELECT id_credito,
	  contrato_texto_html,
	  datos_personas_firmas
	FROM contratos
	WHERE id_credito = _id_credito;
$$;


ALTER FUNCTION public.get_contrato(_id_credito bigint) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 19203)
-- Name: get_credito(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_credito(_id_credito bigint) RETURNS TABLE(id_credito bigint, id_usuario bigint, fecha_registro timestamp with time zone, fecha_primer_pago date, metodo_generacion character varying, moneda character varying, num_cuotas smallint, frecuencia_pagos smallint, importe real, otros_pagos real, interes real, tipo_interes character varying, credito_activo boolean)
    LANGUAGE sql
    AS $$
	SELECT id_credito, id_usuario, fecha_registro, fecha_primer_pago, metodo_generacion, moneda,
	 num_cuotas, frecuencia_pagos, importe, otros_pagos, interes,
	 tipo_interes, credito_activo 
	FROM creditos
	WHERE id_credito = _id_credito;
$$;


ALTER FUNCTION public.get_credito(_id_credito bigint) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 19204)
-- Name: get_firmas_contratos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_firmas_contratos() RETURNS TABLE(id_persona bigint, tipo_firma_contrato character varying, acreedor_representante boolean)
    LANGUAGE sql
    AS $$
	SELECT id_persona,
	  tipo_firma_contrato,
	  es_acreedor_representante
	FROM firmas_contratos;
$$;


ALTER FUNCTION public.get_firmas_contratos() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 19205)
-- Name: get_garantias(bigint, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_garantias(_id_credito bigint, _tipo_garantia character varying) RETURNS TABLE(id_garantia bigint, id_credito bigint, nombre_garantia character varying, descripcion_garantia text, tipo_garantia character varying)
    LANGUAGE sql
    AS $$
	SELECT id_garantia, id_credito, nombre_garantia, descripcion_garantia, tipo_garantia
	FROM GARANTIAS
	WHERE id_credito = _id_credito AND tipo_garantia = _tipo_garantia;
$$;


ALTER FUNCTION public.get_garantias(_id_credito bigint, _tipo_garantia character varying) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 19206)
-- Name: get_persona_por_ci(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_persona_por_ci(_ci_persona bigint) RETURNS TABLE(id_persona bigint, ci integer, ci_expedido character varying, nombres character varying, ap_paterno character varying, ap_materno character varying, sexo character, fecha_nacimiento date, telefono character varying, tel_celular character varying, email character varying, ocupacion character varying, datos_adicionales character varying, calle_domicilio character varying, numero_calle_domicilio integer, zona_domicilio character varying, ciudad_domicilio character varying, estado_civil character varying)
    LANGUAGE sql
    AS $$
	SELECT id_persona, ci, ci_expedido, nombres, ap_paterno, ap_materno, sexo, fecha_nacimiento,
		telefono, tel_celular, email, ocupacion, datos_adicionales, calle_domicilio,
		numero_calle_domicilio, zona_domicilio, ciudad_domicilio, estado_civil
	FROM personas
		WHERE ci = _ci_persona;
$$;


ALTER FUNCTION public.get_persona_por_ci(_ci_persona bigint) OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 19207)
-- Name: get_persona_por_id(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_persona_por_id(_id_persona bigint) RETURNS TABLE(id_persona bigint, ci integer, ci_expedido character varying, nombres character varying, ap_paterno character varying, ap_materno character varying, sexo character, fecha_nacimiento date, telefono character varying, tel_celular character varying, email character varying, ocupacion character varying, datos_adicionales character varying, calle_domicilio character varying, numero_calle_domicilio integer, zona_domicilio character varying, ciudad_domicilio character varying, estado_civil character varying)
    LANGUAGE sql
    AS $$
	SELECT id_persona, ci, ci_expedido, nombres, ap_paterno, ap_materno, sexo, fecha_nacimiento,
		telefono, tel_celular, email, ocupacion, datos_adicionales, calle_domicilio,
		numero_calle_domicilio, zona_domicilio, ciudad_domicilio, estado_civil
	FROM personas
	WHERE id_persona = _id_persona;
$$;


ALTER FUNCTION public.get_persona_por_id(_id_persona bigint) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 19208)
-- Name: get_tipos_firmas_contratos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_tipos_firmas_contratos() RETURNS TABLE(id_tipo_firma_contrato integer, tipo_firma_contrato character varying)
    LANGUAGE sql
    AS $$
	SELECT   id_tipo_firma_contrato,
		tipo_firma_contrato
	FROM tipos_firmas_contratos;
$$;


ALTER FUNCTION public.get_tipos_firmas_contratos() OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 19209)
-- Name: get_totales_plan_pagos(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_totales_plan_pagos(_id_credito bigint) RETURNS TABLE(id_credito bigint, total_capital character varying, total_interes character varying, total_otros_cargos character varying, total_cuota character varying)
    LANGUAGE sql
    AS $$
	SELECT * FROM totales_plan_pagos
		WHERE id_credito = _id_credito;
$$;


ALTER FUNCTION public.get_totales_plan_pagos(_id_credito bigint) OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 19210)
-- Name: get_usuario(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION get_usuario(_id_usuario bigint) RETURNS TABLE(id_usuario bigint, ci integer, ci_expedido character varying, nombres character varying, ap_paterno character varying, ap_materno character varying, telefono character varying, tel_celular character varying, email character varying, direccion character varying, datos_adicionales character varying, contrasenia character varying, nombre_usuario character varying, id_rol integer, usuario_activo boolean)
    LANGUAGE sql
    AS $$
	SELECT id_usuario, 
		ci,
		ci_expedido,
		nombres,
		ap_paterno,
		ap_materno,
		telefono,
		tel_celular,
		email,
		direccion,
		datos_adicionales,
		contrasenia,
		nombre_usuario,
		id_rol,
		usuario_activo
	FROM usuarios
	WHERE id_usuario = _id_usuario;
$$;


ALTER FUNCTION public.get_usuario(_id_usuario bigint) OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 19211)
-- Name: insertar_contrato(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertar_contrato(parametros text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  existe_contrato integer := 0;
  _id_credito bigint := cast(parametros[1] AS bigint);
  _contrato_texto_html character varying := cast(parametros[2] AS character varying);
  _datos_personas_firmas character varying := cast(parametros[3] AS character varying);
BEGIN
	SELECT count(id_credito) INTO existe_contrato
	FROM contratos
	WHERE id_credito = _id_credito;
	
	IF existe_contrato > 0 THEN
		UPDATE contratos
		SET contrato_texto_html = _contrato_texto_html, 
			datos_personas_firmas = _datos_personas_firmas
		WHERE id_credito = _id_credito;
	ELSE
		INSERT INTO contratos (id_credito, 
			contrato_texto_html, 
			datos_personas_firmas)
		VALUES (_id_credito, 
			_contrato_texto_html, 
			_datos_personas_firmas);
	END IF;

	RETURN _id_credito;
END $$;


ALTER FUNCTION public.insertar_contrato(parametros text[]) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 19212)
-- Name: insertar_credito(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertar_credito(parametros text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id_credito bigint := 0;
  _id_usuario bigint := cast(parametros[1] AS integer);
  _fecha_primer_pago date := cast(parametros[2] AS date);
  _metodo_generacion character varying := cast(parametros[3] AS character varying);
  _moneda character varying := cast(parametros[4] AS character varying);
  _num_cuotas smallint := cast(parametros[5] AS smallint);
  _frecuencia_pagos smallint := cast(parametros[6] AS smallint);
  _importe real := cast(parametros[7] AS real);
  _otros_pagos real:= cast(parametros[8] AS real);
  _interes real:= cast(parametros[9] AS real);
  _tipo_interes character varying:= cast(parametros[10] AS character varying);
  _credito_activo boolean := cast(parametros[11] AS boolean);
--  cliente_tiene_credito integer := 0;
BEGIN
	INSERT INTO creditos (id_usuario, fecha_primer_pago, metodo_generacion, moneda, num_cuotas, frecuencia_pagos, importe, otros_pagos, interes, tipo_interes, credito_activo)
	VALUES (_id_usuario, _fecha_primer_pago, _metodo_generacion, _moneda, _num_cuotas, _frecuencia_pagos, _importe, _otros_pagos, _interes, _tipo_interes, _credito_activo)
	RETURNING id_credito into _id_credito;

--	EXCEPTION
--	  WHEN raise exception THEN
--	   return false;

	RETURN _id_credito;
END $$;


ALTER FUNCTION public.insertar_credito(parametros text[]) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 19213)
-- Name: insertar_firmas_contratos(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertar_firmas_contratos(parametros text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id_persona bigint := cast(parametros[1] AS bigint);
  _tipo_firma_contrato character varying := cast(parametros[2] AS character varying);
  _es_acreedor_representante boolean := cast(parametros[3] AS boolean);
  _id_persona_encontrada bigint := 0;
BEGIN
	SELECT id_persona INTO _id_persona_encontrada
	FROM firmas_contratos
	WHERE id_persona = _id_persona;

	IF _id_persona_encontrada IS NULL THEN
		_id_persona_encontrada := 0;
	END IF;

	IF _id_persona_encontrada = 0 THEN
		INSERT INTO firmas_contratos (id_persona, tipo_firma_contrato, es_acreedor_representante)
		VALUES (_id_persona, _tipo_firma_contrato, _es_acreedor_representante)
		RETURNING id_persona into _id_persona;
	ELSE
		UPDATE firmas_contratos
		SET es_acreedor_representante = _es_acreedor_representante --Es el único campo que interesa actualizar.
		WHERE id_persona = _id_persona;
	END IF;
	
	 -- Se mantiene la capacidad para devolver para poder implementar codigos de errores.
	RETURN _id_persona;
END $$;


ALTER FUNCTION public.insertar_firmas_contratos(parametros text[]) OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 19214)
-- Name: insertar_garantias(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertar_garantias(parametros text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id_garantia bigint := 0;
  _id_credito bigint := cast(parametros[1] AS bigint);
  _nombre_garantia character varying := cast(parametros[2] AS character varying);
  _descripcion_garantia text := cast(parametros[3] AS character varying);
  _tipo_garantia character varying := cast(parametros[4] AS character varying);
BEGIN
	INSERT INTO garantias (id_credito, nombre_garantia, descripcion_garantia, tipo_garantia)
	VALUES (_id_credito, initcap(lower(_nombre_garantia)), _descripcion_garantia, _tipo_garantia)
	RETURNING id_garantia into _id_garantia;

--	EXCEPTION
--	  WHEN raise exception THEN
--	   return false;

	RETURN _id_garantia;
END $$;


ALTER FUNCTION public.insertar_garantias(parametros text[]) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 19215)
-- Name: insertar_historial_creditos(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertar_historial_creditos(parametros text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id_historial_credito bigint := 0;
  _id_credito bigint := cast(parametros[1] AS bigint);
  _id_usuario bigint := cast(parametros[2] AS bigint);
  _motivo_cambio character varying := cast(parametros[3] AS character varying);
  _credito_activo_historico boolean := cast(parametros[4] AS boolean);
  _tipo_cambio character varying := cast(parametros[5] AS character varying);
BEGIN
	INSERT INTO historial_creditos (id_credito, id_usuario, motivo_cambio, credito_activo_historico, tipo_cambio)
	VALUES (_id_credito, _id_usuario, _motivo_cambio, _credito_activo_historico, _tipo_cambio)
	RETURNING id_historial_credito into _id_historial_credito;

	UPDATE creditos
	SET credito_activo = false
	WHERE id_credito = _id_credito;

--	EXCEPTION
--	  WHEN raise exception THEN
--	   return false;

	RETURN _id_historial_credito;
END $$;


ALTER FUNCTION public.insertar_historial_creditos(parametros text[]) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 19216)
-- Name: insertar_persona(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertar_persona(parametros text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id_persona bigint := 0;
  _ci integer := cast(parametros[1] AS integer);
  _ci_expedido character varying := cast(parametros[2] AS character varying);
  _nombres character varying := cast(parametros[3] AS character varying);
  _ap_paterno character varying := cast(parametros[4] AS character varying);
  _ap_materno character varying := cast(parametros[5] AS character varying);
  _sexo character(1) := cast(parametros[6] AS character(1));
  _fecha_nacimiento date := cast(parametros[7] AS date);
  _telefono character varying := cast(parametros[8] AS character varying);
  _tel_celular character varying := cast(parametros[9] AS character varying);
  _email character varying := cast(parametros[10] AS character varying);
  _ocupacion character varying := cast(parametros[11] AS character varying);
  _datos_adicionales character varying := cast(parametros[12] AS character varying);
  _calle_domicilio  character varying := cast(parametros[13] AS character varying);
  _numero_calle_domicilio integer := cast(parametros[14] AS character varying); 
  _zona_domicilio character varying := cast(parametros[15] AS character varying);
  _ciudad_domicilio character varying := cast(parametros[16] AS character varying);
  _estado_civil character varying := cast(parametros[17] AS character varying);

BEGIN
	INSERT INTO personas (ci, 
		ci_expedido, 
		nombres, 
		ap_paterno, 
		ap_materno, 
		sexo, 
		fecha_nacimiento, 
		telefono, 
		tel_celular, 
		email, 
		ocupacion, 
		datos_adicionales, 
		calle_domicilio, 
		numero_calle_domicilio, 
		zona_domicilio, 
		ciudad_domicilio,
		estado_civil)
	VALUES (_ci, 
		_ci_expedido, 
		initcap(lower(_nombres)), 
		initcap(lower(_ap_paterno)), 
		initcap(lower(_ap_materno)), 
		_sexo, 
		_fecha_nacimiento, 
		_telefono, 
		_tel_celular, 
		_email, 
		initcap(lower(_ocupacion)), 
		_datos_adicionales, _calle_domicilio, 
		_numero_calle_domicilio, 
		initcap(lower(_zona_domicilio)), 
		initcap(lower(_ciudad_domicilio)),
		_estado_civil)
	RETURNING id_persona into _id_persona;
--	EXCEPTION
--	  WHEN raise exception THEN
--	   return false;

	RETURN _id_persona;
END $$;


ALTER FUNCTION public.insertar_persona(parametros text[]) OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 19217)
-- Name: insertar_persona_credito(bigint, bigint, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertar_persona_credito(_id_persona bigint, _id_credito bigint, _tipo_persona character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  codigo_error int := 0;
BEGIN
	INSERT INTO persona_credito (id_persona, id_credito, tipo_persona)
	VALUES (_id_persona, _id_credito, _tipo_persona);
--	EXCEPTION
--	  WHEN raise exception THEN
--	   return false;
  return codigo_error;
END $$;


ALTER FUNCTION public.insertar_persona_credito(_id_persona bigint, _id_credito bigint, _tipo_persona character varying) OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 19218)
-- Name: insertar_plan_pago(bigint, text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertar_plan_pago(idcredito bigint, plan_pagos text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _numero_cuota integer := plan_pagos[1];
  _fecha_vencimiento_imprimir varchar := plan_pagos[2];
  _saldo_capital varchar := plan_pagos[3];
  _capital varchar := plan_pagos[4];
  _interes varchar := plan_pagos[5];
  _otros_cargos varchar := plan_pagos[6];
  _total_cuota varchar := plan_pagos[7];
  _fecha_vencimiento Date := cast(plan_pagos[8] AS date);
  resultado bigint;
BEGIN
	INSERT INTO plan_pagos (id_credito, numero_cuota, fecha_vencimiento_imprimir, saldo_capital, capital, interes, otros_cargos, total_cuota, fecha_vencimiento)
	VALUES (idCredito, _numero_cuota, _fecha_vencimiento_imprimir, _saldo_capital, _capital, _interes, _otros_cargos, _total_cuota, _fecha_vencimiento)
	RETURNING id_plan_pago into resultado;

	RETURN resultado;
END;
$$;


ALTER FUNCTION public.insertar_plan_pago(idcredito bigint, plan_pagos text[]) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 19219)
-- Name: insertar_totales_plan_pago(bigint, text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertar_totales_plan_pago(_idcredito bigint, totales_plan_pagos text[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  _total_capital varchar := totales_plan_pagos[1];
  _total_interes varchar := totales_plan_pagos[2];
  _total_otros_cargos varchar := totales_plan_pagos[3];
  _total_cuota varchar := totales_plan_pagos[4];
  resultado integer := 0; --Insertado sin errores.
BEGIN
	INSERT INTO totales_plan_pagos (id_credito, total_capital, total_interes, total_otros_cargos, total_cuota)
	VALUES (_idcredito, _total_capital, _total_interes, _total_otros_cargos, _total_cuota);

	RETURN resultado;
END;
$$;


ALTER FUNCTION public.insertar_totales_plan_pago(_idcredito bigint, totales_plan_pagos text[]) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 19220)
-- Name: insertar_usuario(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION insertar_usuario(parametros text[]) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id_usuario bigint := 0;
 
  _ci integer := cast(parametros[1] AS integer);
  _ci_expedido character varying := cast(parametros[2] AS character varying);
  _nombres character varying := cast(parametros[3] AS character varying);
  _ap_paterno character varying := cast(parametros[4] AS character varying);
  _ap_materno character varying := cast(parametros[5] AS character varying);
  _telefono character varying := cast(parametros[6] AS character varying);
  _tel_celular character varying := cast(parametros[7] AS character varying);
  _email character varying := cast(parametros[8] AS character varying);
  _direccion character varying := cast(parametros[9] AS character varying);
  _datos_adicionales character varying := cast(parametros[10] AS character varying);
  _contrasenia character varying := cast(parametros[11] AS character varying);
  _nombre_usuario character varying := cast(parametros[12] AS character varying);
  _id_rol integer := cast(parametros[13] AS integer);
  _usuario_activo boolean := cast(parametros[14] AS boolean);
BEGIN
	INSERT INTO usuarios (
	  ci,
	  ci_expedido,
	  nombres,
	  ap_paterno,
	  ap_materno,
	  telefono,
	  tel_celular,
	  email,
	  direccion,
	  datos_adicionales,
	  contrasenia,
	  nombre_usuario,
	  id_rol,
	  usuario_activo
	)
	VALUES (
	  _ci,
	  _ci_expedido,
	  _nombres,
	  _ap_paterno,
	  _ap_materno,
	  _telefono,
	  _tel_celular,
	  _email,
	  _direccion,
	  _datos_adicionales,
	  MD5(_contrasenia),
	  _nombre_usuario,
	  _id_rol,
	  _usuario_activo
	)
	RETURNING id_usuario into _id_usuario;
--	EXCEPTION
--	  WHEN raise exception THEN
--	   return false;

	RETURN _id_usuario;
END $$;


ALTER FUNCTION public.insertar_usuario(parametros text[]) OWNER TO postgres;

--
-- TOC entry 175 (class 1259 OID 19221)
-- Name: permisos; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE permisos (
    id_permiso integer NOT NULL,
    nombre_permiso character varying NOT NULL
);


ALTER TABLE permisos OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 19227)
-- Name: obtener_permisos(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION obtener_permisos(_id_usuario bigint) RETURNS SETOF permisos
    LANGUAGE sql
    AS $$
	select p.id_permiso, p.nombre_permiso
	from usuarios as u
	join roles as r on u.id_rol = r.id_rol
	join roles_permisos as rp on rp.id_rol = r.id_rol
	join permisos as p on p.id_permiso = rp.id_permiso
	where u.id_usuario = _id_usuario;
$$;


ALTER FUNCTION public.obtener_permisos(_id_usuario bigint) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 19228)
-- Name: pagar_plan_pago(anyarray, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pagar_plan_pago(ids_plan_pago anyarray, _id_credito bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  estado_operacion bigint;
  number_strings integer := array_length(ids_plan_pago, 1);
  indice_ids integer := 1;
  numero_cuentas_pagadas integer := 0;
BEGIN
	WHILE indice_ids <= number_strings LOOP  
		RAISE NOTICE '%', ids_plan_pago[indice_ids];  
		UPDATE plan_pagos
			SET pagado = true,
			fecha_pagado = now()
			WHERE id_plan_pago = ids_plan_pago[indice_ids]::bigint;
		indice_ids = indice_ids + 1;
	END LOOP; 

	SELECT count(*) INTO numero_cuentas_pagadas
	FROM plan_pagos
	WHERE id_credito = _id_credito AND pagado = false;

	-- Si ya se terminó de pagar las cuentas, se debe desactivar el crédito para permitir
	-- a la persona tener un nuevo crédito.
	IF numero_cuentas_pagadas = 0 THEN
		UPDATE creditos
		SET credito_activo = false
		WHERE id_credito = _id_credito;
	END IF;

	RETURN estado_operacion;
END;
$$;


ALTER FUNCTION public.pagar_plan_pago(ids_plan_pago anyarray, _id_credito bigint) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 19229)
-- Name: reporte_comprobante_plan_pagos(bigint, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION reporte_comprobante_plan_pagos(_id_persona bigint, _ids_plan_pagos character varying) RETURNS TABLE(numero_cuota integer, fecha_vencimiento_imprimir character varying, saldo_capital real, capital real, interes real, otros_cargos real, total_cuota real, cuenta_pendiente text)
    LANGUAGE plpgsql
    AS $$
DECLARE
	sql text := '';
BEGIN
	sql := 'SELECT pp.numero_cuota,
		pp.fecha_vencimiento_imprimir, 
		pp.saldo_capital::real,
		pp.capital::real,
		pp.interes::real,
		pp.otros_cargos::real,
		pp.total_cuota::real,
		CASE
		    WHEN pp.pagado THEN ''Si''
		    ELSE ''No''
		END AS cuenta_pendiente
	FROM persona_credito AS pc
	INNER JOIN creditos AS cr ON pc.id_credito = cr.id_credito
	INNER JOIN plan_pagos AS pp ON pp.id_credito = cr.id_credito
	WHERE cr.credito_activo = TRUE
	AND pc.id_persona = ' || _id_persona ||
	' AND pc.tipo_persona = ''CLIENTE''
	AND pp.id_plan_pago IN (' || _ids_plan_pagos || ')
	ORDER BY pp.id_plan_pago';

	RAISE NOTICE '%', sql; 
	RETURN QUERY EXECUTE sql;	
END
$$;


ALTER FUNCTION public.reporte_comprobante_plan_pagos(_id_persona bigint, _ids_plan_pagos character varying) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 19230)
-- Name: reporte_plan_pago(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION reporte_plan_pago(_id_persona bigint) RETURNS TABLE(couta integer, fecha_vencimiento_imprimir character varying, saldo_capital character varying, capital character varying, interes character varying, otros_cargos character varying, total_cuota character varying)
    LANGUAGE sql
    AS $$
	SELECT pp.numero_cuota, pp.fecha_vencimiento_imprimir, 
		pp.saldo_capital, pp.capital, pp.interes, pp.otros_cargos, pp.total_cuota
		FROM persona_credito AS pc
	INNER JOIN creditos AS cr ON pc.id_credito = cr.id_credito
	INNER JOIN plan_pagos AS pp ON pp.id_credito = cr.id_credito
	WHERE pc.id_persona = _id_persona AND cr.credito_activo = TRUE
	AND pc.tipo_persona = 'CLIENTE'
	ORDER BY pp.id_plan_pago;
$$;


ALTER FUNCTION public.reporte_plan_pago(_id_persona bigint) OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 19231)
-- Name: verificar_cliente_termino_de_pagar_su_credito(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION verificar_cliente_termino_de_pagar_su_credito(_id_credito bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  _credito_pagado boolean := false;
  _cantidad_registro_totales integer := 0;
  _cantidad_registro_pagados integer := 0;
BEGIN
	SELECT count(*) INTO _cantidad_registro_totales
	FROM plan_pagos
	WHERE id_credito = _id_credito;

	SELECT count(*) INTO _cantidad_registro_pagados
	FROM plan_pagos
	WHERE id_credito = _id_credito
	AND pagado = true ;

	IF _cantidad_registro_totales =  _cantidad_registro_pagados THEN
		_credito_pagado = true;
	ELSE
		_credito_pagado = false;
	END IF;
	
	RETURN _credito_pagado;
END $$;


ALTER FUNCTION public.verificar_cliente_termino_de_pagar_su_credito(_id_credito bigint) OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 19232)
-- Name: verificar_fecha_vencimiento_plan_pagos(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION verificar_fecha_vencimiento_plan_pagos(_id_credito bigint) RETURNS bigint
    LANGUAGE sql
    AS $$
	select count(id_plan_pago) from plan_pagos
	where id_credito = _id_credito
	and fecha_vencimiento < now() and pagado = false;
$$;


ALTER FUNCTION public.verificar_fecha_vencimiento_plan_pagos(_id_credito bigint) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 19233)
-- Name: verificar_persona_existe_en_firmas_contrato(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION verificar_persona_existe_en_firmas_contrato(_id_persona bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	_cantidad_personas_encontradas integer := 0;
BEGIN
	SELECT count(*) INTO _cantidad_personas_encontradas 
	FROM firmas_contratos
	WHERE id_persona = _id_persona;
	
	RETURN 	_cantidad_personas_encontradas;
END
$$;


ALTER FUNCTION public.verificar_persona_existe_en_firmas_contrato(_id_persona bigint) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 19234)
-- Name: verificar_usuario(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION verificar_usuario(_nombre_usuario character varying, _contrasenia character varying) RETURNS bigint
    LANGUAGE sql
    AS $$
	SELECT u.id_usuario
		FROM usuarios u
		WHERE u.nombre_usuario = _nombre_usuario AND u.contrasenia = MD5(_contrasenia)
		AND u.usuario_activo = true;
$$;


ALTER FUNCTION public.verificar_usuario(_nombre_usuario character varying, _contrasenia character varying) OWNER TO postgres;

--
-- TOC entry 176 (class 1259 OID 19235)
-- Name: configuraciones; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE configuraciones (
    id_configuracion integer NOT NULL,
    ruta_visor_pdf character varying,
    ruta_destino_archivos_pdf character varying,
    solo_guadar_archivos_pdf boolean DEFAULT false,
    ruta_programas_pg character varying
);


ALTER TABLE configuraciones OWNER TO postgres;

--
-- TOC entry 177 (class 1259 OID 19242)
-- Name: configuraciones_id_configuracion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE configuraciones_id_configuracion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE configuraciones_id_configuracion_seq OWNER TO postgres;

--
-- TOC entry 2232 (class 0 OID 0)
-- Dependencies: 177
-- Name: configuraciones_id_configuracion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE configuraciones_id_configuracion_seq OWNED BY configuraciones.id_configuracion;


--
-- TOC entry 178 (class 1259 OID 19244)
-- Name: contratos; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE contratos (
    id_credito bigint NOT NULL,
    contrato_texto_html character varying,
    datos_personas_firmas character varying
);


ALTER TABLE contratos OWNER TO postgres;

--
-- TOC entry 2233 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN contratos.datos_personas_firmas; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN contratos.datos_personas_firmas IS 'Este campo contiene los IDs de las personas que firman al pie del contrato.
los IDs están separados por comas por si alguna vez se necesita saber otros datos de las personas que firmaron el contrato como acreedores.';


--
-- TOC entry 179 (class 1259 OID 19250)
-- Name: creditos; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE creditos (
    id_credito bigint NOT NULL,
    id_usuario bigint NOT NULL,
    fecha_registro timestamp with time zone DEFAULT now() NOT NULL,
    fecha_primer_pago date,
    metodo_generacion character varying,
    moneda character varying,
    num_cuotas smallint,
    frecuencia_pagos smallint,
    importe real,
    otros_pagos real,
    interes real,
    tipo_interes character varying,
    credito_activo boolean DEFAULT false NOT NULL
);


ALTER TABLE creditos OWNER TO postgres;

--
-- TOC entry 2234 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN creditos.credito_activo; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN creditos.credito_activo IS 'Si el campo es verdadero, signifca que el crédito aún no fue pagado.
Si el campo en falso, significa que el crédito ya fue pagado.';


--
-- TOC entry 180 (class 1259 OID 19258)
-- Name: creditos_id_credito_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE creditos_id_credito_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE creditos_id_credito_seq OWNER TO postgres;

--
-- TOC entry 2235 (class 0 OID 0)
-- Dependencies: 180
-- Name: creditos_id_credito_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE creditos_id_credito_seq OWNED BY creditos.id_credito;


--
-- TOC entry 181 (class 1259 OID 19260)
-- Name: firmas_contratos; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE firmas_contratos (
    id_persona bigint NOT NULL,
    tipo_firma_contrato character varying,
    es_acreedor_representante boolean DEFAULT false NOT NULL
);


ALTER TABLE firmas_contratos OWNER TO postgres;

--
-- TOC entry 182 (class 1259 OID 19267)
-- Name: garantias; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE garantias (
    id_garantia bigint NOT NULL,
    id_credito bigint,
    nombre_garantia character varying,
    descripcion_garantia text,
    tipo_garantia character varying
);


ALTER TABLE garantias OWNER TO postgres;

--
-- TOC entry 183 (class 1259 OID 19273)
-- Name: garantias_id_garantia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE garantias_id_garantia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE garantias_id_garantia_seq OWNER TO postgres;

--
-- TOC entry 2236 (class 0 OID 0)
-- Dependencies: 183
-- Name: garantias_id_garantia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE garantias_id_garantia_seq OWNED BY garantias.id_garantia;


--
-- TOC entry 184 (class 1259 OID 19275)
-- Name: historial_creditos; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE historial_creditos (
    id_historial_credito bigint NOT NULL,
    id_credito bigint NOT NULL,
    id_usuario bigint NOT NULL,
    fecha_cambio timestamp with time zone DEFAULT now() NOT NULL,
    motivo_cambio text NOT NULL,
    credito_activo_historico boolean NOT NULL,
    tipo_cambio character varying NOT NULL
);


ALTER TABLE historial_creditos OWNER TO postgres;

--
-- TOC entry 2237 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN historial_creditos.credito_activo_historico; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN historial_creditos.credito_activo_historico IS 'Corresponde al campo <<credito_activo>> de la tabla <<creditos>>.
Es el estado anterior al cambio realizado en el campo <<credito_activo>>.
Puede ser que por algún error se desee anular un crédito y por algún motivo reactivarlo en algún momento, para estos cambios es que se guarda el histórico de los cambios realizados.';


--
-- TOC entry 185 (class 1259 OID 19282)
-- Name: historial_creditos_id_historial_credito_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE historial_creditos_id_historial_credito_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE historial_creditos_id_historial_credito_seq OWNER TO postgres;

--
-- TOC entry 2238 (class 0 OID 0)
-- Dependencies: 185
-- Name: historial_creditos_id_historial_credito_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE historial_creditos_id_historial_credito_seq OWNED BY historial_creditos.id_historial_credito;


--
-- TOC entry 186 (class 1259 OID 19284)
-- Name: historial_personas; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE historial_personas (
    id_historial_personas bigint NOT NULL,
    id_persona bigint NOT NULL,
    ci integer,
    ci_expedido character varying,
    nombres character varying,
    ap_paterno character varying,
    ap_materno character varying,
    sexo character(1),
    fecha_nacimiento date,
    telefono character varying,
    tel_celular character varying,
    email character varying,
    ocupacion character varying,
    datos_adicionales character varying,
    calle_domicilio character varying,
    numero_calle_domicilio integer,
    zona_domicilio character varying,
    ciudad_domicilio character varying,
    estado_civil character varying,
    id_usuario bigint NOT NULL,
    fecha_cambio timestamp with time zone DEFAULT now() NOT NULL,
    tipo_cambio character varying NOT NULL,
    motivo_cambio text NOT NULL
);


ALTER TABLE historial_personas OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 19291)
-- Name: historial_personas_id_historial_personas_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE historial_personas_id_historial_personas_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE historial_personas_id_historial_personas_seq OWNER TO postgres;

--
-- TOC entry 2239 (class 0 OID 0)
-- Dependencies: 187
-- Name: historial_personas_id_historial_personas_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE historial_personas_id_historial_personas_seq OWNED BY historial_personas.id_historial_personas;


--
-- TOC entry 188 (class 1259 OID 19293)
-- Name: permisos_id_permiso_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE permisos_id_permiso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE permisos_id_permiso_seq OWNER TO postgres;

--
-- TOC entry 2240 (class 0 OID 0)
-- Dependencies: 188
-- Name: permisos_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE permisos_id_permiso_seq OWNED BY permisos.id_permiso;


--
-- TOC entry 189 (class 1259 OID 19295)
-- Name: persona_credito; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE persona_credito (
    id_persona bigint NOT NULL,
    id_credito bigint NOT NULL,
    tipo_persona character varying
);


ALTER TABLE persona_credito OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 19301)
-- Name: personas; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE personas (
    id_persona bigint NOT NULL,
    ci integer,
    ci_expedido character varying,
    nombres character varying,
    ap_paterno character varying,
    ap_materno character varying,
    sexo character(1),
    fecha_nacimiento date,
    telefono character varying,
    tel_celular character varying,
    email character varying,
    ocupacion character varying,
    datos_adicionales character varying,
    calle_domicilio character varying,
    numero_calle_domicilio integer,
    zona_domicilio character varying,
    ciudad_domicilio character varying,
    estado_civil character varying
);


ALTER TABLE personas OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 19307)
-- Name: personas_id_persona_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE personas_id_persona_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE personas_id_persona_seq OWNER TO postgres;

--
-- TOC entry 2241 (class 0 OID 0)
-- Dependencies: 191
-- Name: personas_id_persona_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE personas_id_persona_seq OWNED BY personas.id_persona;


--
-- TOC entry 192 (class 1259 OID 19309)
-- Name: plan_pagos_id_plan_pagos_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE plan_pagos_id_plan_pagos_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE plan_pagos_id_plan_pagos_seq OWNER TO postgres;

--
-- TOC entry 2242 (class 0 OID 0)
-- Dependencies: 192
-- Name: plan_pagos_id_plan_pagos_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE plan_pagos_id_plan_pagos_seq OWNED BY plan_pagos.id_plan_pago;


--
-- TOC entry 193 (class 1259 OID 19311)
-- Name: reporte_persona_con_credito_activo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW reporte_persona_con_credito_activo AS
 SELECT p.id_persona,
    ((p.ci || ' '::text) || (p.ci_expedido)::text) AS ci,
    (((((p.ap_paterno)::text || ' '::text) || (p.ap_materno)::text) || ' '::text) || (p.nombres)::text) AS nombre_cliente,
    p.tel_celular,
    p.calle_domicilio,
    p.numero_calle_domicilio,
    p.zona_domicilio,
    p.ciudad_domicilio,
    p.estado_civil,
    c.importe,
    c.num_cuotas,
    pp.id_credito,
    pp.numero_cuota AS num_cuota,
    pp.fecha_vencimiento_imprimir,
    pp.saldo_capital,
    pp.capital,
    pp.interes,
    pp.total_cuota,
        CASE
            WHEN pp.pagado THEN 'Pagado'::text
            ELSE 'Pendiente'::text
        END AS cuenta_pendiente,
    c.fecha_registro
   FROM (((personas p
     JOIN persona_credito pc ON ((p.id_persona = pc.id_persona)))
     JOIN creditos c ON ((pc.id_credito = c.id_credito)))
     JOIN plan_pagos pp ON ((pp.id_credito = pc.id_credito)))
  WHERE ((c.credito_activo = true) AND ((pc.tipo_persona)::text = 'CLIENTE'::text))
  ORDER BY pp.id_plan_pago, pp.fecha_vencimiento;


ALTER TABLE reporte_persona_con_credito_activo OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 19316)
-- Name: reporte_persona_con_credito_en_mora; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW reporte_persona_con_credito_en_mora AS
 SELECT p.id_persona,
    ((p.ci || ' '::text) || (p.ci_expedido)::text) AS ci,
    (((((p.ap_paterno)::text || ' '::text) || (p.ap_materno)::text) || ' '::text) || (p.nombres)::text) AS nombre_cliente,
    p.tel_celular,
    p.calle_domicilio,
    p.numero_calle_domicilio,
    p.zona_domicilio,
    p.ciudad_domicilio,
    p.estado_civil,
    c.importe,
    c.num_cuotas,
    pp.id_credito,
    pp.numero_cuota AS num_cuota,
    pp.fecha_vencimiento_imprimir,
    pp.saldo_capital,
    pp.capital,
    pp.interes,
    pp.total_cuota,
        CASE
            WHEN pp.pagado THEN 'Pagado'::text
            ELSE 'Pendiente'::text
        END AS cuenta_pendiente,
        CASE
            WHEN (pp.fecha_vencimiento < now()) THEN 'En mora'::text
            ELSE ''::text
        END AS pago_en_mora,
    c.fecha_registro
   FROM (((personas p
     JOIN persona_credito pc ON ((p.id_persona = pc.id_persona)))
     JOIN creditos c ON ((pc.id_credito = c.id_credito)))
     JOIN plan_pagos pp ON ((pp.id_credito = pc.id_credito)))
  WHERE (((c.credito_activo = true) AND ((pc.tipo_persona)::text = 'CLIENTE'::text)) AND (verificar_fecha_vencimiento_plan_pagos(c.id_credito) > 0))
  ORDER BY pp.id_plan_pago, pp.fecha_vencimiento;


ALTER TABLE reporte_persona_con_credito_en_mora OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 19321)
-- Name: reporte_personas_con_creditos_pagados; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW reporte_personas_con_creditos_pagados AS
 SELECT p.id_persona,
    ((p.ci || ' '::text) || (p.ci_expedido)::text) AS ci,
    (((((p.ap_paterno)::text || ' '::text) || (p.ap_materno)::text) || ' '::text) || (p.nombres)::text) AS nombre_cliente,
    p.tel_celular,
    p.calle_domicilio,
    p.numero_calle_domicilio,
    p.zona_domicilio,
    p.ciudad_domicilio,
    p.estado_civil,
    c.importe,
    c.num_cuotas,
    pp.id_credito,
    pp.numero_cuota AS num_cuota,
    pp.fecha_vencimiento_imprimir,
    pp.saldo_capital,
    pp.capital,
    pp.interes,
    pp.total_cuota,
        CASE
            WHEN pp.pagado THEN 'Pagado'::text
            ELSE 'Pendiente'::text
        END AS cuenta_pendiente,
    c.fecha_registro
   FROM (((personas p
     JOIN persona_credito pc ON ((p.id_persona = pc.id_persona)))
     JOIN creditos c ON ((pc.id_credito = c.id_credito)))
     JOIN plan_pagos pp ON ((pp.id_credito = pc.id_credito)))
  WHERE (((c.credito_activo = false) AND ((pc.tipo_persona)::text = 'CLIENTE'::text)) AND verificar_cliente_termino_de_pagar_su_credito(c.id_credito))
  ORDER BY pp.id_plan_pago, pp.fecha_vencimiento;


ALTER TABLE reporte_personas_con_creditos_pagados OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 19326)
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE roles (
    id_rol integer NOT NULL,
    rol character varying NOT NULL
);


ALTER TABLE roles OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 19332)
-- Name: roles_permisos; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE roles_permisos (
    id_rol_permiso integer NOT NULL,
    id_rol integer NOT NULL,
    id_permiso integer NOT NULL
);


ALTER TABLE roles_permisos OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 19335)
-- Name: roles_permisos_id_rol_permiso_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE roles_permisos_id_rol_permiso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE roles_permisos_id_rol_permiso_seq OWNER TO postgres;

--
-- TOC entry 2243 (class 0 OID 0)
-- Dependencies: 198
-- Name: roles_permisos_id_rol_permiso_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE roles_permisos_id_rol_permiso_seq OWNED BY roles_permisos.id_rol_permiso;


--
-- TOC entry 199 (class 1259 OID 19337)
-- Name: tipos_firmas_contratos; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tipos_firmas_contratos (
    id_tipo_firma_contrato integer NOT NULL,
    tipo_firma_contrato character varying
);


ALTER TABLE tipos_firmas_contratos OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 19343)
-- Name: tipos_firmas_contratos_id_tipo_firma_contrato_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tipos_firmas_contratos_id_tipo_firma_contrato_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tipos_firmas_contratos_id_tipo_firma_contrato_seq OWNER TO postgres;

--
-- TOC entry 2244 (class 0 OID 0)
-- Dependencies: 200
-- Name: tipos_firmas_contratos_id_tipo_firma_contrato_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tipos_firmas_contratos_id_tipo_firma_contrato_seq OWNED BY tipos_firmas_contratos.id_tipo_firma_contrato;


--
-- TOC entry 201 (class 1259 OID 19345)
-- Name: totales_plan_pagos; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE totales_plan_pagos (
    id_credito bigint NOT NULL,
    total_capital character varying NOT NULL,
    total_interes character varying NOT NULL,
    total_otros_cargos character varying DEFAULT 0 NOT NULL,
    total_cuota character varying NOT NULL
);


ALTER TABLE totales_plan_pagos OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 19352)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE usuarios (
    id_usuario bigint NOT NULL,
    ci integer,
    ci_expedido character varying,
    nombres character varying,
    ap_paterno character varying,
    ap_materno character varying,
    telefono character varying,
    tel_celular character varying,
    email character varying,
    direccion character varying,
    datos_adicionales character varying,
    contrasenia character varying NOT NULL,
    nombre_usuario character varying NOT NULL,
    id_rol integer NOT NULL,
    usuario_activo boolean DEFAULT false
);


ALTER TABLE usuarios OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 19359)
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE usuarios_id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE usuarios_id_usuario_seq OWNER TO postgres;

--
-- TOC entry 2245 (class 0 OID 0)
-- Dependencies: 203
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE usuarios_id_usuario_seq OWNED BY usuarios.id_usuario;


--
-- TOC entry 204 (class 1259 OID 19361)
-- Name: v_get_usuarios; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_get_usuarios AS
 SELECT usuarios.id_usuario,
    usuarios.ci,
    usuarios.ci_expedido,
    usuarios.nombres,
    usuarios.ap_paterno,
    usuarios.ap_materno,
    usuarios.telefono,
    usuarios.tel_celular,
    usuarios.email,
    usuarios.direccion,
    usuarios.datos_adicionales,
    usuarios.contrasenia,
    usuarios.nombre_usuario
   FROM usuarios;


ALTER TABLE v_get_usuarios OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 19365)
-- Name: vista_buscar_persona; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vista_buscar_persona AS
 SELECT (1)::bigint AS id_persona,
    1 AS ci,
    ''::character varying AS nombres,
    ''::character varying AS ap_paterno,
    ''::character varying AS ap_materno,
    ''::character(1) AS sexo,
    '2016-01-01'::date AS fecha_nacimiento,
    1 AS telefono,
    1 AS tel_celular,
    ''::character varying AS email,
    ''::character varying AS direccion,
    ''::character varying AS ocupacion;


ALTER TABLE vista_buscar_persona OWNER TO postgres;

--
-- TOC entry 2049 (class 2604 OID 19369)
-- Name: id_configuracion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY configuraciones ALTER COLUMN id_configuracion SET DEFAULT nextval('configuraciones_id_configuracion_seq'::regclass);


--
-- TOC entry 2052 (class 2604 OID 19370)
-- Name: id_credito; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY creditos ALTER COLUMN id_credito SET DEFAULT nextval('creditos_id_credito_seq'::regclass);


--
-- TOC entry 2054 (class 2604 OID 19371)
-- Name: id_garantia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY garantias ALTER COLUMN id_garantia SET DEFAULT nextval('garantias_id_garantia_seq'::regclass);


--
-- TOC entry 2056 (class 2604 OID 19372)
-- Name: id_historial_credito; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY historial_creditos ALTER COLUMN id_historial_credito SET DEFAULT nextval('historial_creditos_id_historial_credito_seq'::regclass);


--
-- TOC entry 2058 (class 2604 OID 19373)
-- Name: id_historial_personas; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY historial_personas ALTER COLUMN id_historial_personas SET DEFAULT nextval('historial_personas_id_historial_personas_seq'::regclass);


--
-- TOC entry 2047 (class 2604 OID 19374)
-- Name: id_permiso; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY permisos ALTER COLUMN id_permiso SET DEFAULT nextval('permisos_id_permiso_seq'::regclass);


--
-- TOC entry 2059 (class 2604 OID 19375)
-- Name: id_persona; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY personas ALTER COLUMN id_persona SET DEFAULT nextval('personas_id_persona_seq'::regclass);


--
-- TOC entry 2046 (class 2604 OID 19376)
-- Name: id_plan_pago; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY plan_pagos ALTER COLUMN id_plan_pago SET DEFAULT nextval('plan_pagos_id_plan_pagos_seq'::regclass);


--
-- TOC entry 2060 (class 2604 OID 19377)
-- Name: id_rol_permiso; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY roles_permisos ALTER COLUMN id_rol_permiso SET DEFAULT nextval('roles_permisos_id_rol_permiso_seq'::regclass);


--
-- TOC entry 2061 (class 2604 OID 19378)
-- Name: id_tipo_firma_contrato; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipos_firmas_contratos ALTER COLUMN id_tipo_firma_contrato SET DEFAULT nextval('tipos_firmas_contratos_id_tipo_firma_contrato_seq'::regclass);


--
-- TOC entry 2064 (class 2604 OID 19379)
-- Name: id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usuarios ALTER COLUMN id_usuario SET DEFAULT nextval('usuarios_id_usuario_seq'::regclass);


--
-- TOC entry 2074 (class 2606 OID 19381)
-- Name: Credito_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY creditos
    ADD CONSTRAINT "Credito_pkey" PRIMARY KEY (id_credito);


--
-- TOC entry 2088 (class 2606 OID 19383)
-- Name: Persona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY personas
    ADD CONSTRAINT "Persona_pkey" PRIMARY KEY (id_persona);


--
-- TOC entry 2070 (class 2606 OID 19385)
-- Name: configuraciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY configuraciones
    ADD CONSTRAINT configuraciones_pkey PRIMARY KEY (id_configuracion);


--
-- TOC entry 2072 (class 2606 OID 19387)
-- Name: contratos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contratos
    ADD CONSTRAINT contratos_pkey PRIMARY KEY (id_credito);


--
-- TOC entry 2076 (class 2606 OID 19389)
-- Name: firmas_contratos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY firmas_contratos
    ADD CONSTRAINT firmas_contratos_pkey PRIMARY KEY (id_persona);


--
-- TOC entry 2078 (class 2606 OID 19391)
-- Name: firmas_contratos_tipo_firma_contrato_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY firmas_contratos
    ADD CONSTRAINT firmas_contratos_tipo_firma_contrato_key UNIQUE (tipo_firma_contrato);


--
-- TOC entry 2080 (class 2606 OID 19393)
-- Name: garantias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY garantias
    ADD CONSTRAINT garantias_pkey PRIMARY KEY (id_garantia);


--
-- TOC entry 2082 (class 2606 OID 19395)
-- Name: historial_creditos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY historial_creditos
    ADD CONSTRAINT historial_creditos_pkey PRIMARY KEY (id_historial_credito);


--
-- TOC entry 2084 (class 2606 OID 19397)
-- Name: historial_personas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY historial_personas
    ADD CONSTRAINT historial_personas_pkey PRIMARY KEY (id_historial_personas);


--
-- TOC entry 2068 (class 2606 OID 19399)
-- Name: permisos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY permisos
    ADD CONSTRAINT permisos_pkey PRIMARY KEY (id_permiso);


--
-- TOC entry 2086 (class 2606 OID 19401)
-- Name: persona_credito_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY persona_credito
    ADD CONSTRAINT persona_credito_pkey PRIMARY KEY (id_persona, id_credito);


--
-- TOC entry 2090 (class 2606 OID 19403)
-- Name: personas_ci_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY personas
    ADD CONSTRAINT personas_ci_key UNIQUE (ci);


--
-- TOC entry 2066 (class 2606 OID 19405)
-- Name: plan_pagos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY plan_pagos
    ADD CONSTRAINT plan_pagos_pkey PRIMARY KEY (id_plan_pago);


--
-- TOC entry 2094 (class 2606 OID 19407)
-- Name: roles_permisos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY roles_permisos
    ADD CONSTRAINT roles_permisos_pkey PRIMARY KEY (id_rol_permiso);


--
-- TOC entry 2092 (class 2606 OID 19409)
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id_rol);


--
-- TOC entry 2096 (class 2606 OID 19411)
-- Name: tipos_firmas_contratos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipos_firmas_contratos
    ADD CONSTRAINT tipos_firmas_contratos_pkey PRIMARY KEY (id_tipo_firma_contrato);


--
-- TOC entry 2098 (class 2606 OID 19413)
-- Name: totales_plan_pagos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY totales_plan_pagos
    ADD CONSTRAINT totales_plan_pagos_pkey PRIMARY KEY (id_credito);


--
-- TOC entry 2100 (class 2606 OID 19415)
-- Name: usuarios_ci_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usuarios
    ADD CONSTRAINT usuarios_ci_key UNIQUE (ci);


--
-- TOC entry 2102 (class 2606 OID 19417)
-- Name: usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 2104 (class 2606 OID 19418)
-- Name: contratos_id_credito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY contratos
    ADD CONSTRAINT contratos_id_credito_fkey FOREIGN KEY (id_credito) REFERENCES contratos(id_credito);


--
-- TOC entry 2105 (class 2606 OID 19423)
-- Name: firmas_contratos_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY firmas_contratos
    ADD CONSTRAINT firmas_contratos_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES personas(id_persona);


--
-- TOC entry 2106 (class 2606 OID 19428)
-- Name: garantias_id_credito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY garantias
    ADD CONSTRAINT garantias_id_credito_fkey FOREIGN KEY (id_credito) REFERENCES creditos(id_credito);


--
-- TOC entry 2107 (class 2606 OID 19433)
-- Name: persona_credito_id_credito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY persona_credito
    ADD CONSTRAINT persona_credito_id_credito_fkey FOREIGN KEY (id_credito) REFERENCES creditos(id_credito);


--
-- TOC entry 2108 (class 2606 OID 19438)
-- Name: persona_credito_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY persona_credito
    ADD CONSTRAINT persona_credito_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES personas(id_persona);


--
-- TOC entry 2103 (class 2606 OID 19443)
-- Name: plan_pagos_id_credito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY plan_pagos
    ADD CONSTRAINT plan_pagos_id_credito_fkey FOREIGN KEY (id_credito) REFERENCES creditos(id_credito);


--
-- TOC entry 2109 (class 2606 OID 19448)
-- Name: totales_plan_pagos_id_credito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY totales_plan_pagos
    ADD CONSTRAINT totales_plan_pagos_id_credito_fkey FOREIGN KEY (id_credito) REFERENCES creditos(id_credito);


--
-- TOC entry 2230 (class 0 OID 0)
-- Dependencies: 7
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2017-05-15 17:50:21 -04

--
-- PostgreSQL database dump complete
--

