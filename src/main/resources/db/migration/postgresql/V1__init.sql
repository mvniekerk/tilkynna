-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.9.2-alpha1
-- PostgreSQL version: 10.0
-- Project Site: pgmodeler.io
-- Model Author: ---


-- Database creation must be done outside a multicommand file.
-- These commands were put in this file only as a convenience.
-- -- object: tilkynna | type: DATABASE --
-- -- DROP DATABASE IF EXISTS tilkynna;
-- CREATE DATABASE tilkynna
-- 	ENCODING = 'UTF8'
-- 	TABLESPACE = pg_default
-- 	OWNER = postgres;
-- -- ddl-end --
-- 

-- object: _reports | type: SCHEMA --
-- DROP SCHEMA IF EXISTS _reports CASCADE;
-- CREATE SCHEMA _reports;
-- ddl-end --
ALTER SCHEMA _reports OWNER TO postgres;
-- ddl-end --

--SET search_path TO pg_catalog,public,_reports;
-- ddl-end --

-- object: _reports.template | type: TABLE --
-- DROP TABLE IF EXISTS _reports.template CASCADE;
CREATE TABLE _reports.template (
	id uuid NOT NULL DEFAULT gen_random_uuid(),
	name text NOT NULL,
	original_filename text NOT NULL,
	CONSTRAINT pk_template PRIMARY KEY (id),
	CONSTRAINT un_template_name UNIQUE (name)

);
-- ddl-end --
COMMENT ON COLUMN _reports.template.original_filename IS 'the birt report design file location ';
-- ddl-end --
ALTER TABLE _reports.template OWNER TO postgres;
-- ddl-end --

-- object: _reports.export_format | type: TABLE --
-- DROP TABLE IF EXISTS _reports.export_format CASCADE;
CREATE TABLE _reports.export_format (
	id smallint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT BY 1 MINVALUE 0 MAXVALUE 32767 START WITH 1 CACHE 1 ),
	name text,
	media_type text,
	is_active boolean,
	CONSTRAINT pk_export_format PRIMARY KEY (id)

);
-- ddl-end --
COMMENT ON TABLE _reports.export_format IS 'enum ? PDF, CSV, TXT, ';
-- ddl-end --
ALTER TABLE _reports.export_format OWNER TO postgres;
-- ddl-end --

-- object: _reports."ui-notification_status" | type: TYPE --
-- DROP TYPE IF EXISTS _reports."ui-notification_status" CASCADE;
CREATE TYPE _reports."ui-notification_status" AS
 ENUM ('unread','read','closed');
-- ddl-end --
ALTER TYPE _reports."ui-notification_status" OWNER TO postgres;
-- ddl-end --
COMMENT ON TYPE _reports."ui-notification_status" IS 'this provides an enumerated type for ui-notifications';
-- ddl-end --

-- object: _reports.report_status | type: TYPE --
-- DROP TYPE IF EXISTS _reports.report_status CASCADE;
CREATE TYPE _reports.report_status AS
 ENUM ('PENDING','STARTED','FAILED','FINISHED');
-- ddl-end --
ALTER TYPE _reports.report_status OWNER TO postgres;
-- ddl-end --
COMMENT ON TYPE _reports.report_status IS 'Status of the request to generated a report
PENDING: requested accepted 
STARTED: processing of the request has started 
FAILED: processing for generating the report failed
FINISHED: processing for generating the report of streamed destination complete
FINISHED_REMOTE: processing for generating the report to any destination other than streaming is complete';
-- ddl-end --

-- object: _reports.destination | type: TABLE --
-- DROP TABLE IF EXISTS _reports.destination CASCADE;
CREATE TABLE _reports.destination (
	destination_id uuid NOT NULL DEFAULT gen_random_uuid(),
	type text NOT NULL,
	name text NOT NULL,
	description text,
	security_protocol text NOT NULL,
	timeout bigint DEFAULT 5000,
	is_active boolean DEFAULT false,
	downloadable boolean NOT NULL,
	CONSTRAINT pk_destination PRIMARY KEY (destination_id),
	CONSTRAINT un_destination_name UNIQUE (name)

);
-- ddl-end --
ALTER TABLE _reports.destination OWNER TO postgres;
-- ddl-end --

-- object: _reports.smtp | type: TABLE --
-- DROP TABLE IF EXISTS _reports.smtp CASCADE;
CREATE TABLE _reports.smtp (
	destination_id uuid NOT NULL,
	host text NOT NULL,
	port smallint NOT NULL,
	username text NOT NULL,
	password bytea NOT NULL,
	password_hash text NOT NULL,
	from_address text NOT NULL,
	CONSTRAINT pk_smtp PRIMARY KEY (destination_id)

);
-- ddl-end --
COMMENT ON COLUMN _reports.smtp.password_hash IS 'This column will be used to validate that the decryption of the encrypted password was successful.';
-- ddl-end --
ALTER TABLE _reports.smtp OWNER TO postgres;
-- ddl-end --

-- object: _reports.sftp | type: TABLE --
-- DROP TABLE IF EXISTS _reports.sftp CASCADE;
CREATE TABLE _reports.sftp (
	destination_id uuid NOT NULL,
	host text NOT NULL,
	port smallint NOT NULL,
	username text NOT NULL,
	password bytea NOT NULL,
	password_hash text NOT NULL,
	working_directory text NOT NULL,
	CONSTRAINT pk_sftp PRIMARY KEY (destination_id)

);
-- ddl-end --
COMMENT ON COLUMN _reports.sftp.password_hash IS 'This column will be used to validate that the decryption of the encrypted password was successful.';
-- ddl-end --
ALTER TABLE _reports.sftp OWNER TO postgres;
-- ddl-end --

-- object: _reports.web_endpoint | type: TABLE --
-- DROP TABLE IF EXISTS _reports.web_endpoint CASCADE;
CREATE TABLE _reports.web_endpoint (
	destination_id uuid NOT NULL,
	url text NOT NULL,
	verb text NOT NULL,
	CONSTRAINT pk_web_endpoint PRIMARY KEY (destination_id)

);
-- ddl-end --
COMMENT ON COLUMN _reports.web_endpoint.verb IS 'POST,PUT';
-- ddl-end --
ALTER TABLE _reports.web_endpoint OWNER TO postgres;
-- ddl-end --

-- object: _reports.datasource | type: TABLE --
-- DROP TABLE IF EXISTS _reports.datasource CASCADE;
CREATE TABLE _reports.datasource (
	datasource_id uuid NOT NULL DEFAULT gen_random_uuid(),
	type text NOT NULL,
	name varchar(255) NOT NULL,
	description text,
	is_active boolean DEFAULT false,
	CONSTRAINT pk_datasource PRIMARY KEY (datasource_id),
	CONSTRAINT un_name UNIQUE (name)

);
-- ddl-end --
ALTER TABLE _reports.datasource OWNER TO postgres;
-- ddl-end --

-- object: _reports.template_tag | type: TABLE --
-- DROP TABLE IF EXISTS _reports.template_tag CASCADE;
CREATE TABLE _reports.template_tag (
	template_id uuid,
	tag text NOT NULL
);
-- ddl-end --
COMMENT ON TABLE _reports.template_tag IS 'Purposely Denormalised';
-- ddl-end --
ALTER TABLE _reports.template_tag OWNER TO postgres;
-- ddl-end --

-- object: _reports.stream | type: TABLE --
-- DROP TABLE IF EXISTS _reports.stream CASCADE;
CREATE TABLE _reports.stream (
	destination_id uuid NOT NULL,
	CONSTRAINT pk_stream PRIMARY KEY (destination_id)

);
-- ddl-end --
ALTER TABLE _reports.stream OWNER TO postgres;
-- ddl-end --

-- object: _reports.s3 | type: TABLE --
-- DROP TABLE IF EXISTS _reports.s3 CASCADE;
CREATE TABLE _reports.s3 (
	destination_id uuid NOT NULL,
	access_key text NOT NULL,
	secret_key text NOT NULL,
	CONSTRAINT pk_s3 PRIMARY KEY (destination_id)

);
-- ddl-end --
ALTER TABLE _reports.s3 OWNER TO postgres;
-- ddl-end --

-- object: _reports.jdbc | type: TABLE --
-- DROP TABLE IF EXISTS _reports.jdbc CASCADE;
CREATE TABLE _reports.jdbc (
	datasource_id uuid NOT NULL,
	driver_class text NOT NULL,
	db_url text NOT NULL,
	username text NOT NULL,
	password bytea NOT NULL,
	password_hash text NOT NULL,
	CONSTRAINT pk_jdbc PRIMARY KEY (datasource_id)

);
-- ddl-end --
COMMENT ON COLUMN _reports.jdbc.password_hash IS 'This column will be used to validate that the decryption of the encrypted password was successful.';
-- ddl-end --
ALTER TABLE _reports.jdbc OWNER TO postgres;
-- ddl-end --

-- object: _reports.flat_file | type: TABLE --
-- DROP TABLE IF EXISTS _reports.flat_file CASCADE;
CREATE TABLE _reports.flat_file (
	datasource_id uuid NOT NULL,
	file_uri text NOT NULL,
	char_set text NOT NULL,
	flat_file_style text NOT NULL,
	first_line_header boolean DEFAULT true,
	second_line_data_type_indicator boolean DEFAULT false,
	CONSTRAINT pk_flat_file PRIMARY KEY (datasource_id)

);
-- ddl-end --
ALTER TABLE _reports.flat_file OWNER TO postgres;
-- ddl-end --

-- object: _reports."ui-notification" | type: TABLE --
-- DROP TABLE IF EXISTS _reports."ui-notification" CASCADE;
CREATE TABLE _reports."ui-notification" (
	id bigint NOT NULL,
	title text NOT NULL,
	message text,
	notification_status _reports."ui-notification_status",
	user_id uuid,
	CONSTRAINT pk_notification PRIMARY KEY (id)

);
-- ddl-end --
COMMENT ON TABLE _reports."ui-notification" IS 'to be replaced later with a more robust topic-subscribe notfication capability';
-- ddl-end --
ALTER TABLE _reports."ui-notification" OWNER TO postgres;
-- ddl-end --

-- object: _reports.template_datasource | type: TABLE --
-- DROP TABLE IF EXISTS _reports.template_datasource CASCADE;
CREATE TABLE _reports.template_datasource (
	template_id uuid NOT NULL,
	datasource_id uuid NOT NULL,
	CONSTRAINT pk_template_datasource PRIMARY KEY (template_id,datasource_id)

);
-- ddl-end --
ALTER TABLE _reports.template_datasource OWNER TO postgres;
-- ddl-end --

-- object: idx_tag | type: INDEX --
-- DROP INDEX IF EXISTS _reports.idx_tag CASCADE;
CREATE INDEX idx_tag ON _reports.template_tag
	USING gin
	(
	  (to_tsvector('english', tag))
	);
-- ddl-end --

-- object: _reports.generated_report | type: TABLE --
-- DROP TABLE IF EXISTS _reports.generated_report CASCADE;
CREATE TABLE _reports.generated_report (
	correlation_id uuid NOT NULL DEFAULT gen_random_uuid(),
	requested_by uuid NOT NULL,
	requested_at timestamptz NOT NULL,
	generated_at timestamptz NOT NULL,
	destination_id uuid NOT NULL,
	template_id uuid NOT NULL,
	export_format_id smallint NOT NULL,
	request_body text NOT NULL,
	report_status _reports.report_status,
	retry_count smallint DEFAULT 0,
	CONSTRAINT pk_generated_report PRIMARY KEY (correlation_id)

);
-- ddl-end --
COMMENT ON COLUMN _reports.generated_report.requested_by IS 'The uuid of the users (in A3S) logged in and requesting the report';
-- ddl-end --
COMMENT ON COLUMN _reports.generated_report.request_body IS 'JSON of the request body to be used for generating this report';
-- ddl-end --
COMMENT ON COLUMN _reports.generated_report.retry_count IS 'Number of times left to rety upon failure ';
-- ddl-end --
ALTER TABLE _reports.generated_report OWNER TO postgres;
-- ddl-end --

-- object: _reports.selected_destination_parameter | type: TABLE --
-- DROP TABLE IF EXISTS _reports.selected_destination_parameter CASCADE;
CREATE TABLE _reports.selected_destination_parameter (
	id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT BY 1 MINVALUE 0 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1 ),
	correlation_id uuid NOT NULL,
	destination_parameter_id bigint,
	value text,
	CONSTRAINT pk_selected_destination_parameter PRIMARY KEY (id)

);
-- ddl-end --
COMMENT ON TABLE _reports.selected_destination_parameter IS 'destination parameter value for the specific report. For example if destination type is SMTP. destination_parameter entries would include: 
to: melissap@grindrodbank.co.za
subject: report to be sent';
-- ddl-end --
ALTER TABLE _reports.selected_destination_parameter OWNER TO postgres;
-- ddl-end --

-- object: _reports.destination_parameter | type: TABLE --
-- DROP TABLE IF EXISTS _reports.destination_parameter CASCADE;
CREATE TABLE _reports.destination_parameter (
	id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT BY 1 MINVALUE 0 MAXVALUE 9223372036854775807 START WITH 1 CACHE 1 ),
	destination_id uuid NOT NULL,
	name text NOT NULL,
	data_type text NOT NULL,
	description text,
	required bool NOT NULL DEFAULT true,
	validation text,
	CONSTRAINT pk_destination_parameter PRIMARY KEY (id),
	CONSTRAINT un_destination_parameter_name UNIQUE (destination_id,name)

);
-- ddl-end --
COMMENT ON TABLE _reports.destination_parameter IS 'Holds the possible variable parameters for a destination. For example SFTP can have a path (which could be different for any report request), SMTP has to,cc,bcc,subject,body parameters. ';
-- ddl-end --
COMMENT ON COLUMN _reports.destination_parameter.validation IS 'RegEx used to validate a selected_destination_paramter. As selected_destination_parameter.value is just TEXT. (eg. for an email the ##.validation field might be something like: ^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,}$';
-- ddl-end --
ALTER TABLE _reports.destination_parameter OWNER TO postgres;
-- ddl-end --

-- object: "fk_destination.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.smtp DROP CONSTRAINT IF EXISTS "fk_destination.id" CASCADE;
ALTER TABLE _reports.smtp ADD CONSTRAINT "fk_destination.id" FOREIGN KEY (destination_id)
REFERENCES _reports.destination (destination_id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "fk_destination.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.sftp DROP CONSTRAINT IF EXISTS "fk_destination.id" CASCADE;
ALTER TABLE _reports.sftp ADD CONSTRAINT "fk_destination.id" FOREIGN KEY (destination_id)
REFERENCES _reports.destination (destination_id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "fk_destination.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.web_endpoint DROP CONSTRAINT IF EXISTS "fk_destination.id" CASCADE;
ALTER TABLE _reports.web_endpoint ADD CONSTRAINT "fk_destination.id" FOREIGN KEY (destination_id)
REFERENCES _reports.destination (destination_id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "fk_template.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.template_tag DROP CONSTRAINT IF EXISTS "fk_template.id" CASCADE;
ALTER TABLE _reports.template_tag ADD CONSTRAINT "fk_template.id" FOREIGN KEY (template_id)
REFERENCES _reports.template (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "fk_destination.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.stream DROP CONSTRAINT IF EXISTS "fk_destination.id" CASCADE;
ALTER TABLE _reports.stream ADD CONSTRAINT "fk_destination.id" FOREIGN KEY (destination_id)
REFERENCES _reports.destination (destination_id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "fk_destination.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.s3 DROP CONSTRAINT IF EXISTS "fk_destination.id" CASCADE;
ALTER TABLE _reports.s3 ADD CONSTRAINT "fk_destination.id" FOREIGN KEY (destination_id)
REFERENCES _reports.destination (destination_id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "fk_datasource.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.jdbc DROP CONSTRAINT IF EXISTS "fk_datasource.id" CASCADE;
ALTER TABLE _reports.jdbc ADD CONSTRAINT "fk_datasource.id" FOREIGN KEY (datasource_id)
REFERENCES _reports.datasource (datasource_id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "fk_datasource.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.flat_file DROP CONSTRAINT IF EXISTS "fk_datasource.id" CASCADE;
ALTER TABLE _reports.flat_file ADD CONSTRAINT "fk_datasource.id" FOREIGN KEY (datasource_id)
REFERENCES _reports.datasource (datasource_id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "fk_template.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.template_datasource DROP CONSTRAINT IF EXISTS "fk_template.id" CASCADE;
ALTER TABLE _reports.template_datasource ADD CONSTRAINT "fk_template.id" FOREIGN KEY (template_id)
REFERENCES _reports.template (id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: "fk_datasource.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.template_datasource DROP CONSTRAINT IF EXISTS "fk_datasource.id" CASCADE;
ALTER TABLE _reports.template_datasource ADD CONSTRAINT "fk_datasource.id" FOREIGN KEY (datasource_id)
REFERENCES _reports.datasource (datasource_id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: "fk_destination.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.generated_report DROP CONSTRAINT IF EXISTS "fk_destination.id" CASCADE;
ALTER TABLE _reports.generated_report ADD CONSTRAINT "fk_destination.id" FOREIGN KEY (destination_id)
REFERENCES _reports.destination (destination_id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: "fk_export_format.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.generated_report DROP CONSTRAINT IF EXISTS "fk_export_format.id" CASCADE;
ALTER TABLE _reports.generated_report ADD CONSTRAINT "fk_export_format.id" FOREIGN KEY (export_format_id)
REFERENCES _reports.export_format (id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: fk_template_id | type: CONSTRAINT --
-- ALTER TABLE _reports.generated_report DROP CONSTRAINT IF EXISTS fk_template_id CASCADE;
ALTER TABLE _reports.generated_report ADD CONSTRAINT fk_template_id FOREIGN KEY (template_id)
REFERENCES _reports.template (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "fk_generated_report.correlation_id" | type: CONSTRAINT --
-- ALTER TABLE _reports.selected_destination_parameter DROP CONSTRAINT IF EXISTS "fk_generated_report.correlation_id" CASCADE;
ALTER TABLE _reports.selected_destination_parameter ADD CONSTRAINT "fk_generated_report.correlation_id" FOREIGN KEY (correlation_id)
REFERENCES _reports.generated_report (correlation_id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: "fk_destination_parameter.id" | type: CONSTRAINT --
-- ALTER TABLE _reports.selected_destination_parameter DROP CONSTRAINT IF EXISTS "fk_destination_parameter.id" CASCADE;
ALTER TABLE _reports.selected_destination_parameter ADD CONSTRAINT "fk_destination_parameter.id" FOREIGN KEY (destination_parameter_id)
REFERENCES _reports.destination_parameter (id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: fk_destination | type: CONSTRAINT --
-- ALTER TABLE _reports.destination_parameter DROP CONSTRAINT IF EXISTS fk_destination CASCADE;
ALTER TABLE _reports.destination_parameter ADD CONSTRAINT fk_destination FOREIGN KEY (destination_id)
REFERENCES _reports.destination (destination_id) MATCH FULL
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --


