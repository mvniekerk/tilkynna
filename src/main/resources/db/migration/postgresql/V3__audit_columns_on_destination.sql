-- Diff code generated with pgModeler (PostgreSQL Database Modeler)
-- pgModeler version: 0.9.2-alpha1
-- Diff date: 2019-05-22 17:06:39
-- Source model: tilkynna
-- Database: tilkynna
-- PostgreSQL version: 10.0

-- [ Diff summary ]
-- Dropped objects: 2
-- Created objects: 2
-- Changed objects: 2
-- Truncated tables: 0

delete from  _reports.destination where name = 'STREAM';


-- object: __updated_on | type: COLUMN --
-- ALTER TABLE _reports.destination DROP COLUMN IF EXISTS __updated_on CASCADE;
ALTER TABLE _reports.destination ADD COLUMN __updated_on timestamp with time zone NOT NULL;
-- ddl-end --

COMMENT ON COLUMN _reports.destination.__updated_on IS 'timestamptz when destination was last updated (changed) ';
-- ddl-end --


-- object: __updated_by | type: COLUMN --
-- ALTER TABLE _reports.destination DROP COLUMN IF EXISTS __updated_by CASCADE;
ALTER TABLE _reports.destination ADD COLUMN __updated_by uuid NOT NULL;
-- ddl-end --

COMMENT ON COLUMN _reports.destination.__updated_by IS 'UUID of the user that last updated this destination at the __updated_on time. ';
-- ddl-end --

insert into  _reports.destination 
(
	type,
	name,
	description,
	security_protocol,	
    downloadable,
	is_active, __updated_on, __updated_by)
values ('STREAM', 'STREAM', 'STREAM', 'ssl', true, true, now(), gen_random_uuid()); -- TODO : UUID here needs to map back to a A3S user :-( 
