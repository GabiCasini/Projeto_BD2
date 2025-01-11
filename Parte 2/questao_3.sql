'''
3. Implementar procedimentos armazenados (stored procedures) que garantam a
validação das regras semânticas criadas. Nesse caso, o mecanismo de permissões deve
ser utilizado para criar um usuário que somente tenha acesso à manipulação dos dados
envolvidos através do procedimento definido.
'''

-- Funcionário precisa ter mais de 18 anos no dia em que foi contratado

CREATE OR REPLACE PROCEDURE insert_employee(
	p_employee_id INT,
    p_employee_first_name VARCHAR(20),
    p_employee_last_name VARCHAR(20),
    p_employee_birth_date TIMESTAMP,
    p_employee_hire_date TIMESTAMP
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    employee_age_at_hiring INT;
BEGIN
    SELECT DATE_PART('year', AGE(p_employee_hire_date, p_employee_birth_date))
    INTO employee_age_at_hiring;

    IF employee_age_at_hiring < 18 THEN
        RAISE EXCEPTION 'FUNCIONÁRIO PRECISA TER 18 ANOS';
    END IF;

    INSERT INTO employee (employee_id, first_name, last_name, birth_date, hire_date)
    VALUES (p_employee_id, p_employee_first_name, p_employee_last_name, p_employee_birth_date, p_employee_hire_date);
    
    RAISE NOTICE 'Linha inserida com sucesso';
END;
$$;