DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_extension WHERE extname='pgcrypto') THEN
    CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
  END IF;
END; 
$$
