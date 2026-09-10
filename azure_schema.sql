--
-- PostgreSQL database dump
--

\restrict r76QKv7GSpatHmrwrs6sCUno1mKaIUyiN7n34beNRkhPRHBi3o3j3idortiIbep

-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 18.4 (Debian 18.4-1)

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
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts (
    account_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    account_number character varying(20) NOT NULL,
    account_type character varying(20) NOT NULL,
    balance numeric(19,4) DEFAULT 0.0000 NOT NULL,
    currency character(3) DEFAULT 'USD'::bpchar NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT accounts_balance_check CHECK ((balance >= (0)::numeric)),
    CONSTRAINT accounts_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'FROZEN'::character varying, 'CLOSED'::character varying])::text[]))),
    CONSTRAINT accounts_type_check CHECK (((account_type)::text = ANY ((ARRAY['CHECKING'::character varying, 'SAVINGS'::character varying, 'CREDIT'::character varying])::text[])))
);


ALTER TABLE public.accounts OWNER TO postgres;

--
-- Name: accounts_account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.accounts ALTER COLUMN account_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.accounts_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.addresses (
    address_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    address_type character varying(20) NOT NULL,
    street_address character varying(255) NOT NULL,
    city character varying(100) NOT NULL,
    state character varying(50) NOT NULL,
    postal_code character varying(20) NOT NULL,
    country character(2) DEFAULT 'US'::bpchar NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT addresses_type_check CHECK (((address_type)::text = ANY ((ARRAY['HOME'::character varying, 'MAILING'::character varying, 'WORK'::character varying])::text[])))
);


ALTER TABLE public.addresses OWNER TO postgres;

--
-- Name: addresses_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.addresses ALTER COLUMN address_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.addresses_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    customer_id bigint NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    phone_number character varying(25),
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT customers_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying, 'SUSPENDED'::character varying])::text[])))
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.customers ALTER COLUMN customer_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.customers_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: merchants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.merchants (
    merchant_id bigint NOT NULL,
    merchant_name character varying(255) NOT NULL,
    merchant_category character varying(100),
    country character(2) DEFAULT 'US'::bpchar NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.merchants OWNER TO postgres;

--
-- Name: merchants_merchant_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.merchants ALTER COLUMN merchant_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.merchants_merchant_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    transaction_id bigint NOT NULL,
    account_id bigint NOT NULL,
    merchant_id bigint,
    amount numeric(19,4) NOT NULL,
    currency character(3) DEFAULT 'USD'::bpchar NOT NULL,
    transaction_type character varying(20) NOT NULL,
    status character varying(20) DEFAULT 'COMPLETED'::character varying NOT NULL,
    transaction_timestamp timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT transactions_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT transactions_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'COMPLETED'::character varying, 'FAILED'::character varying, 'REVERSED'::character varying])::text[]))),
    CONSTRAINT transactions_type_check CHECK (((transaction_type)::text = ANY ((ARRAY['PURCHASE'::character varying, 'REFUND'::character varying, 'DEPOSIT'::character varying, 'WITHDRAWAL'::character varying, 'TRANSFER'::character varying])::text[])))
);


ALTER TABLE public.transactions OWNER TO postgres;

--
-- Name: transactions_partitioned; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions_partitioned (
    transaction_id bigint NOT NULL,
    account_id bigint NOT NULL,
    merchant_id bigint,
    amount numeric(19,4) NOT NULL,
    currency character(3) NOT NULL,
    transaction_type character varying(20) NOT NULL,
    status character varying(20) NOT NULL,
    transaction_timestamp timestamp with time zone NOT NULL,
    created_at timestamp with time zone NOT NULL
)
PARTITION BY RANGE (transaction_timestamp);


ALTER TABLE public.transactions_partitioned OWNER TO postgres;

--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.transactions ALTER COLUMN transaction_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.transactions_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: accounts accounts_account_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_account_number_key UNIQUE (account_number);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (account_id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (address_id);


--
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: merchants merchants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.merchants
    ADD CONSTRAINT merchants_pkey PRIMARY KEY (merchant_id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (transaction_id);


--
-- Name: idx_accounts_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_accounts_customer_id ON public.accounts USING btree (customer_id);


--
-- Name: idx_transactions_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_account_id ON public.transactions USING btree (account_id);


--
-- Name: idx_transactions_account_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_account_status ON public.transactions USING btree (account_id, status);


--
-- Name: idx_transactions_account_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_account_timestamp ON public.transactions USING btree (account_id, transaction_timestamp);


--
-- Name: accounts accounts_customer_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE RESTRICT;


--
-- Name: addresses addresses_customer_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_customer_fk FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE CASCADE;


--
-- Name: transactions transactions_account_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_account_fk FOREIGN KEY (account_id) REFERENCES public.accounts(account_id) ON DELETE RESTRICT;


--
-- Name: transactions transactions_merchant_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_merchant_fk FOREIGN KEY (merchant_id) REFERENCES public.merchants(merchant_id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict r76QKv7GSpatHmrwrs6sCUno1mKaIUyiN7n34beNRkhPRHBi3o3j3idortiIbep
