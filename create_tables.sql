CREATE TABLE area
(
    area_id   serial primary key,
    area_name text not null
);

CREATE TABLE employer
(
    employer_id   SERIAL PRIMARY KEY,
    employer_name TEXT    NOT NULL,
    area_id       INTEGER NOT NULL REFERENCES area (area_id)
);

CREATE TABLE person
(
    person_id   SERIAL PRIMARY KEY,
    first_name  TEXT NOT NULL,
    middle_name TEXT,
    last_name   TEXT,
    email       TEXT,
    area_id     INTEGER REFERENCES area (area_id)


)

CREATE TABLE vacancy
(
    vacancy_id         SERIAL PRIMARY KEY,
    employer_id        INTEGER   NOT NULL REFERENCES employer (employer_id),
    position_name      TEXT      NOT NULL,
    compensation_from  INTEGER,
    compensation_to    INTEGER,
    compensation_gross BOOLEAN            DEFAULT true,
    created_at         TIMESTAMP NOT NULL DEFAULT now()

);

CREATE TABLE resume
(
    resume_id            SERIAL PRIMARY KEY,
    person_id            INTEGER REFERENCES person (person_id),
    desired_position     TEXT NOT NULL,
    desired_compensation INTEGER,
    experience           SMALLINT
);

CREATE TABLE response
(
    response_id SERIAL PRIMARY KEY,
    resume_id   INTEGER REFERENCES resume (resume_id),
    vacancy_id  INTEGER REFERENCES vacancy (vacancy_id),
    created_at  TIMESTAMP NOT NULL DEFAULT now()
);
