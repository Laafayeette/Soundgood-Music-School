CREATE DATABASE sgms_historical_db;

\c sgms_historical_db;

CREATE TYPE difficulty AS ENUM ('beginner', 'intermediate', 'advanced');

CREATE EXTENSION postgres_fdw;

CREATE SERVER hist_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (dbname 'soundgood', host 'localhost', port '5432');

CREATE USER MAPPING FOR POSTGRES SERVER hist_server OPTIONS (user 'postgres', password '');

CREATE SCHEMA sgms_historical_schema;

IMPORT FOREIGN SCHEMA public
FROM SERVER hist_server INTO sgms_historical_schema;

CREATE TABLE sgms_historical_schema.historical_table (
    historical_table_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    lesson_id INT,
    student_id INT,
    lesson_type VARCHAR(500) NOT NULL,
    ensemble_genre VARCHAR(500),
    type_of_instrument VARCHAR(500),
    price INT NOT NULL,
    first_name VARCHAR(500),
    last_name VARCHAR(500),
    phone_number VARCHAR(500)
);
ALTER TABLE sgms_historical_schema.historical_table ADD CONSTRAINT PK_historical_table PRIMARY KEY (historical_table_id);

  --sgms_historical_schema.

INSERT INTO sgms_historical_schema.historical_table (
    lesson_id,
    student_id, 
    lesson_type,
    ensemble_genre,
    type_of_instrument,
    price,
    first_name,
    last_name,
    phone_number
)
SELECT l.lesson_id, s.student_id,
CASE
    WHEN (sol.lesson_id = l.lesson_id) THEN 'solo_lesson'
    WHEN (gl.lesson_id = l.lesson_id) THEN 'group_lesson'
    WHEN (e.lesson_id = l.lesson_id) THEN 'ensemble'
END AS lesson_type,
e.ensemble_genre,
CASE
    WHEN (sol.lesson_id =l.lesson_id) THEN sol.type_of_instrument
    WHEN (gl.lesson_id = l.lesson_id) THEN gl.type_of_instrument
END AS type_of_instrument,
ps.price,
p.first_name,
p.last_name,
MAX(ph.phone_number) AS phone_number
FROM sgms_historical_schema.lesson AS l
LEFT JOIN sgms_historical_schema.solo_lesson AS sol ON sol.lesson_id = l.lesson_id
LEFT JOIN sgms_historical_schema.group_lesson AS gl ON gl.lesson_id = l.lesson_id
LEFT JOIN sgms_historical_schema.ensemble AS e ON e.lesson_id = l.lesson_id
LEFT JOIN sgms_historical_schema.price_scheme AS ps ON ps.price_scheme_id = l.price_scheme_id
LEFT JOIN sgms_historical_schema.student_lesson AS sl ON sl.lesson_id = l.lesson_id
LEFT JOIN sgms_historical_schema.student AS s ON sl.student_id = s.student_id
LEFT JOIN sgms_historical_schema.person AS p ON p.person_id = s.person_id
LEFT JOIN sgms_historical_schema.person_phone AS pp ON pp.person_id = p.person_id
LEFT JOIN sgms_historical_schema.phone AS ph ON ph.phone_id = pp.phone_id
GROUP BY l.lesson_id, s.student_id, sol.lesson_id, gl.lesson_id, e.lesson_id, e.ensemble_genre, sol.type_of_instrument, gl.type_of_instrument, ps.price, p.first_name, p.last_name
ORDER BY l.lesson_id;