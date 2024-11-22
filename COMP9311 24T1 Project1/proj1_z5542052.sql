------------------------------------------------------
-- COMP9311 24T1 Project 1 
-- SQL and PL/pgSQL 
-- Template
-- Name: Yixin Kang
-- zID: z5542052
------------------------------------------------------

-- Q1:
create or replace view Q1(subject_code)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT code as subject_code 
FROM orgunits, subjects
WHERE orgunits.id = subjects.offeredby
AND orgunits.longname LIKE '%Information%'
AND orgunits.utype = 
(SELECT id FROM orgunit_types WHERE orgunit_types.name LIKE '%School%')
AND subjects.code ~ '[A-Za-z]{4}7[0-9]{3}';


-- Q2:
CREATE OR REPLACE VIEW lec_lab(course_id) 
AS
--... SQL statements, get the course id with lecture and laboratory classes
SELECT DISTINCT c1.course
FROM classes c1, classes c2
WHERE c1.course = c2.course
AND c1.ctype =
(SELECT id FROM class_types WHERE name = 'Lecture')
AND c2.ctype = 
(SELECT id FROM class_types WHERE name = 'Laboratory');

CREATE OR REPLACE VIEW two_ctype(course_id) AS
SELECT course
FROM classes
GROUP BY course
HAVING count(distinct(ctype)) = 2;

create or replace view Q2(course_id)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT courses.id AS course_id
FROM courses, subjects
WHERE courses.subject = subjects.id 
AND subjects.code LIKE 'COMP%'
AND courses.id in
((SELECT * FROM two_ctype) 
INTERSECT  
(SELECT * FROM lec_lab))
;

-- Q3:
CREATE OR REPLACE VIEW q3_1(course_id) AS
SELECT courses.id 
FROM courses
INNER JOIN course_staff on courses.id = course_staff.course
INNER JOIN people on course_staff.staff = people.id
WHERE people.title = 'Prof'
GROUP BY courses.id
HAVING count(title) >= 2;

CREATE OR REPLACE VIEW q3_2(course_id) AS
SELECT courses.id
FROM courses, semesters
WHERE courses.semester = semesters.id
AND semesters.year >= 2008
AND semesters.year <= 2012
AND courses.id in (SELECT * FROM q3_1);

create or replace view Q3(unsw_id)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT people.unswid 
FROM course_enrolments
INNER JOIN people on people.id = course_enrolments.student
WHERE people.unswid::text  LIKE '320%' AND course_enrolments.course in (SELECT * FROM q3_2)
GROUP BY people.id
HAVING count(course_enrolments.course) >= 5
;

-- Q4:
CREATE OR REPLACE VIEW q4_1(course_id, avg_mark) AS
SELECT course, round(avg(mark),2)
FROM course_enrolments
WHERE grade in ('DN','HD')
GROUP BY course;

CREATE OR REPLACE VIEW q4_2(semesters_term, orgunits_name, course_id) AS
SELECT semesters.term, orgunits.name, courses.id
FROM courses
INNER JOIN semesters ON courses.semester = semesters.id
INNER JOIN subjects ON courses.subject = subjects.id 
INNER JOIN orgunits ON subjects.offeredby = orgunits.id
INNER JOIN orgunit_types ON orgunits.utype = orgunit_types.id
WHERE semesters.year = 2012
AND orgunit_types.name = 'Faculty';

CREATE OR REPLACE VIEW q4_3(semesters_term, orgunits_name, max_avg_mark) AS
SELECT q4_2.semesters_term, q4_2.orgunits_name, max(q4_1.avg_mark)
FROM q4_1
INNER JOIN q4_2 ON q4_1.course_id = q4_2.course_id
GROUP BY q4_2.semesters_term, q4_2.orgunits_name;



create or replace view Q4(course_id, avg_mark)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT q4_1.course_id, q4_1.avg_mark
FROM q4_1
INNER JOIN q4_2 ON q4_1.course_id = q4_2.course_id
INNER JOIN q4_3 ON q4_2.semesters_term = q4_3.semesters_term
AND q4_2.orgunits_name = q4_3.orgunits_name
AND q4_1.avg_mark = q4_3.max_avg_mark
;

-- Q5:
CREATE OR REPLACE VIEW q5_1(course_id) AS
SELECT courses.id 
FROM courses
INNER JOIN course_staff on courses.id = course_staff.course
INNER JOIN people on course_staff.staff = people.id
WHERE people.title = 'Prof'
GROUP BY courses.id
HAVING count(title) >= 2;

CREATE OR REPLACE VIEW q5_2(course_id) AS
SELECT courses.id
FROM courses, semesters
WHERE courses.semester = semesters.id
AND semesters.year >= 2005
AND semesters.year <= 2015
AND courses.id in (SELECT * FROM q5_1);

CREATE OR REPLACE VIEW q5_3(course_id) AS
SELECT course
FROM course_enrolments
WHERE course in (SELECT * FROM q5_1)
AND course in (SELECT * FROM q5_2)
GROUP BY course
HAVING count(student) > 500;

create or replace view Q5(course_id, staff_name)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT q5_3.course_id, string_agg(people.given, '; ' ORDER BY people.given)
FROM q5_3
INNER JOIN course_staff ON q5_3.course_id = course_staff.course
INNER JOIN people ON course_staff.staff = people.id
WHERE people.title = 'Prof' GROUP BY q5_3.course_id
;

-- Q6:
CREATE OR REPLACE VIEW q6_1(room_id, subjects_code, frequency) AS
SELECT rooms.id, subjects.code,count(classes.id) 
FROM rooms
INNER JOIN classes ON classes.room = rooms.id
INNER JOIN courses ON classes.course = courses.id 
INNER JOIN semesters ON courses.semester = semesters.id
INNER JOIN subjects ON courses.subject = subjects.id
WHERE semesters.year = 2012
GROUP BY rooms.id, subjects.code;

CREATE OR REPLACE VIEW q6_2(room_id, room_frequency) AS
SELECT room_id, sum(frequency) AS room_frequency  
FROM q6_1
GROUP BY room_id;

CREATE OR REPLACE VIEW q6_3(room_id, room_frequency) AS
SELECT room_id, room_frequency
FROM q6_2 
WHERE room_frequency = 
(SELECT max(room_frequency) FROM q6_2);

CREATE OR REPLACE VIEW q6_4(room_id, subjects_code,frequency) AS
SELECT *
FROM q6_1 
WHERE room_id = 
(SELECT room_id FROM q6_3);


create or replace view Q6(room_id, subject_code) 
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT room_id, subjects_code
FROM q6_4
WHERE frequency = (SELECT max(frequency) FROM q6_4)
;

-- Q7:
CREATE OR REPLACE VIEW q7_1(student_id, program_id, starting, ending, orgunit_id, program_uoc, course_id, subject_uoc) AS
SELECT people.unswid, program_enrolments.program, semesters.starting, semesters.ending, programs.offeredby, programs.uoc, course_enrolments.course, subjects.uoc
FROM people
INNER JOIN program_enrolments ON people.id = program_enrolments.student
INNER JOIN programs ON program_enrolments.program = programs.id 
INNER JOIN course_enrolments ON course_enrolments.student = people.id
INNER JOIN courses ON courses.id = course_enrolments.course AND courses.semester = program_enrolments.semester
INNER JOIN subjects ON courses.subject = subjects.id
INNER JOIN semesters ON courses.semester = semesters.id
WHERE course_enrolments.mark >= 50
ORDER BY people.unswid, program_enrolments.program;

CREATE OR REPLACE VIEW q7_2(student_id, orgunit_id, duration) AS
SELECT student_id, orgunit_id, (max(ending) - min(starting)) as duration 
FROM q7_1
GROUP BY student_id, orgunit_id;

CREATE OR REPLACE VIEW q7_3(student_id, program_id, orgunit_id, program_uoc, total_uoc) AS
SELECT student_id, program_id, orgunit_id, program_uoc, sum(subject_uoc) AS total_uoc
FROM q7_1
GROUP BY student_id, program_id, orgunit_id, program_uoc;

CREATE OR REPLACE VIEW q7_4(student_id, program_id, orgunit_id, complete) AS
SELECT student_id, program_id, orgunit_id,
CASE WHEN total_uoc >= program_uoc THEN 1 ELSE 0 END AS complete
FROM q7_3;

CREATE OR REPLACE VIEW q7_5(student_id, orgunit_id) AS
SELECT student_id, orgunit_id
FROM q7_4
GROUP BY student_id, orgunit_id
HAVING SUM(complete) >= 2;


create or replace view Q7(student_id, program_id) 
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT q7_5.student_id, q7_4.program_id
FROM q7_5
INNER JOIN q7_2 ON q7_5.student_id = q7_2.student_id AND q7_5.orgunit_id = q7_2.orgunit_id
INNER JOIN q7_4 ON q7_5.student_id = q7_4.student_id AND q7_5.orgunit_id = q7_4.orgunit_id
WHERE q7_2.duration <= 1000 
;

-- Q8:
CREATE OR REPLACE VIEW q8_1(people_id, staff_id, orgunit_id, sum_roles_org) AS
SELECT people.id, people.unswid, affiliations.orgunit, count(affiliations.role)
FROM affiliations
INNER JOIN people ON people.id = affiliations.staff
GROUP BY people.id, people.unswid, affiliations.orgunit
HAVING count(affiliations.role) >=3;

CREATE OR REPLACE VIEW q8_2(staff_id, sum_roles) AS
SELECT people.unswid, count(affiliations.role)
FROM affiliations
INNER JOIN people ON people.id = affiliations.staff
GROUP BY people.id;

CREATE OR REPLACE VIEW q8_3(staff_id, student_id, mark) AS
SELECT new_q8_1.staff_id, course_enrolments.student, course_enrolments.mark
FROM course_staff
INNER JOIN (SELECT DISTINCT staff_id, people_id FROM q8_1) AS new_q8_1 ON new_q8_1.people_id = course_staff.staff
INNER JOIN staff_roles ON course_staff.role = staff_roles.id
INNER JOIN courses ON course_staff.course = courses.id
INNER JOIN course_enrolments ON course_enrolments.course = courses.id
INNER JOIN semesters ON courses.semester = semesters.id
WHERE semesters.year = 2012
AND staff_roles.name = 'Course Convenor';

CREATE OR REPLACE VIEW q8_4(staff_id, hdn, total) AS
SELECT staff_id, sum(CASE WHEN mark >= 75 THEN 1 ELSE 0 END) AS hdn, sum(CASE WHEN mark is not NULL THEN 1 ELSE 0 END) AS total
FROM q8_3
GROUP BY staff_id;

CREATE OR REPLACE VIEW q8_5(staff_id, hdn_rate) AS
SELECT staff_id, ROUND(CAST(hdn AS numeric)/total,2) AS hdn_rate
FROM q8_4;

CREATE OR REPLACE VIEW q8_6(staff_id, hdn_rate, rank_hdn) AS
SELECT staff_id, hdn_rate, RANK() OVER (ORDER BY hdn_rate DESC) AS rank_column
FROM q8_5;

create or replace view Q8(staff_id, sum_roles, hdn_rate) AS
--... SQL statements, possibly using other views/functions defined by you ...
SELECT q8_6.staff_id, q8_2.sum_roles,q8_6.hdn_rate
FROM q8_6
INNER JOIN q8_2 ON q8_6.staff_id = q8_2.staff_id
WHERE q8_6.rank_hdn <= 20
ORDER BY hdn_rate DESC
;


-- Q9

create or replace function 
	Q9(unswid integer)  returns setof text
as $$
--... SQL statements, possibly using other views/functions defined by you ...
DECLARE 
	result TEXT;
	row_result RECORD;
BEGIN 	
	FOR row_result IN
		with A as (
		SELECT subjects.code AS subject_code, 
        	course_enrolments.course AS course,
        	subjects._prereq,
        	CASE WHEN subjects._prereq LIKE CONCAT('%',LEFT(subjects.code,4),'%') THEN 1 ELSE 0 END AS consider
		FROM people
		INNER JOIN course_enrolments ON course_enrolments.student = people.id
		INNER JOIN courses ON course_enrolments.course = courses.id
		INNER JOIN subjects ON courses.subject = subjects.id
		WHERE people.unswid = Q9.unswid)
		,
		B as (SELECT people.unswid AS people_id, subjects.code AS subject_code, RANK() OVER (PARTITION BY course_enrolments.course ORDER BY course_enrolments.mark DESC) AS subject_rank
		FROM course_enrolments
		INNER JOIN courses ON course_enrolments.course = courses.id
		INNER JOIN subjects ON courses.subject = subjects.id
		INNER JOIN people ON people.id = course_enrolments.student
		WHERE course_enrolments.mark IS NOT NULL)
		SELECT concat(B.subject_code,' ',B.subject_rank) AS result
		FROM B
		WHERE B.subject_code in (SELECT A.subject_code FROM A WHERE consider = 1)
		AND B.people_id = Q9.unswid
	LOOP
		result := row_result.result;
        	RETURN NEXT result;
	END LOOP;
	IF result is NULL THEN 
		result := 'WARNING: Invalid Student Input [' || unswid || ']';
            	RETURN NEXT result;
	END IF;
	RETURN;

END;
$$ language plpgsql;


-- Q10
create or replace function 
	Q10(unswid integer) returns setof text
as $$
--... SQL statements, possibly using other views/functions defined by you ...
DECLARE
	result TEXT;
	row_result RECORD;
BEGIN	
	FOR row_result IN 
		with A as(
		SELECT people.unswid AS people_unswid, programs.name AS program_name, program_enrolments.semester AS program_semester
		FROM people
		INNER JOIN program_enrolments ON people.id = program_enrolments.student
		INNER JOIN programs ON program_enrolments.program = programs.id 
		WHERE people.unswid = Q10.unswid)
		,
		B as(
		SELECT people.unswid AS people_unswid, course_enrolments.course, subjects.uoc AS subject_uoc, course_enrolments.mark AS course_mark, courses.semester AS course_semester
		FROM people
		INNER JOIN course_enrolments ON course_enrolments.student = people.id
		INNER JOIN courses ON courses.id = course_enrolments.course
		INNER JOIN subjects ON courses.subject = subjects.id
		WHERE people.unswid = Q10.unswid
		--WHERE people.grade in ('SY','PT','PC','PS','CR','DN,'HD,'A','B','C','XE','T','PE','RC','RS')
		AND course_enrolments.mark IS NOT NULL)
		SELECT concat(A.people_unswid,' ',A.program_name,' ', ROUND(CAST(CAST(sum(B.subject_uoc * B.course_mark) AS NUMERIC)/CAST(sum(B.subject_uoc)AS NUMERIC) AS NUMERIC),2)) AS result
		FROM A
		INNER JOIN B ON A.program_semester = B.course_semester
		GROUP BY A.people_unswid, A.program_name
	LOOP 
		result := row_result.result;
		RETURN NEXT result;
	END LOOP;
	IF result is NULL THEN
		result := 'WARNING: Invalid Student Input [' || unswid || ']';
		RETURN NEXT result;
	END IF;
END;
$$ language plpgsql;

