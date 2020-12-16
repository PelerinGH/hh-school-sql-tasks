-- last 10 vacancy without salary
SELECT vacancy.position_name  AS position_name,
       area.area_name         AS area_name,
       employer.employer_name AS employer_name
FROM vacancy
         INNER JOIN employer ON vacancy.employer_id = employer.employer_id
         INNER JOIN area ON employer.area_id = area.area_id
WHERE vacancy.compensation_from IS NULL
  AND vacancy.compensation_to IS NULL
ORDER BY vacancy.created_at DESC
LIMIT 10;


--average for min,max and average gross compensation
WITH gross_compensations AS (
    SELECT vacancy.position_name,
           CASE
               WHEN compensation_gross IS TRUE
                   THEN compensation_to
               ELSE compensation_to / 0.87
               END AS compensation_to,
           CASE
               WHEN compensation_gross IS TRUE
                   THEN compensation_from
               ELSE compensation_from / 0.87
               END AS compensation_from
    FROM vacancy
)
SELECT avg(compensation_to)                           AS average_max_compensation,
       avg(compensation_from)                         AS average_min_compensation,
       avg((compensation_to + compensation_from) / 2) as average_average_compensation
FROM gross_compensations;


-- top 5 employers by max number of responses per vacancy
WITH responses_per_vacancy AS (
    SELECT vacancy_id,
           employer_id,
           count(response_id) as responces_number
    FROM vacancy
             LEFT JOIN response on vacancy.vacancy_id = response.vacancy_id
    GROUP BY vacancy_id, employer_id
),
     max_responces_per_employer AS (
         SELECT employer_id,
                max(responces_number) as max_responces
         FROM responses_per_vacancy
         GROUP BY employer_id
     )
SELECT employer_name
FROM max_responces_per_employer
INNER JOIN employer ON employer.employer_id = max_responces_per_employer.employer_id
ORDER BY max_responces DESC, employer_name
LIMIT 5;


--median number of vacancies of employers
WITH vacancies_per_employer AS (
    SELECT employer_id,
           count(vacancy_id) AS vacancies_number
    FROM vacancy
    GROUP BY employer_id
)
SELECT percentile_cont(0.5) WITHIN GROUP ( ORDER BY vacancies_number) AS median_number
FROM vacancies_per_employer;

--min and max time from vacancy creation to first response for each city
WITH first_response_per_vacancy AS (
    SELECT vacancy.vacancy_id                            AS vacancy_id,
           MIN(response.created_at - vacancy.created_at) as time_to_response
    FROM vacancy
             INNER JOIN response ON vacancy.vacancy_id = response.vacancy_id
    GROUP BY vacancy.vacancy_id
)
SELECT area_name,
       MIN(time_to_response) AS min_time_to_first_response,
       MAX(time_to_response) AS max_time_to_first_response
FROM first_response_per_vacancy
         INNER JOIN employer ON employer.employer_id = first_response_per_vacancy.vacancy_id
         INNER JOIN area on area.area_id = employer.area_id
GROUP BY area_name
