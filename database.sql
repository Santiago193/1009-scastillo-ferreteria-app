--
-- PostgreSQL database dump
--

\restrict KSETyQst3AQYxbqra2rbvmCsVdffcE3qaNLgK9mBLlPX9a3J10JSC3U62fbMPi8

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2026-01-11 19:03:30

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 5099 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- TOC entry 249 (class 1255 OID 18592)
-- Name: trg_compra_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_compra_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Si eliminan una compra, se revierte la suma de inventario
    UPDATE tb_producto
    SET cantidad = cantidad - OLD.cantidad
    WHERE id_producto = OLD.id_producto;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.trg_compra_delete() OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 18593)
-- Name: trg_compra_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_compra_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Cuando se registra una compra, aumentamos el inventario
    UPDATE tb_producto
    SET cantidad = cantidad + NEW.cantidad
    WHERE id_producto = NEW.id_producto;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_compra_insert() OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 18594)
-- Name: trg_compra_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_compra_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Restamos la cantidad anterior y sumamos la nueva
    UPDATE tb_producto
    SET cantidad = cantidad - OLD.cantidad + NEW.cantidad
    WHERE id_producto = NEW.id_producto;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_compra_update() OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 18595)
-- Name: trg_protect_stock(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_protect_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.cantidad < 0 THEN
        RAISE EXCEPTION 'ERROR: El inventario no puede ser negativo (%).', NEW.cantidad;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_protect_stock() OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 18596)
-- Name: trg_total_compra(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_total_compra() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tb_compra
    SET total = (
        SELECT COALESCE(SUM(cantidad * precio_compra), 0)
        FROM tb_compra_detalle
        WHERE id_compra = NEW.id_compra
    )
    WHERE id_compra = NEW.id_compra;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_total_compra() OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 18597)
-- Name: trg_total_venta(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_total_venta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tb_venta
    SET total = (
        SELECT COALESCE(SUM(cantidad * precio_unitario), 0)
        FROM tb_venta_detalle
        WHERE id_venta = NEW.id_venta
    )
    WHERE id_venta = NEW.id_venta;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_total_venta() OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 18598)
-- Name: trg_venta_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_venta_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Si eliminan una venta, se devuelve el stock vendido
    UPDATE tb_producto
    SET cantidad = cantidad + OLD.cantidad
    WHERE id_producto = OLD.id_producto;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.trg_venta_delete() OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 18599)
-- Name: trg_venta_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_venta_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Evitar stock negativo antes de descontar
    IF (SELECT cantidad FROM tb_producto WHERE id_producto = NEW.id_producto) < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente para realizar la venta.';
    END IF;

    UPDATE tb_producto
    SET cantidad = cantidad - NEW.cantidad
    WHERE id_producto = NEW.id_producto;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_venta_insert() OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 18600)
-- Name: trg_venta_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_venta_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    diferencia INTEGER := NEW.cantidad - OLD.cantidad;
BEGIN
    -- Si la diferencia es positiva, se intenta restar más stock
    IF diferencia > 0 THEN
        IF (SELECT cantidad FROM tb_producto WHERE id_producto = NEW.id_producto) < diferencia THEN
            RAISE EXCEPTION 'Stock insuficiente para actualizar la venta.';
        END IF;
    END IF;

    UPDATE tb_producto
    SET cantidad = cantidad - diferencia
    WHERE id_producto = NEW.id_producto;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_venta_update() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 18601)
-- Name: tb_compra; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_compra (
    id_compra integer NOT NULL,
    id_proveedor integer,
    fecha timestamp without time zone DEFAULT now(),
    total numeric(10,2) NOT NULL
);


ALTER TABLE public.tb_compra OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 18607)
-- Name: tb_compra_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_compra_detalle (
    id_detalle integer NOT NULL,
    id_compra integer,
    id_producto integer,
    cantidad integer NOT NULL,
    precio_compra numeric(10,2) NOT NULL
);


ALTER TABLE public.tb_compra_detalle OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 18613)
-- Name: tb_compra_detalle_id_detalle_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_compra_detalle_id_detalle_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_compra_detalle_id_detalle_seq OWNER TO postgres;

--
-- TOC entry 5101 (class 0 OID 0)
-- Dependencies: 221
-- Name: tb_compra_detalle_id_detalle_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_compra_detalle_id_detalle_seq OWNED BY public.tb_compra_detalle.id_detalle;


--
-- TOC entry 222 (class 1259 OID 18614)
-- Name: tb_compra_id_compra_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_compra_id_compra_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_compra_id_compra_seq OWNER TO postgres;

--
-- TOC entry 5102 (class 0 OID 0)
-- Dependencies: 222
-- Name: tb_compra_id_compra_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_compra_id_compra_seq OWNED BY public.tb_compra.id_compra;


--
-- TOC entry 223 (class 1259 OID 18615)
-- Name: tb_empresa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_empresa (
    id_empresa integer NOT NULL,
    nombre character varying(150) NOT NULL,
    slogan character varying(200),
    ruc character varying(20),
    correo character varying(120),
    correo_alt character varying(120),
    telefono1 character varying(30),
    telefono2 character varying(30),
    direccion character varying(200),
    ciudad character varying(80),
    sitio_web character varying(150),
    logo_url character varying(300),
    descripcion text,
    facebook character varying(200),
    instagram character varying(200)
);


ALTER TABLE public.tb_empresa OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 18622)
-- Name: tb_empresa_id_empresa_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_empresa_id_empresa_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_empresa_id_empresa_seq OWNER TO postgres;

--
-- TOC entry 5103 (class 0 OID 0)
-- Dependencies: 224
-- Name: tb_empresa_id_empresa_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_empresa_id_empresa_seq OWNED BY public.tb_empresa.id_empresa;


--
-- TOC entry 225 (class 1259 OID 18623)
-- Name: tb_estadocivil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_estadocivil (
    id_estadocivil integer NOT NULL,
    descripcion character varying(50)
);


ALTER TABLE public.tb_estadocivil OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 18627)
-- Name: tb_estadocivil_id_estadocivil_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_estadocivil_id_estadocivil_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_estadocivil_id_estadocivil_seq OWNER TO postgres;

--
-- TOC entry 5104 (class 0 OID 0)
-- Dependencies: 226
-- Name: tb_estadocivil_id_estadocivil_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_estadocivil_id_estadocivil_seq OWNED BY public.tb_estadocivil.id_estadocivil;


--
-- TOC entry 227 (class 1259 OID 18628)
-- Name: tb_iva; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_iva (
    id_iva integer NOT NULL,
    porcentaje numeric(5,2) NOT NULL,
    fecha_vigencia date NOT NULL
);


ALTER TABLE public.tb_iva OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 18634)
-- Name: tb_iva_id_iva_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_iva_id_iva_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_iva_id_iva_seq OWNER TO postgres;

--
-- TOC entry 5105 (class 0 OID 0)
-- Dependencies: 228
-- Name: tb_iva_id_iva_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_iva_id_iva_seq OWNED BY public.tb_iva.id_iva;


--
-- TOC entry 229 (class 1259 OID 18635)
-- Name: tb_pagina; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_pagina (
    id_pagina integer NOT NULL,
    nombre character varying(80),
    url character varying(250)
);


ALTER TABLE public.tb_pagina OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 18639)
-- Name: tb_pagina_id_pagina_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_pagina_id_pagina_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_pagina_id_pagina_seq OWNER TO postgres;

--
-- TOC entry 5106 (class 0 OID 0)
-- Dependencies: 230
-- Name: tb_pagina_id_pagina_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_pagina_id_pagina_seq OWNED BY public.tb_pagina.id_pagina;


--
-- TOC entry 231 (class 1259 OID 18640)
-- Name: tb_perfil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_perfil (
    id_perfil integer NOT NULL,
    nombre character varying(30) NOT NULL
);


ALTER TABLE public.tb_perfil OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 18645)
-- Name: tb_perfil_id_perfil_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_perfil_id_perfil_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_perfil_id_perfil_seq OWNER TO postgres;

--
-- TOC entry 5107 (class 0 OID 0)
-- Dependencies: 232
-- Name: tb_perfil_id_perfil_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_perfil_id_perfil_seq OWNED BY public.tb_perfil.id_perfil;


--
-- TOC entry 233 (class 1259 OID 18646)
-- Name: tb_perfilpagina; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_perfilpagina (
    id_perfilpagina integer NOT NULL,
    id_perfil integer NOT NULL,
    id_pagina integer NOT NULL
);


ALTER TABLE public.tb_perfilpagina OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 18652)
-- Name: tb_perfilpagina_id_perfilpagina_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_perfilpagina_id_perfilpagina_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_perfilpagina_id_perfilpagina_seq OWNER TO postgres;

--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 234
-- Name: tb_perfilpagina_id_perfilpagina_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_perfilpagina_id_perfilpagina_seq OWNED BY public.tb_perfilpagina.id_perfilpagina;


--
-- TOC entry 235 (class 1259 OID 18653)
-- Name: tb_producto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_producto (
    id_producto integer NOT NULL,
    codigo_barra character varying(50) NOT NULL,
    nombre character varying(150) NOT NULL,
    cantidad integer DEFAULT 0 NOT NULL,
    precio_venta numeric(10,2) NOT NULL,
    id_ubicacion integer,
    stock_minimo integer DEFAULT 5,
    marca character varying(100),
    unidad character varying(20),
    descripcion text,
    imagen_url character varying(300),
    activo boolean DEFAULT true
);


ALTER TABLE public.tb_producto OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 18665)
-- Name: tb_producto_id_producto_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_producto_id_producto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_producto_id_producto_seq OWNER TO postgres;

--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 236
-- Name: tb_producto_id_producto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_producto_id_producto_seq OWNED BY public.tb_producto.id_producto;


--
-- TOC entry 237 (class 1259 OID 18666)
-- Name: tb_producto_proveedor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_producto_proveedor (
    id integer NOT NULL,
    id_producto integer,
    id_proveedor integer,
    precio_compra numeric(10,2) NOT NULL
);


ALTER TABLE public.tb_producto_proveedor OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 18671)
-- Name: tb_producto_proveedor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_producto_proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_producto_proveedor_id_seq OWNER TO postgres;

--
-- TOC entry 5110 (class 0 OID 0)
-- Dependencies: 238
-- Name: tb_producto_proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_producto_proveedor_id_seq OWNED BY public.tb_producto_proveedor.id;


--
-- TOC entry 239 (class 1259 OID 18672)
-- Name: tb_proveedor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_proveedor (
    id_proveedor integer NOT NULL,
    nombre character varying(150) NOT NULL,
    telefono character varying(50),
    correo character varying(120),
    ubicacion character varying(200)
);


ALTER TABLE public.tb_proveedor OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 18679)
-- Name: tb_proveedor_id_proveedor_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_proveedor_id_proveedor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_proveedor_id_proveedor_seq OWNER TO postgres;

--
-- TOC entry 5111 (class 0 OID 0)
-- Dependencies: 240
-- Name: tb_proveedor_id_proveedor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_proveedor_id_proveedor_seq OWNED BY public.tb_proveedor.id_proveedor;


--
-- TOC entry 241 (class 1259 OID 18680)
-- Name: tb_ubicacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_ubicacion (
    id_ubicacion integer NOT NULL,
    estanteria integer NOT NULL,
    columna character varying(10) NOT NULL,
    fila integer NOT NULL
);


ALTER TABLE public.tb_ubicacion OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 18687)
-- Name: tb_ubicacion_id_ubicacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_ubicacion_id_ubicacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_ubicacion_id_ubicacion_seq OWNER TO postgres;

--
-- TOC entry 5112 (class 0 OID 0)
-- Dependencies: 242
-- Name: tb_ubicacion_id_ubicacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_ubicacion_id_ubicacion_seq OWNED BY public.tb_ubicacion.id_ubicacion;


--
-- TOC entry 243 (class 1259 OID 18688)
-- Name: tb_usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_usuario (
    id_usuario integer NOT NULL,
    nombre character varying(80) NOT NULL,
    apellido character varying(80) NOT NULL,
    correo character varying(120) NOT NULL,
    contrasena character varying(200) NOT NULL,
    id_estadocivil integer,
    id_perfil integer NOT NULL,
    bloqueado boolean DEFAULT false
);


ALTER TABLE public.tb_usuario OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 18698)
-- Name: tb_usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_usuario_id_usuario_seq OWNER TO postgres;

--
-- TOC entry 5113 (class 0 OID 0)
-- Dependencies: 244
-- Name: tb_usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_usuario_id_usuario_seq OWNED BY public.tb_usuario.id_usuario;


--
-- TOC entry 245 (class 1259 OID 18699)
-- Name: tb_venta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_venta (
    id_venta integer NOT NULL,
    fecha timestamp without time zone DEFAULT now(),
    total numeric(10,2) NOT NULL,
    id_usuario integer
);


ALTER TABLE public.tb_venta OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 18705)
-- Name: tb_venta_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_venta_detalle (
    id_detalle integer NOT NULL,
    id_venta integer,
    id_producto integer,
    cantidad integer NOT NULL,
    precio_unitario numeric(10,2) NOT NULL
);


ALTER TABLE public.tb_venta_detalle OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 18711)
-- Name: tb_venta_detalle_id_detalle_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_venta_detalle_id_detalle_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_venta_detalle_id_detalle_seq OWNER TO postgres;

--
-- TOC entry 5114 (class 0 OID 0)
-- Dependencies: 247
-- Name: tb_venta_detalle_id_detalle_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_venta_detalle_id_detalle_seq OWNED BY public.tb_venta_detalle.id_detalle;


--
-- TOC entry 248 (class 1259 OID 18712)
-- Name: tb_venta_id_venta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_venta_id_venta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_venta_id_venta_seq OWNER TO postgres;

--
-- TOC entry 5115 (class 0 OID 0)
-- Dependencies: 248
-- Name: tb_venta_id_venta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_venta_id_venta_seq OWNED BY public.tb_venta.id_venta;


--
-- TOC entry 4834 (class 2604 OID 18713)
-- Name: tb_compra id_compra; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_compra ALTER COLUMN id_compra SET DEFAULT nextval('public.tb_compra_id_compra_seq'::regclass);


--
-- TOC entry 4836 (class 2604 OID 18714)
-- Name: tb_compra_detalle id_detalle; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_compra_detalle ALTER COLUMN id_detalle SET DEFAULT nextval('public.tb_compra_detalle_id_detalle_seq'::regclass);


--
-- TOC entry 4837 (class 2604 OID 18715)
-- Name: tb_empresa id_empresa; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_empresa ALTER COLUMN id_empresa SET DEFAULT nextval('public.tb_empresa_id_empresa_seq'::regclass);


--
-- TOC entry 4838 (class 2604 OID 18716)
-- Name: tb_estadocivil id_estadocivil; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_estadocivil ALTER COLUMN id_estadocivil SET DEFAULT nextval('public.tb_estadocivil_id_estadocivil_seq'::regclass);


--
-- TOC entry 4839 (class 2604 OID 18717)
-- Name: tb_iva id_iva; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_iva ALTER COLUMN id_iva SET DEFAULT nextval('public.tb_iva_id_iva_seq'::regclass);


--
-- TOC entry 4840 (class 2604 OID 18718)
-- Name: tb_pagina id_pagina; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_pagina ALTER COLUMN id_pagina SET DEFAULT nextval('public.tb_pagina_id_pagina_seq'::regclass);


--
-- TOC entry 4841 (class 2604 OID 18719)
-- Name: tb_perfil id_perfil; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_perfil ALTER COLUMN id_perfil SET DEFAULT nextval('public.tb_perfil_id_perfil_seq'::regclass);


--
-- TOC entry 4842 (class 2604 OID 18720)
-- Name: tb_perfilpagina id_perfilpagina; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_perfilpagina ALTER COLUMN id_perfilpagina SET DEFAULT nextval('public.tb_perfilpagina_id_perfilpagina_seq'::regclass);


--
-- TOC entry 4843 (class 2604 OID 18721)
-- Name: tb_producto id_producto; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_producto ALTER COLUMN id_producto SET DEFAULT nextval('public.tb_producto_id_producto_seq'::regclass);


--
-- TOC entry 4847 (class 2604 OID 18722)
-- Name: tb_producto_proveedor id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_producto_proveedor ALTER COLUMN id SET DEFAULT nextval('public.tb_producto_proveedor_id_seq'::regclass);


--
-- TOC entry 4848 (class 2604 OID 18723)
-- Name: tb_proveedor id_proveedor; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_proveedor ALTER COLUMN id_proveedor SET DEFAULT nextval('public.tb_proveedor_id_proveedor_seq'::regclass);


--
-- TOC entry 4849 (class 2604 OID 18724)
-- Name: tb_ubicacion id_ubicacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_ubicacion ALTER COLUMN id_ubicacion SET DEFAULT nextval('public.tb_ubicacion_id_ubicacion_seq'::regclass);


--
-- TOC entry 4850 (class 2604 OID 18725)
-- Name: tb_usuario id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.tb_usuario_id_usuario_seq'::regclass);


--
-- TOC entry 4852 (class 2604 OID 18726)
-- Name: tb_venta id_venta; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_venta ALTER COLUMN id_venta SET DEFAULT nextval('public.tb_venta_id_venta_seq'::regclass);


--
-- TOC entry 4854 (class 2604 OID 18727)
-- Name: tb_venta_detalle id_detalle; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_venta_detalle ALTER COLUMN id_detalle SET DEFAULT nextval('public.tb_venta_detalle_id_detalle_seq'::regclass);


--
-- TOC entry 5064 (class 0 OID 18601)
-- Dependencies: 219
-- Data for Name: tb_compra; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_compra (id_compra, id_proveedor, fecha, total) FROM stdin;
1	2	2025-12-19 18:02:51.153934	45.00
2	1	2025-12-19 18:04:12.803462	35.20
3	2	2025-12-19 18:06:25.622208	19.60
4	2	2026-01-02 20:05:52.741057	44.00
\.


--
-- TOC entry 5065 (class 0 OID 18607)
-- Dependencies: 220
-- Data for Name: tb_compra_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_compra_detalle (id_detalle, id_compra, id_producto, cantidad, precio_compra) FROM stdin;
1	1	1	50	0.90
2	2	1	40	0.88
3	3	1	20	0.98
4	4	2	55	0.80
\.


--
-- TOC entry 5068 (class 0 OID 18615)
-- Dependencies: 223
-- Data for Name: tb_empresa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_empresa (id_empresa, nombre, slogan, ruc, correo, correo_alt, telefono1, telefono2, direccion, ciudad, sitio_web, logo_url, descripcion, facebook, instagram) FROM stdin;
1	Ferretería el Ejercito 	Todo para construir, reparar y crear.	179284750001	contacto@gmail.com	ventas@gmail.com	0998542367	022345678	Ciudadela Ejercito	Quito	https://www.elejercito.com	images/elejercito.png	Ferreterí­a profesional con más de 20 años de experiencia.	https://facebook.com/eltornillazo	https://instagram.com/eltornillazo
\.


--
-- TOC entry 5070 (class 0 OID 18623)
-- Dependencies: 225
-- Data for Name: tb_estadocivil; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_estadocivil (id_estadocivil, descripcion) FROM stdin;
1	Soltero
2	Casado
3	Divorciado
4	Viudo
\.


--
-- TOC entry 5072 (class 0 OID 18628)
-- Dependencies: 227
-- Data for Name: tb_iva; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_iva (id_iva, porcentaje, fecha_vigencia) FROM stdin;
\.


--
-- TOC entry 5074 (class 0 OID 18635)
-- Dependencies: 229
-- Data for Name: tb_pagina; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_pagina (id_pagina, nombre, url) FROM stdin;
1	Dashboard	http://localhost:8080/ferreteria/paginaadmin/dashboard.jsp
2	Productos	http://localhost:8080/ferreteria/paginaadmin/productos.jsp
3	Compras	http://localhost:8080/ferreteria/paginaadmin/compras.jsp
4	Ventas	http://localhost:8080/ferreteria/paginaadmin/ventas.jsp
5	Reporte Ganancias	http://localhost:8080/ferreteria/paginaadmin/reporte_ganancias.jsp
6	Reporte Inventario	http://localhost:8080/ferreteria/paginaadmin/reporte_inventario.jsp
7	Usuarios	http://localhost:8080/ferreteria/paginaadmin/usuarios.jsp
8	Config Empresa	http://localhost:8080/ferreteria/paginaadmin/config_empresa.jsp
9	Logout	http://localhost:8080/ferreteria/paginaadmin/logout.jsp
10	Dashboard	http://localhost:8080/ferreteria/paginaempleado/dashboard.jsp
11	Productos	http://localhost:8080/ferreteria/paginaempleado/productos.jsp
12	Ventas	http://localhost:8080/ferreteria/paginaempleado/ventas.jsp
14	Reporte Inventario	http://localhost:8080/ferreteria/paginaempleado/reporte_inventario.jsp
15	Logout	http://localhost:8080/ferreteria/paginaempleado/logout.jsp
16	Inicio	http://localhost:8080/ferreteria/paginausuario/inicio.jsp
17	Logout	http://localhost:8080/ferreteria/paginausuario/logout.jsp
\.


--
-- TOC entry 5076 (class 0 OID 18640)
-- Dependencies: 231
-- Data for Name: tb_perfil; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_perfil (id_perfil, nombre) FROM stdin;
1	ADMIN
2	EMPLEADO
3	USUARIO
\.


--
-- TOC entry 5078 (class 0 OID 18646)
-- Dependencies: 233
-- Data for Name: tb_perfilpagina; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_perfilpagina (id_perfilpagina, id_perfil, id_pagina) FROM stdin;
1	1	1
2	1	2
3	1	3
4	1	4
5	1	5
6	1	6
7	1	7
8	1	8
9	1	9
10	2	10
11	2	11
12	2	12
14	2	14
15	2	15
16	3	16
17	3	17
\.


--
-- TOC entry 5080 (class 0 OID 18653)
-- Dependencies: 235
-- Data for Name: tb_producto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_producto (id_producto, codigo_barra, nombre, cantidad, precio_venta, id_ubicacion, stock_minimo, marca, unidad, descripcion, imagen_url, activo) FROM stdin;
3	003	Arroz 1kg	80	1.15	3	30	Don Pepe	kg	prueba3	https://cdn-icons-png.flaticon.com/512/7430/7430210.png	t
1	001	Arroz 1kg	210	1.20	1	20	Súper Arroz	kg	prueba1	https://cdn-icons-png.flaticon.com/512/7430/7430210.png	t
2	002	Arroz 1kg	75	1.20	2	20	Súper Arroz	kg	prueba 2	https://cdn-icons-png.flaticon.com/512/7430/7430210.png	t
\.


--
-- TOC entry 5082 (class 0 OID 18666)
-- Dependencies: 237
-- Data for Name: tb_producto_proveedor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_producto_proveedor (id, id_producto, id_proveedor, precio_compra) FROM stdin;
2	1	1	0.88
1	1	2	0.98
4	2	2	0.80
\.


--
-- TOC entry 5084 (class 0 OID 18672)
-- Dependencies: 239
-- Data for Name: tb_proveedor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_proveedor (id_proveedor, nombre, telefono, correo, ubicacion) FROM stdin;
1	Distribuidora Andina	099111222	andina@mail.com	Quito
2	Comercial El Ahorro	098333444	ahorro@mail.com	Latacunga
3	Proveedora Central	097555666	central@mail.com	Ambato
\.


--
-- TOC entry 5086 (class 0 OID 18680)
-- Dependencies: 241
-- Data for Name: tb_ubicacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_ubicacion (id_ubicacion, estanteria, columna, fila) FROM stdin;
1	1	1	1
2	1	1	2
3	1	2	1
4	2	1	1
5	2	2	3
\.


--
-- TOC entry 5088 (class 0 OID 18688)
-- Dependencies: 243
-- Data for Name: tb_usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_usuario (id_usuario, nombre, apellido, correo, contrasena, id_estadocivil, id_perfil, bloqueado) FROM stdin;
2	Juan	Empleado	empleado@ferreteria.com	1234	2	2	f
3	Carlos	Cliente	cliente@ferreteria.com	1234	3	3	f
4	santiago 	Castillo	admin1@ferreteria.com	123456	1	2	f
1	Admin	Master	admin@ferreteria.com	1234	1	1	f
5	jess	buapa	jess@gmail.com	1234	1	1	f
\.


--
-- TOC entry 5090 (class 0 OID 18699)
-- Dependencies: 245
-- Data for Name: tb_venta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_venta (id_venta, fecha, total, id_usuario) FROM stdin;
1	2026-01-11 18:50:46.42539	36.00	4
\.


--
-- TOC entry 5091 (class 0 OID 18705)
-- Dependencies: 246
-- Data for Name: tb_venta_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_venta_detalle (id_detalle, id_venta, id_producto, cantidad, precio_unitario) FROM stdin;
1	1	2	30	1.20
\.


--
-- TOC entry 5116 (class 0 OID 0)
-- Dependencies: 221
-- Name: tb_compra_detalle_id_detalle_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_compra_detalle_id_detalle_seq', 4, true);


--
-- TOC entry 5117 (class 0 OID 0)
-- Dependencies: 222
-- Name: tb_compra_id_compra_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_compra_id_compra_seq', 4, true);


--
-- TOC entry 5118 (class 0 OID 0)
-- Dependencies: 224
-- Name: tb_empresa_id_empresa_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_empresa_id_empresa_seq', 1, true);


--
-- TOC entry 5119 (class 0 OID 0)
-- Dependencies: 226
-- Name: tb_estadocivil_id_estadocivil_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_estadocivil_id_estadocivil_seq', 4, true);


--
-- TOC entry 5120 (class 0 OID 0)
-- Dependencies: 228
-- Name: tb_iva_id_iva_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_iva_id_iva_seq', 1, false);


--
-- TOC entry 5121 (class 0 OID 0)
-- Dependencies: 230
-- Name: tb_pagina_id_pagina_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_pagina_id_pagina_seq', 1, false);


--
-- TOC entry 5122 (class 0 OID 0)
-- Dependencies: 232
-- Name: tb_perfil_id_perfil_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_perfil_id_perfil_seq', 3, true);


--
-- TOC entry 5123 (class 0 OID 0)
-- Dependencies: 234
-- Name: tb_perfilpagina_id_perfilpagina_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_perfilpagina_id_perfilpagina_seq', 17, true);


--
-- TOC entry 5124 (class 0 OID 0)
-- Dependencies: 236
-- Name: tb_producto_id_producto_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_producto_id_producto_seq', 3, true);


--
-- TOC entry 5125 (class 0 OID 0)
-- Dependencies: 238
-- Name: tb_producto_proveedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_producto_proveedor_id_seq', 4, true);


--
-- TOC entry 5126 (class 0 OID 0)
-- Dependencies: 240
-- Name: tb_proveedor_id_proveedor_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_proveedor_id_proveedor_seq', 3, true);


--
-- TOC entry 5127 (class 0 OID 0)
-- Dependencies: 242
-- Name: tb_ubicacion_id_ubicacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_ubicacion_id_ubicacion_seq', 5, true);


--
-- TOC entry 5128 (class 0 OID 0)
-- Dependencies: 244
-- Name: tb_usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_usuario_id_usuario_seq', 5, true);


--
-- TOC entry 5129 (class 0 OID 0)
-- Dependencies: 247
-- Name: tb_venta_detalle_id_detalle_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_venta_detalle_id_detalle_seq', 1, true);


--
-- TOC entry 5130 (class 0 OID 0)
-- Dependencies: 248
-- Name: tb_venta_id_venta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_venta_id_venta_seq', 1, true);


--
-- TOC entry 4858 (class 2606 OID 18729)
-- Name: tb_compra_detalle tb_compra_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_compra_detalle
    ADD CONSTRAINT tb_compra_detalle_pkey PRIMARY KEY (id_detalle);


--
-- TOC entry 4856 (class 2606 OID 18731)
-- Name: tb_compra tb_compra_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_compra
    ADD CONSTRAINT tb_compra_pkey PRIMARY KEY (id_compra);


--
-- TOC entry 4860 (class 2606 OID 18733)
-- Name: tb_empresa tb_empresa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_empresa
    ADD CONSTRAINT tb_empresa_pkey PRIMARY KEY (id_empresa);


--
-- TOC entry 4862 (class 2606 OID 18735)
-- Name: tb_estadocivil tb_estadocivil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_estadocivil
    ADD CONSTRAINT tb_estadocivil_pkey PRIMARY KEY (id_estadocivil);


--
-- TOC entry 4864 (class 2606 OID 18737)
-- Name: tb_iva tb_iva_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_iva
    ADD CONSTRAINT tb_iva_pkey PRIMARY KEY (id_iva);


--
-- TOC entry 4866 (class 2606 OID 18739)
-- Name: tb_pagina tb_pagina_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_pagina
    ADD CONSTRAINT tb_pagina_pkey PRIMARY KEY (id_pagina);


--
-- TOC entry 4868 (class 2606 OID 18741)
-- Name: tb_perfil tb_perfil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_perfil
    ADD CONSTRAINT tb_perfil_pkey PRIMARY KEY (id_perfil);


--
-- TOC entry 4870 (class 2606 OID 18743)
-- Name: tb_perfilpagina tb_perfilpagina_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_perfilpagina
    ADD CONSTRAINT tb_perfilpagina_pkey PRIMARY KEY (id_perfilpagina);


--
-- TOC entry 4872 (class 2606 OID 18745)
-- Name: tb_producto tb_producto_codigo_barra_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_producto
    ADD CONSTRAINT tb_producto_codigo_barra_key UNIQUE (codigo_barra);


--
-- TOC entry 4874 (class 2606 OID 18747)
-- Name: tb_producto tb_producto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_producto
    ADD CONSTRAINT tb_producto_pkey PRIMARY KEY (id_producto);


--
-- TOC entry 4876 (class 2606 OID 18749)
-- Name: tb_producto_proveedor tb_producto_proveedor_id_producto_id_proveedor_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_producto_proveedor
    ADD CONSTRAINT tb_producto_proveedor_id_producto_id_proveedor_key UNIQUE (id_producto, id_proveedor);


--
-- TOC entry 4878 (class 2606 OID 18751)
-- Name: tb_producto_proveedor tb_producto_proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_producto_proveedor
    ADD CONSTRAINT tb_producto_proveedor_pkey PRIMARY KEY (id);


--
-- TOC entry 4880 (class 2606 OID 18753)
-- Name: tb_proveedor tb_proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_proveedor
    ADD CONSTRAINT tb_proveedor_pkey PRIMARY KEY (id_proveedor);


--
-- TOC entry 4882 (class 2606 OID 18755)
-- Name: tb_ubicacion tb_ubicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_ubicacion
    ADD CONSTRAINT tb_ubicacion_pkey PRIMARY KEY (id_ubicacion);


--
-- TOC entry 4884 (class 2606 OID 18757)
-- Name: tb_usuario tb_usuario_correo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_usuario
    ADD CONSTRAINT tb_usuario_correo_key UNIQUE (correo);


--
-- TOC entry 4886 (class 2606 OID 18759)
-- Name: tb_usuario tb_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_usuario
    ADD CONSTRAINT tb_usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4890 (class 2606 OID 18761)
-- Name: tb_venta_detalle tb_venta_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_venta_detalle
    ADD CONSTRAINT tb_venta_detalle_pkey PRIMARY KEY (id_detalle);


--
-- TOC entry 4888 (class 2606 OID 18763)
-- Name: tb_venta tb_venta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_venta
    ADD CONSTRAINT tb_venta_pkey PRIMARY KEY (id_venta);


--
-- TOC entry 4904 (class 2620 OID 18764)
-- Name: tb_compra_detalle tg_compra_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_compra_delete AFTER DELETE ON public.tb_compra_detalle FOR EACH ROW EXECUTE FUNCTION public.trg_compra_delete();


--
-- TOC entry 4905 (class 2620 OID 18765)
-- Name: tb_compra_detalle tg_compra_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_compra_insert AFTER INSERT ON public.tb_compra_detalle FOR EACH ROW EXECUTE FUNCTION public.trg_compra_insert();


--
-- TOC entry 4906 (class 2620 OID 18766)
-- Name: tb_compra_detalle tg_compra_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_compra_update AFTER UPDATE ON public.tb_compra_detalle FOR EACH ROW EXECUTE FUNCTION public.trg_compra_update();


--
-- TOC entry 4910 (class 2620 OID 18767)
-- Name: tb_producto tg_protect_stock; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_protect_stock BEFORE UPDATE ON public.tb_producto FOR EACH ROW EXECUTE FUNCTION public.trg_protect_stock();


--
-- TOC entry 4907 (class 2620 OID 18768)
-- Name: tb_compra_detalle tg_total_compra_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_total_compra_delete AFTER DELETE ON public.tb_compra_detalle FOR EACH ROW EXECUTE FUNCTION public.trg_total_compra();


--
-- TOC entry 4908 (class 2620 OID 18769)
-- Name: tb_compra_detalle tg_total_compra_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_total_compra_insert AFTER INSERT ON public.tb_compra_detalle FOR EACH ROW EXECUTE FUNCTION public.trg_total_compra();


--
-- TOC entry 4909 (class 2620 OID 18770)
-- Name: tb_compra_detalle tg_total_compra_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_total_compra_update AFTER UPDATE ON public.tb_compra_detalle FOR EACH ROW EXECUTE FUNCTION public.trg_total_compra();


--
-- TOC entry 4911 (class 2620 OID 18771)
-- Name: tb_venta_detalle tg_total_venta_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_total_venta_delete AFTER DELETE ON public.tb_venta_detalle FOR EACH ROW EXECUTE FUNCTION public.trg_total_venta();


--
-- TOC entry 4912 (class 2620 OID 18772)
-- Name: tb_venta_detalle tg_total_venta_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_total_venta_insert AFTER INSERT ON public.tb_venta_detalle FOR EACH ROW EXECUTE FUNCTION public.trg_total_venta();


--
-- TOC entry 4913 (class 2620 OID 18773)
-- Name: tb_venta_detalle tg_total_venta_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_total_venta_update AFTER UPDATE ON public.tb_venta_detalle FOR EACH ROW EXECUTE FUNCTION public.trg_total_venta();


--
-- TOC entry 4914 (class 2620 OID 18774)
-- Name: tb_venta_detalle tg_venta_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_venta_delete AFTER DELETE ON public.tb_venta_detalle FOR EACH ROW EXECUTE FUNCTION public.trg_venta_delete();


--
-- TOC entry 4915 (class 2620 OID 18775)
-- Name: tb_venta_detalle tg_venta_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_venta_insert AFTER INSERT ON public.tb_venta_detalle FOR EACH ROW EXECUTE FUNCTION public.trg_venta_insert();


--
-- TOC entry 4916 (class 2620 OID 18776)
-- Name: tb_venta_detalle tg_venta_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_venta_update AFTER UPDATE ON public.tb_venta_detalle FOR EACH ROW EXECUTE FUNCTION public.trg_venta_update();


--
-- TOC entry 4892 (class 2606 OID 18845)
-- Name: tb_compra_detalle tb_compra_detalle_id_compra_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_compra_detalle
    ADD CONSTRAINT tb_compra_detalle_id_compra_fkey FOREIGN KEY (id_compra) REFERENCES public.tb_compra(id_compra) ON DELETE CASCADE;


--
-- TOC entry 4893 (class 2606 OID 18782)
-- Name: tb_compra_detalle tb_compra_detalle_id_producto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_compra_detalle
    ADD CONSTRAINT tb_compra_detalle_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.tb_producto(id_producto);


--
-- TOC entry 4891 (class 2606 OID 18787)
-- Name: tb_compra tb_compra_id_proveedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_compra
    ADD CONSTRAINT tb_compra_id_proveedor_fkey FOREIGN KEY (id_proveedor) REFERENCES public.tb_proveedor(id_proveedor);


--
-- TOC entry 4894 (class 2606 OID 18792)
-- Name: tb_perfilpagina tb_perfilpagina_id_pagina_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_perfilpagina
    ADD CONSTRAINT tb_perfilpagina_id_pagina_fkey FOREIGN KEY (id_pagina) REFERENCES public.tb_pagina(id_pagina);


--
-- TOC entry 4895 (class 2606 OID 18797)
-- Name: tb_perfilpagina tb_perfilpagina_id_perfil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_perfilpagina
    ADD CONSTRAINT tb_perfilpagina_id_perfil_fkey FOREIGN KEY (id_perfil) REFERENCES public.tb_perfil(id_perfil);


--
-- TOC entry 4896 (class 2606 OID 18802)
-- Name: tb_producto tb_producto_id_ubicacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_producto
    ADD CONSTRAINT tb_producto_id_ubicacion_fkey FOREIGN KEY (id_ubicacion) REFERENCES public.tb_ubicacion(id_ubicacion);


--
-- TOC entry 4897 (class 2606 OID 18807)
-- Name: tb_producto_proveedor tb_producto_proveedor_id_producto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_producto_proveedor
    ADD CONSTRAINT tb_producto_proveedor_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.tb_producto(id_producto);


--
-- TOC entry 4898 (class 2606 OID 18812)
-- Name: tb_producto_proveedor tb_producto_proveedor_id_proveedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_producto_proveedor
    ADD CONSTRAINT tb_producto_proveedor_id_proveedor_fkey FOREIGN KEY (id_proveedor) REFERENCES public.tb_proveedor(id_proveedor);


--
-- TOC entry 4899 (class 2606 OID 18817)
-- Name: tb_usuario tb_usuario_id_estadocivil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_usuario
    ADD CONSTRAINT tb_usuario_id_estadocivil_fkey FOREIGN KEY (id_estadocivil) REFERENCES public.tb_estadocivil(id_estadocivil);


--
-- TOC entry 4900 (class 2606 OID 18822)
-- Name: tb_usuario tb_usuario_id_perfil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_usuario
    ADD CONSTRAINT tb_usuario_id_perfil_fkey FOREIGN KEY (id_perfil) REFERENCES public.tb_perfil(id_perfil);


--
-- TOC entry 4902 (class 2606 OID 18827)
-- Name: tb_venta_detalle tb_venta_detalle_id_producto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_venta_detalle
    ADD CONSTRAINT tb_venta_detalle_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.tb_producto(id_producto);


--
-- TOC entry 4903 (class 2606 OID 18832)
-- Name: tb_venta_detalle tb_venta_detalle_id_venta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_venta_detalle
    ADD CONSTRAINT tb_venta_detalle_id_venta_fkey FOREIGN KEY (id_venta) REFERENCES public.tb_venta(id_venta);


--
-- TOC entry 4901 (class 2606 OID 18837)
-- Name: tb_venta tb_venta_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_venta
    ADD CONSTRAINT tb_venta_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.tb_usuario(id_usuario);


--
-- TOC entry 5100 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2026-01-11 19:03:30

--
-- PostgreSQL database dump complete
--

\unrestrict KSETyQst3AQYxbqra2rbvmCsVdffcE3qaNLgK9mBLlPX9a3J10JSC3U62fbMPi8

