-- Deve falhar
insert into track (track_id, name, album_id, media_type_id, milliseconds, unit_price)
values (66666, 'name',141, 1, 11, 1);

-- Deve falhar
insert into employee (employee_id, first_name, last_name) values (9,'hendel', 'fonseca');

-- Deve falhar
insert into employee (employee_id, first_name, last_name) values (10,'GabriEl', 'Breder');

-- Nomes corretos, deve funcionar
insert into employee (employee_id, first_name, last_name) values (11,'Bárbara', 'Moraes');