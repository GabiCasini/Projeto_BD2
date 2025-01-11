'''2 - Criar usando a linguagem de programação do SGBD escolhido um procedimento que remova todos os índices de uma tabela informada como parâmetro.'''

CREATE OR REPLACE PROCEDURE drop_indexes(table_name TEXT)
LANGUAGE plpgsql AS $$
DECLARE
  index_name TEXT;
  constraint_name TEXT;
BEGIN
  -- CASCADE para restrições
  FOR constraint_name IN 
    SELECT conname
    FROM pg_constraint
    WHERE conrelid = table_name::regclass
  LOOP
    EXECUTE FORMAT('ALTER TABLE %I DROP CONSTRAINT %I CASCADE', table_name, constraint_name);
  END LOOP;

  FOR index_name IN 
    SELECT indexname
    FROM pg_indexes
    WHERE tablename = table_name
  LOOP
    EXECUTE FORMAT('DROP INDEX IF EXISTS %I CASCADE', index_name);
  END LOOP;
END;
$$;

'''Usamos a tabela album para teste'''
CALL drop_indexes('album'); --> passar o nome da tabela a ser alterada como parâmentro aqui