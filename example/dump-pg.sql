--
-- PostgreSQL database cluster dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET escape_string_warning = off;

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: attr1; Type: TABLE; Schema: public; Owner: bla; Tablespace: 
--

CREATE TABLE attr1 (
  ObjID integer NOT NULL,
  attr1ID integer NOT NULL,
  Val integer NOT NULL
);

--
-- Data for Name: attr1; Type: TABLE DATA; Schema: public; Owner: bla
--

COPY attr1 (ObjID, attr1ID, Val) FROM stdin;
1	1	3
2	2	2
3	3	1
\.

--
-- Name: attr2; Type: TABLE; Schema: public; Owner: bla; Tablespace: 
--

CREATE TABLE attr2 (
  ObjID integer NOT NULL,
  attr2ID integer NOT NULL,
  Val integer NOT NULL
);

--
-- Data for Name: attr2; Type: TABLE DATA; Schema: public; Owner: bla
--

COPY attr2 (ObjID, attr2ID, Val) FROM stdin;
1	3	4
2	2	5
3	1	6
\.

--
-- Name: attr3; Type: TABLE; Schema: public; Owner: bla; Tablespace: 
--

CREATE TABLE attr3 (
  attr3ID integer NOT NULL,
  Val integer NOT NULL
);

--
-- Data for Name: attr3; Type: TABLE DATA; Schema: public; Owner: bla
--

COPY attr3 (attr3ID, Val) FROM stdin;
1	0
2	8
3	7
\.

--
-- Name: attr4; Type: TABLE; Schema: public; Owner: bla; Tablespace: 
--

CREATE TABLE attr4 (
  attr4ID integer NOT NULL,
  Val integer NOT NULL
);

--
-- Data for Name: attr4; Type: TABLE DATA; Schema: public; Owner: bla
--

COPY attr4 (attr4ID, Val) FROM stdin;
1	0
2	0
3	9
\.

--
-- Name: barobject; Type: TABLE; Schema: public; Owner: bla; Tablespace: 
--

CREATE TABLE barobject (
  ObjID integer NOT NULL,
  attr4ID integer NOT NULL,
  Bar integer NOT NULL
);

--
-- Data for Name: barobject; Type: TABLE DATA; Schema: public; Owner: bla
--

COPY barobject (ObjID, attr4ID, Bar) FROM stdin;
1	2	1002
2	1	1200
3	3	1000
\.

--
-- Name: fooobject; Type: TABLE; Schema: public; Owner: bla; Tablespace: 
--

CREATE TABLE fooobject (
  ObjID integer NOT NULL,
  attr1ID integer NOT NULL,
  attr3ID integer NOT NULL,
  Foo integer NOT NULL
);

--
-- Data for Name: fooobject; Type: TABLE DATA; Schema: public; Owner: bla
--

COPY fooobject (ObjID, attr1ID, attr3ID, Foo) FROM stdin;
1	1	2	112
2	2	1	122
3	3	3	111
\.

--
-- Name: object; Type: TABLE; Schema: public; Owner: bla; Tablespace: 
--

CREATE TABLE object (
  ObjID integer NOT NULL,
  Bla integer NOT NULL,
  Blub character varying(50) DEFAULT NULL
);

--
-- Data for Name: object; Type: TABLE DATA; Schema: public; Owner: bla
--

COPY object (ObjID, Bla, Blub) FROM stdin;
1	12	NULL
2	12	h)	(i
3	1	h'o
\.
