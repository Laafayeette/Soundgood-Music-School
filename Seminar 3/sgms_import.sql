CREATE TABLE address (
 address_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 street VARCHAR(500),
 city VARCHAR(500),
 zip VARCHAR(500)
);

ALTER TABLE address ADD CONSTRAINT PK_address PRIMARY KEY (address_id);

CREATE TYPE difficulty AS ENUM ('beginner', 'intermediate', 'advanced');

CREATE TABLE instrument_competence (
 instrument_competence_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 instrument_level VARCHAR(500),
 instrument_type VARCHAR(500)
);

ALTER TABLE instrument_competence ADD CONSTRAINT PK_instrument_competence PRIMARY KEY (instrument_competence_id);


CREATE TABLE person (
 person_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 first_name VARCHAR(500),
 last_name VARCHAR(500),
 personal_number VARCHAR(500) UNIQUE NOT NULL
);

ALTER TABLE person ADD CONSTRAINT PK_person PRIMARY KEY (person_id);


CREATE TABLE person_address (
 address_id INT NOT NULL REFERENCES "address" ON DELETE CASCADE,
 person_id INT NOT NULL REFERENCES "person" ON DELETE CASCADE
);

ALTER TABLE person_address ADD CONSTRAINT PK_person_address PRIMARY KEY (address_id,person_id);


CREATE TABLE person_instrument_competence (
 person_id INT NOT NULL REFERENCES "person" ON DELETE CASCADE,
 instrument_competence_id INT NOT NULL REFERENCES "instrument_competence" ON DELETE CASCADE
);

ALTER TABLE person_instrument_competence ADD CONSTRAINT PK_person_instrument_competence PRIMARY KEY (person_id,instrument_competence_id);


CREATE TABLE phone (
 phone_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 phone_number VARCHAR(500) UNIQUE NOT NULL
);

ALTER TABLE phone ADD CONSTRAINT PK_phone PRIMARY KEY (phone_id);


CREATE TABLE rule (
 rule_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 value VARCHAR(500),
 description VARCHAR(500),
 type_of_rule VARCHAR(500),
 duration VARCHAR(500)
);

ALTER TABLE rule ADD CONSTRAINT PK_rule PRIMARY KEY (rule_id);


CREATE TABLE stock (
 stock_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 brand_of_instrument VARCHAR(500),
 type_of_instrument VARCHAR(500),
 price_of_rental INT
);

ALTER TABLE stock ADD CONSTRAINT PK_stock PRIMARY KEY (stock_id);


CREATE TABLE contact_person (
 contact_person_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 person_id INT NOT NULL
);

ALTER TABLE contact_person ADD CONSTRAINT PK_contact_person PRIMARY KEY (contact_person_id);


CREATE TABLE instructor (
 instructor_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 can_teach_ensembles VARCHAR(500),
 person_id INT NOT NULL
);

ALTER TABLE instructor ADD CONSTRAINT PK_instructor PRIMARY KEY (instructor_id);


CREATE TABLE instrument (
 instrument_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 stock_id INT NOT NULL
);

ALTER TABLE instrument ADD CONSTRAINT PK_instrument PRIMARY KEY (instrument_id);


CREATE TABLE person_phone (
 person_id INT NOT NULL REFERENCES "person" ON DELETE CASCADE,
 phone_id INT NOT NULL REFERENCES "phone" ON DELETE CASCADE
);

ALTER TABLE person_phone ADD CONSTRAINT PK_person_phone PRIMARY KEY (person_id,phone_id);


CREATE TABLE price_scheme (
 price_scheme_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 level_type difficulty,
 lesson_type VARCHAR(500) NOT NULL,
 price INT NOT NULL,
 price_time TIMESTAMP(6),
 rule_id INT NOT NULL
);

ALTER TABLE price_scheme ADD CONSTRAINT PK_price_scheme PRIMARY KEY (price_scheme_id);


CREATE TABLE student (
 student_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 person_id INT NOT NULL,
 contact_person_id INT,
 rule_id INT NOT NULL
);

ALTER TABLE student ADD CONSTRAINT PK_student PRIMARY KEY (student_id);


CREATE TABLE student_sibling (
 student_id INT NOT NULL REFERENCES "student" ON DELETE CASCADE,
 sibling_id INT NOT NULL REFERENCES "student" ON DELETE CASCADE
);

ALTER TABLE student_sibling ADD CONSTRAINT PK_student_sibling PRIMARY KEY (student_id,sibling_id);


CREATE TABLE time_available (
 start_time TIMESTAMP(6) NOT NULL,
 instructor_id INT NOT NULL REFERENCES "instructor" ON DELETE CASCADE,
 end_time TIME(6)
);

ALTER TABLE time_available ADD CONSTRAINT PK_time_available PRIMARY KEY (start_time,instructor_id);

CREATE TABLE lesson (
 lesson_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 level_of_lesson difficulty,
 time_of_lesson TIMESTAMP(6),
 instructor_id INT,
 price_scheme_id INT
);

ALTER TABLE lesson ADD CONSTRAINT PK_lesson PRIMARY KEY (lesson_id);


CREATE TABLE rental (
 instrument_id INT NOT NULL,
 student_id INT NOT NULL,
 time_of_rental TIMESTAMP(6) NOT NULL,
 rule_id INT NOT NULL
);

ALTER TABLE rental ADD CONSTRAINT PK_rental PRIMARY KEY (instrument_id,student_id);


CREATE TABLE solo_lesson (
 lesson_id INT NOT NULL REFERENCES "lesson" ON DELETE CASCADE,
 type_of_instrument VARCHAR(500)
);

ALTER TABLE solo_lesson ADD CONSTRAINT PK_solo_lesson PRIMARY KEY (lesson_id);


CREATE TABLE student_lesson (
 lesson_id INT NOT NULL REFERENCES "lesson" ON DELETE CASCADE,
 student_id INT NOT NULL REFERENCES "student" ON DELETE CASCADE
);

ALTER TABLE student_lesson ADD CONSTRAINT PK_student_lesson PRIMARY KEY (lesson_id,student_id);


CREATE TABLE ensemble (
 lesson_id INT NOT NULL REFERENCES "lesson" ON DELETE CASCADE,
 ensemble_genre VARCHAR(500),
 ensemble_minimum VARCHAR(500),
 ensemble_maximum VARCHAR(500)
);

ALTER TABLE ensemble ADD CONSTRAINT PK_ensemble PRIMARY KEY (lesson_id);


CREATE TABLE group_lesson (
 lesson_id INT NOT NULL REFERENCES "lesson" ON DELETE CASCADE,
 lesson_minimum VARCHAR(500),
 lesson_maximum VARCHAR(500),
 type_of_instrument VARCHAR(500)
);

ALTER TABLE group_lesson ADD CONSTRAINT PK_group_lesson PRIMARY KEY (lesson_id);


ALTER TABLE person_address ADD CONSTRAINT FK_person_address_0 FOREIGN KEY (address_id) REFERENCES address (address_id);
ALTER TABLE person_address ADD CONSTRAINT FK_person_address_1 FOREIGN KEY (person_id) REFERENCES person (person_id);


ALTER TABLE person_instrument_competence ADD CONSTRAINT FK_person_instrument_competence_0 FOREIGN KEY (person_id) REFERENCES person (person_id);
ALTER TABLE person_instrument_competence ADD CONSTRAINT FK_person_instrument_competence_1 FOREIGN KEY (instrument_competence_id) REFERENCES instrument_competence (instrument_competence_id);


ALTER TABLE contact_person ADD CONSTRAINT FK_contact_person_0 FOREIGN KEY (person_id) REFERENCES person (person_id);


ALTER TABLE instructor ADD CONSTRAINT FK_instructor_0 FOREIGN KEY (person_id) REFERENCES person (person_id);


ALTER TABLE instrument ADD CONSTRAINT FK_instrument_0 FOREIGN KEY (stock_id) REFERENCES stock (stock_id);


ALTER TABLE person_phone ADD CONSTRAINT FK_person_phone_0 FOREIGN KEY (person_id) REFERENCES person (person_id);
ALTER TABLE person_phone ADD CONSTRAINT FK_person_phone_1 FOREIGN KEY (phone_id) REFERENCES phone (phone_id);


ALTER TABLE price_scheme ADD CONSTRAINT FK_price_scheme_0 FOREIGN KEY (rule_id) REFERENCES rule (rule_id);


ALTER TABLE student ADD CONSTRAINT FK_student_0 FOREIGN KEY (person_id) REFERENCES person (person_id);
ALTER TABLE student ADD CONSTRAINT FK_student_1 FOREIGN KEY (contact_person_id) REFERENCES contact_person (contact_person_id);
ALTER TABLE student ADD CONSTRAINT FK_student_2 FOREIGN KEY (rule_id) REFERENCES rule (rule_id);


ALTER TABLE student_sibling ADD CONSTRAINT FK_student_sibling_0 FOREIGN KEY (student_id) REFERENCES student (student_id);
ALTER TABLE student_sibling ADD CONSTRAINT FK_student_sibling_1 FOREIGN KEY (sibling_id) REFERENCES student (student_id);


ALTER TABLE time_available ADD CONSTRAINT FK_time_available_0 FOREIGN KEY (instructor_id) REFERENCES instructor (instructor_id);


ALTER TABLE lesson ADD CONSTRAINT FK_lesson_0 FOREIGN KEY (instructor_id) REFERENCES instructor (instructor_id);
ALTER TABLE lesson ADD CONSTRAINT FK_lesson_1 FOREIGN KEY (price_scheme_id) REFERENCES price_scheme (price_scheme_id);


ALTER TABLE rental ADD CONSTRAINT FK_rental_0 FOREIGN KEY (instrument_id) REFERENCES instrument (instrument_id);
ALTER TABLE rental ADD CONSTRAINT FK_rental_1 FOREIGN KEY (student_id) REFERENCES student (student_id);
ALTER TABLE rental ADD CONSTRAINT FK_rental_2 FOREIGN KEY (rule_id) REFERENCES rule (rule_id);


ALTER TABLE solo_lesson ADD CONSTRAINT FK_solo_lesson_0 FOREIGN KEY (lesson_id) REFERENCES lesson (lesson_id);


ALTER TABLE student_lesson ADD CONSTRAINT FK_student_lesson_0 FOREIGN KEY (lesson_id) REFERENCES lesson (lesson_id);
ALTER TABLE student_lesson ADD CONSTRAINT FK_student_lesson_1 FOREIGN KEY (student_id) REFERENCES student (student_id);


ALTER TABLE ensemble ADD CONSTRAINT FK_ensemble_0 FOREIGN KEY (lesson_id) REFERENCES lesson (lesson_id);


ALTER TABLE group_lesson ADD CONSTRAINT FK_group_lesson_0 FOREIGN KEY (lesson_id) REFERENCES lesson (lesson_id);


