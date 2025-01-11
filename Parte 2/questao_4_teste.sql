--Comandos de teste, devem falhar pois quebram a integridade da coluna total do invoice_line

insert into invoice_line (invoice_line_id,invoice_id, track_id, unit_price, quantity) values (2241,1, 2, 0.99, 1);

update invoice_line set unit_price = 2 where invoice_line_id = 1;

delete from invoice_line where invoice_line_id = 1;

update invoice set total = 20 where invoice_id = 1;