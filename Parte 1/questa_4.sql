''' 4 - Criar usando a linguagem de programação do SGBD escolhido um script que construa 
        de forma dinâmica a partir do catálogo os comandos create table das tabelas
        existentes no esquema exemplo considerando pelo menos as informações sobre
        colunas (nome, tipo e obrigatoriedade) e chaves primárias e estrangeiras.
'''

DO $$
DECLARE
    table_rec RECORD;
    column_rec RECORD;
    constraint_rec RECORD;
    create_table_query TEXT;
    column_definitions TEXT;
    primary_key TEXT;
    foreign_keys_queries TEXT := '';
BEGIN
    -- Loop para criar as tabelas
    FOR table_rec IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public' --> alterar aqui com o nome do seu schema 
    LOOP
        create_table_query := FORMAT('CREATE TABLE %I (', table_rec.table_name);
        column_definitions := '';
        primary_key := '';

        FOR column_rec IN
            SELECT column_name, data_type, is_nullable, character_maximum_length
            FROM information_schema.columns
            WHERE table_name = table_rec.table_name AND table_schema = 'public' --> alterar aqui com o nome do seu schema
            ORDER BY ordinal_position
        LOOP
            column_definitions := column_definitions || FORMAT(
                '%I %s%s, ',
                column_rec.column_name,
                CASE
                    WHEN column_rec.data_type = 'character varying' AND column_rec.character_maximum_length IS NOT NULL THEN
                        column_rec.data_type || '(' || column_rec.character_maximum_length || ')'
                    ELSE
                        column_rec.data_type
                END,
                CASE
                    WHEN column_rec.is_nullable = 'NO' THEN ' NOT NULL'
                    ELSE ''
                END
            );
        END LOOP;

        column_definitions := RTRIM(column_definitions, ', ');

        FOR constraint_rec IN
            SELECT k.column_name
            FROM information_schema.table_constraints t
            JOIN information_schema.key_column_usage k
                ON t.constraint_name = k.constraint_name
                AND t.table_schema = k.table_schema
            WHERE t.table_schema = 'public' --> alterar aqui com o nome do seu schema
              AND t.table_name = table_rec.table_name
              AND t.constraint_type = 'PRIMARY KEY'
            ORDER BY k.ordinal_position
        LOOP
            primary_key := primary_key || FORMAT('%I, ', constraint_rec.column_name);
        END LOOP;

		create_table_query := create_table_query || column_definitions;		

        IF primary_key != '' THEN
            primary_key := 'PRIMARY KEY (' || RTRIM(primary_key, ', ') || ')';
			create_table_query := create_table_query || ', ' || primary_key;
        END IF;

        create_table_query := create_table_query || ');';

        RAISE NOTICE '%', create_table_query;
    END LOOP;

    -- Loop para alterar as tabelas com as FOREIGN KEYS
    FOR table_rec IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public' --> alterar aqui com o nome do seu schema
    LOOP
        FOR constraint_rec IN
            SELECT
                k.column_name,
                c.table_name AS referenced_table,
                c.column_name AS referenced_column
            FROM information_schema.table_constraints t
            JOIN information_schema.key_column_usage k
                ON t.constraint_name = k.constraint_name
                AND t.table_schema = k.table_schema
            JOIN information_schema.constraint_column_usage c
                ON t.constraint_name = c.constraint_name
                AND t.table_schema = c.table_schema
            WHERE t.table_schema = 'public' --> alterar aqui com o nome do seu schema
              AND t.table_name = table_rec.table_name
              AND t.constraint_type = 'FOREIGN KEY'
        LOOP
            foreign_keys_queries := foreign_keys_queries || FORMAT(
                'ALTER TABLE %I ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %I(%I);',
                table_rec.table_name,
                table_rec.table_name || '_' || constraint_rec.column_name || '_fkey',
                constraint_rec.column_name,
                constraint_rec.referenced_table,
                constraint_rec.referenced_column
            ) || E'\n';
        END LOOP;
    END LOOP;

    -- Executa todas as constraints de FOREIGN KEY
    RAISE NOTICE '%', foreign_keys_queries;
END $$;