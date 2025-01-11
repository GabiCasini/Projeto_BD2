'''3 - Consultar as tabelas de catálogo para listar todas as chaves estrangeiras existentes informando as tabelas e colunas envolvidas.'''

SELECT
    conname AS nome_constraint,
    cl.relname AS tabela_local,
    att1.attname AS coluna_local,
    ref_cl.relname AS tabela_referenciada,
    att2.attname AS coluna_referenciada
FROM 
    pg_constraint AS c
    JOIN pg_attribute AS att1 ON att1.attnum = ANY(c.conkey) AND att1.attrelid = c.conrelid
    JOIN pg_class AS cl ON cl.oid = c.conrelid
    JOIN pg_attribute AS att2 ON att2.attnum = ANY(c.confkey) AND att2.attrelid = c.confrelid
    JOIN pg_class AS ref_cl ON ref_cl.oid = c.confrelid
WHERE 
    c.contype = 'f'
ORDER BY 
    tabela_local, nome_constraint;