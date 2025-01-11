'''
2. Implementar triggers que garantam a validação das regras semânticas criadas.
'''

CREATE OR REPLACE FUNCTION check_tracks_limit_func()
RETURNS TRIGGER AS $$
DECLARE
    tracks_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO tracks_count
    FROM track
    WHERE album_id = NEW.album_id;

    IF tracks_count >= 57 THEN
        RAISE EXCEPTION 'ERRO: O álbum já possui muitas músicas';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_tracks_limit_integrity
BEFORE INSERT
ON track
FOR EACH ROW
EXECUTE FUNCTION check_tracks_limit_func();

-- Nomes precisam ter a primeira letra maiuscúla e as outras minuscúlas

CREATE OR REPLACE FUNCTION check_if_names_are_capitalized_func()
RETURNS TRIGGER AS $$
BEGIN
    IF INITCAP(NEW.first_name) <> NEW.first_name OR 
       INITCAP(NEW.last_name) <> NEW.last_name THEN
        RAISE EXCEPTION 'Nome precisa iniciar com maiúscula e os outros caracteres devem ser minúsculos';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_names_are_capitalized_trigger
BEFORE INSERT OR UPDATE OF first_name, last_name
ON employee
FOR EACH ROW
EXECUTE FUNCTION check_if_names_are_capitalized_func();