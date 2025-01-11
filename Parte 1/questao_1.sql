'''1 - Consultar as tabelas de catálogo para listar todos os índices existentes acompanhados das tabelas e colunas indexadas pelo mesmo.'''

SELECT indexname as indice, tablename as tabela, TRIM(TRAILING ')' FROM split_part(indexdef,'(',2)) as colunas
FROM pg_indexes
WHERE schemaname = 'public' --> alterar aqui com o nome do seu schema
ORDER BY indice, tabela;