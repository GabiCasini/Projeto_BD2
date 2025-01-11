-- Testes (Rodar nessa sequência)
INSERT INTO invoice_exemple (estado) VALUES (2); --INVÁLIDO

INSERT INTO invoice_exemple (estado) VALUES (1); --VÁLIDO

UPDATE invoice_exemple SET estado = 2 WHERE id = 2; --VÁLIDO

UPDATE invoice_exemple SET estado = 3 WHERE id = 2; --VÁLIDO

UPDATE invoice_exemple SET estado = 1 WHERE id = 2; --INVÁLIDO

SELECT * FROM invoice_exemple;
 