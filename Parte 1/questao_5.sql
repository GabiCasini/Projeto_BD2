'''5 - Implemente uma solução através da programação em banco de dados para validar os
        valores de uma coluna que represente uma situação (estado) garantindo que os seus
        valores e suas transições atendam a especificação de um diagrama de transição de
        estados (DTE). Quanto mais genérica e reutilizável for a solução melhor a pontuação
        nessa questão. Junto da solução deverá ser entregue um cenário de teste
        demonstrando o funcionamento da solução.
'''

CREATE TABLE estado ( -- Como se fosse um enum
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL UNIQUE
);

CREATE TABLE transicao (
    estado_0 INTEGER NOT NULL,
    estado_1 INTEGER NOT NULL,
    FOREIGN KEY (estado_0) REFERENCES estado(id),
    FOREIGN KEY (estado_1) REFERENCES estado(id),
    UNIQUE (estado_0, estado_1)
);

INSERT INTO estado (nome)
VALUES ('INICIADO'), ('EM_ANDAMENTO'), ('FINALIZADO');

INSERT INTO transicao (estado_0, estado_1)
VALUES (1, 2), (2, 3); -- INICIADO -> EM_ANDAMENTO && EM_ANDAMENTO -> FINALIZADO

-- TESTE
CREATE TABLE invoice_exemple ( -- cada fatura teria um estado por exemplo
    id SERIAL PRIMARY KEY,
    estado INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (estado) REFERENCES estado(id)
);


CREATE OR REPLACE FUNCTION valida_transicao()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.estado <> 1
	THEN RAISE EXCEPTION 'Inserção inválida: A inserção de um elemento com estado diferente de "Iniciado" não é permitida.';
    END IF;

    IF OLD.estado IS NOT NULL AND NOT EXISTS (
        SELECT 1
        FROM transicao
        WHERE estado_0 = OLD.estado
          AND estado_1 = NEW.estado
    ) 
	THEN RAISE EXCEPTION 'Transição inválida: A mudança do estado % para o estado % não é permitida', OLD.estado, NEW.estado;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER valida_transicoes_trigger
BEFORE INSERT OR UPDATE OF estado ON invoice_exemple
FOR EACH ROW
EXECUTE FUNCTION valida_transicao();