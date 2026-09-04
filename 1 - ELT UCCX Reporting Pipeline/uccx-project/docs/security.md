## Security and Access Configuration

### PostgreSQL Security Configuration
Issue the below query on PostgreSQL to create the Metabase role and grant it the required access - modify placeholders accordingly for the credentials. The role's access to PostgreSQL is reviewed yearly:

    ```
    BEGIN;
    CREATE ROLE <your_role_name> WITH LOGIN PASSWORD '<your_role_pwd>' VALID UNTIL '2027-01-01';
    GRANT CONNECT ON DATABASE uccx TO <your_role_name>;
    GRANT USAGE ON SCHEMA uccxmodels_marts TO <your_role_name>;
    GRANT SELECT ON ALL TABLES IN SCHEMA uccxmodels_marts TO <your_role_name>;
    GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA uccxmodels_marts TO <your_role_name>;
    ALTER DEFAULT PRIVILEGES IN SCHEMA uccxmodels_marts 
    GRANT SELECT ON TABLES TO <your_role_name>;
    ALTER DEFAULT PRIVILEGES IN SCHEMA uccxmodels_marts 
    GRANT SELECT, USAGE ON SEQUENCES TO <your_role_name>;
    GRANT pg_read_all_settings TO <your_role_name>;
    COMMIT;
    ```
