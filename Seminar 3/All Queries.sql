---Query 1
SELECT EXTRACT(MONTH FROM time_of_lesson) AS month,
COUNT(lesson.lesson_id) AS total, 
COUNT(solo_lesson.lesson_id) AS solo,
COUNT(group_lesson.lesson_id) AS group,
COUNT(ensemble.lesson_id) as ensemble
FROM lesson
LEFT JOIN solo_lesson ON solo_lesson.lesson_id = lesson.lesson_id
LEFT JOIN group_lesson ON group_lesson.lesson_id = lesson.lesson_id
LEFT JOIN ensemble ON ensemble.lesson_id = lesson.lesson_id
WHERE EXTRACT(YEAR FROM time_of_lesson) = '2024'
GROUP BY month
ORDER BY month;

---Query 2 View 1
CREATE VIEW no_of_siblings_for_null AS
SELECT COUNT(ss.sibling_id) AS no_of_siblings, COUNT(s.student_id) AS no_of_students
	FROM student AS s
	FULL JOIN student_sibling AS ss
	ON ss.student_id = s.student_id
	WHERE ss.sibling_id IS NULL;

---Query 2 View 2
CREATE VIEW no_of_siblings_for_not_null AS
SELECT no_of_siblings, COUNT(*) as no_of_students
FROM (
    SELECT COUNT(*) AS no_of_siblings
    FROM (
        SELECT student_id AS s_id FROM student_sibling

        UNION ALL 

        SELECT sibling_id AS s_id FROM student_sibling
    )
    GROUP BY s_id
)
GROUP BY no_of_siblings
ORDER BY no_of_siblings;

---Query 2 Master View
CREATE MATERIALIZED VIEW no_of_siblings_per_student AS
SELECT no_of_siblings, no_of_students
FROM no_of_siblings_for_null

UNION ALL

SELECT no_of_siblings, no_of_students
FROM  no_of_siblings_for_not_null;

---Query 2
SELECT *
FROM no_of_siblings_per_student;

---Query 3
SELECT 	i.instructor_id, 
p.first_name, p.last_name,
COUNT(*) AS no_of_lessons FROM instructor AS i
INNER JOIN person AS p ON p.person_id = i.person_id
INNER JOIN lesson AS l ON i.instructor_id = l.instructor_id
WHERE EXTRACT(MONTH FROM l.time_of_lesson) = EXTRACT(MONTH FROM NOW())
GROUP BY i.instructor_id, p.first_name, p.last_name
HAVING COUNT(lesson_id) > 1
ORDER BY no_of_lessons DESC;

---Query 4 View
CREATE VIEW dow AS
SELECT l.lesson_id,
    CASE
        WHEN (EXTRACT(DOW FROM l.time_of_lesson) = 0) THEN 'Mon'
        WHEN (EXTRACT(DOW FROM l.time_of_lesson) = 1) THEN 'Tue'
        WHEN (EXTRACT(DOW FROM l.time_of_lesson) = 2) THEN 'Wed'
        WHEN (EXTRACT(DOW FROM l.time_of_lesson) = 3) THEN 'Thu'
        WHEN (EXTRACT(DOW FROM l.time_of_lesson) = 4) THEN 'Fri'
        WHEN (EXTRACT(DOW FROM l.time_of_lesson) = 5) THEN 'Sat'
        WHEN (EXTRACT(DOW FROM l.time_of_lesson) = 6) THEN 'Sun'
    END AS day,
    l.time_of_lesson AS lesson_time
FROM lesson AS l;



---Query 4
SELECT
dow.day,
e.ensemble_genre AS genre,
CASE
    WHEN(CAST(ensemble_maximum AS INTEGER) - COUNT(DISTINCT sl.student_id)) > 2 THEN 'Many Seats'
    WHEN(CAST(ensemble_maximum AS INTEGER) - COUNT(DISTINCT sl.student_id)) > 0 THEN '1 or 2 Seats'
    WHEN(CAST(ensemble_maximum AS INTEGER) - COUNT(DISTINCT sl.student_id)) < 1 THEN 'No Seats'
END AS no_of_free_seats
FROM ensemble AS e
LEFT JOIN dow ON e.lesson_id = dow.lesson_id
LEFT JOIN lesson AS l ON l.lesson_id = e.lesson_id
LEFT JOIN student_lesson AS sl ON e.lesson_id = sl.lesson_id
GROUP BY e.lesson_id, dow.day, l.time_of_lesson
HAVING EXTRACT(WEEK FROM l.time_of_lesson) = EXTRACT(WEEK FROM NOW()) +1
ORDER BY EXTRACT(DOW FROM l.time_of_lesson), e.ensemble_genre;
