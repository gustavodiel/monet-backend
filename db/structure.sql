SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: month_index(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.month_index(month integer, year integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$ BEGIN RETURN month + year * 12; END; $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entries (
    id bigint NOT NULL,
    name character varying,
    description text,
    kind integer,
    value_cents integer DEFAULT 0 NOT NULL,
    value_currency character varying DEFAULT 'BRL'::character varying NOT NULL,
    payment_method integer,
    category integer,
    origin character varying,
    installment_number integer,
    installment_total integer,
    paid_at timestamp(6) without time zone,
    day_of_month_to_pay integer,
    entry_id bigint,
    month_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    periodic_entry_id bigint
);


--
-- Name: entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entries_id_seq OWNED BY public.entries.id;


--
-- Name: months; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.months (
    id bigint NOT NULL,
    name integer,
    total_cents integer,
    total_currency character varying DEFAULT 'BRL'::character varying NOT NULL,
    year_id bigint
);


--
-- Name: months_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.months_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: months_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.months_id_seq OWNED BY public.months.id;


--
-- Name: periodic_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.periodic_entries (
    id bigint NOT NULL,
    entry_data json NOT NULL,
    start_month_id bigint NOT NULL,
    end_month_id bigint,
    "interval" integer,
    fulfilled boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: periodic_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.periodic_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: periodic_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.periodic_entries_id_seq OWNED BY public.periodic_entries.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: years; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.years (
    id bigint NOT NULL,
    name integer,
    interest_rate double precision
);


--
-- Name: years_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.years_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: years_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.years_id_seq OWNED BY public.years.id;


--
-- Name: entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries ALTER COLUMN id SET DEFAULT nextval('public.entries_id_seq'::regclass);


--
-- Name: months id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.months ALTER COLUMN id SET DEFAULT nextval('public.months_id_seq'::regclass);


--
-- Name: periodic_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodic_entries ALTER COLUMN id SET DEFAULT nextval('public.periodic_entries_id_seq'::regclass);


--
-- Name: years id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.years ALTER COLUMN id SET DEFAULT nextval('public.years_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: entries entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_pkey PRIMARY KEY (id);


--
-- Name: months months_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.months
    ADD CONSTRAINT months_pkey PRIMARY KEY (id);


--
-- Name: periodic_entries periodic_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodic_entries
    ADD CONSTRAINT periodic_entries_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: years years_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.years
    ADD CONSTRAINT years_pkey PRIMARY KEY (id);


--
-- Name: index_entries_on_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entries_on_entry_id ON public.entries USING btree (entry_id);


--
-- Name: index_entries_on_month_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entries_on_month_id ON public.entries USING btree (month_id);


--
-- Name: index_entries_on_periodic_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entries_on_periodic_entry_id ON public.entries USING btree (periodic_entry_id);


--
-- Name: index_months_on_year_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_months_on_year_id ON public.months USING btree (year_id);


--
-- Name: index_months_on_year_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_months_on_year_id_and_name ON public.months USING btree (year_id, name);


--
-- Name: index_periodic_entries_on_end_month_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_periodic_entries_on_end_month_id ON public.periodic_entries USING btree (end_month_id);


--
-- Name: index_periodic_entries_on_start_month_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_periodic_entries_on_start_month_id ON public.periodic_entries USING btree (start_month_id);


--
-- Name: index_years_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_years_on_name ON public.years USING btree (name);


--
-- Name: periodic_entries fk_rails_9718571fdf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodic_entries
    ADD CONSTRAINT fk_rails_9718571fdf FOREIGN KEY (start_month_id) REFERENCES public.months(id);


--
-- Name: periodic_entries fk_rails_e34d59d284; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.periodic_entries
    ADD CONSTRAINT fk_rails_e34d59d284 FOREIGN KEY (end_month_id) REFERENCES public.months(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20220510230511'),
('20220510231213'),
('20220511122001'),
('20220517135815'),
('20220520004620');


