'''
4. A base original do Chinook possui uma coluna Total na tabela Invoice representada
de forma redundante com as informações contidas nas colunas UnitPrice e
Quantity na tabela InvoiceLine. Podemos identificar nesse caso uma regra
semântica onde o valor Total de um Invoice deve ser igual à soma de UnitPrice *
Quantity de todos os registros de InvoiceLine relacionados a um Invoice.
Implementar uma solução que garanta a integridade dessa regra.
'''

CREATE OR REPLACE FUNCTION check_invoice_total_integrity_func()
RETURNS TRIGGER AS $$
DECLARE total_value FLOAT;
BEGIN
    
    SELECT SUM(unit_price * quantity) INTO total_value
    FROM invoice_line
    WHERE invoice_line.invoice_id = NEW.invoice_id;

    IF total_value <> NEW.total THEN
        RAISE EXCEPTION 'ERRO!!!!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_invoice_total_integrity_on_create_invoice_line_func()
RETURNS TRIGGER AS $$
DECLARE total_value FLOAT;
BEGIN
    
    SELECT SUM(unit_price * quantity) INTO total_value
    FROM invoice_line
    WHERE invoice_line.invoice_id = NEW.invoice_id;

    IF total_value <> (select total from invoice where invoice.invoice_id = NEW.invoice_id) THEN
        RAISE EXCEPTION 'ERRO!!!!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_invoice_total_integrity_on_delete_invoice_line_func()
RETURNS TRIGGER AS $$
DECLARE total_value FLOAT;
BEGIN
    
    SELECT SUM(unit_price * quantity) INTO total_value
    FROM invoice_line
    WHERE invoice_line.invoice_id = old.invoice_id;

    IF total_value <> (select total from invoice where invoice.invoice_id = old.invoice_id) THEN
        RAISE EXCEPTION 'ERRO!!!!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE or replace TRIGGER check_invoice_total_integrity
AFTER update of total
ON invoice
FOR EACH ROW
EXECUTE FUNCTION check_invoice_total_integrity_func();

CREATE or replace TRIGGER check_invoice_total_integrity_on_insert_and_update_invoice_line
AFTER insert or UPDATE OF unit_price, quantity
ON invoice_line
FOR EACH ROW
EXECUTE FUNCTION check_invoice_total_integrity_on_create_invoice_line_func();

CREATE or replace TRIGGER check_invoice_total_integrity_on_delete_invoice_line
AFTER delete
ON invoice_line
FOR EACH ROW
EXECUTE FUNCTION check_invoice_total_integrity_on_delete_invoice_line_func();