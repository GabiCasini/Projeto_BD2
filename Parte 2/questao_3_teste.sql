set role postgres;
create role new_user;
GRANT EXECUTE ON PROCEDURE insert_employee(INT, VARCHAR, VARCHAR, TIMESTAMP, TIMESTAMP) TO new_user;
set role new_user;

-- Deve falhar
call insert_employee(50,'First', 'Last', '2020-05-03', '2023-06-07');

-- Deve funcionar
call insert_employee(55,'First', 'Last', '2000-05-03', '2023-06-07');

set role postgres;