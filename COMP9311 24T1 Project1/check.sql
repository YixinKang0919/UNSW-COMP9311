----------------------------------------------------------
--		COMP9311 24T1 
-- 		Project AutoTest File
-- 		MyMyUNSW Check
----------------------------------------------------------

SET client_min_messages TO WARNING;

create or replace function
	proj1_table_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='r';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_view_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='v';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_function_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_proc
	where proname=tname;
	return (_check > 0);
end;
$$ language plpgsql;

--------------------------------------------------------------
-- proj1_check_result:
-- determines appropriate message, based on count of
-- excess and missing tuples in user output vs expected output
--------------------------------------------------------------

create or replace function
	proj1_check_result(_res text,nexcess integer, nmissing integer) returns text
as $$
begin
	if (nexcess = 0 and nmissing = 0) then
		return _res || ' correct';
	elsif (nexcess > 0 and nmissing = 0) then
		return _res || ' too many result tuples';
	elsif (nexcess = 0 and nmissing > 0) then
		return _res || ' missing result tuples';
	elsif (nexcess > 0 and nmissing > 0) then
		return _res || ' incorrect result tuples';
	end if;
end;
$$ language plpgsql;

--------------------------------------------------------------
-- proj1_check:
-- * compares output of user view/function against expected output
-- * returns string (text message) containing analysis of results
--------------------------------------------------------------

create or replace function
	proj1_check(_type text, _name text, _res text, _query text) returns text
as $$
declare
	nexcess integer;
	nmissing integer;
	excessQ text;
	missingQ text;
begin
	if (_type = 'view' and not proj1_view_exists(_name)) then
		return 'No '||_name||' view; did it load correctly?';
	elsif (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (not proj1_table_exists(_res)) then
		return _res||': No expected results!';
	else
		excessQ := 'select count(*) '||
				 'from (('||_query||') except '||
				 '(select * from '||_res||')) as X';
		-- raise notice 'Q: %',excessQ;
		execute excessQ into nexcess;
		missingQ := 'select count(*) '||
					'from ((select * from '||_res||') '||
					'except ('||_query||')) as X';
		-- raise notice 'Q: %',missingQ;
		execute missingQ into nmissing;
		return proj1_check_result(_res,nexcess,nmissing);
	end if;
	return '???';
end;
$$ language plpgsql;

--------------------------------------------------------------
-- proj1_rescheck:
-- * compares output of user function against expected result
-- * returns string (text message) containing analysis of results
--------------------------------------------------------------

create or replace function
	proj1_rescheck(_type text, _name text, _res text, _query text) returns text
as $$
declare
	_sql text;
	_chk boolean;
begin
	if (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (_res is null) then
		_sql := 'select ('||_query||') is null';
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	else
		_sql := 'select ('||_query||') = '||quote_literal(_res);
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	end if;
	if (_chk) then
		return 'correct';
	else
		return 'incorrect result';
	end if;
end;
$$ language plpgsql;

--------------------------------------------------------------
-- check_all:
-- * run all of the checks and return a table of results
--------------------------------------------------------------

drop type if exists TestingResult cascade;
create type TestingResult as (test text, result text);

create or replace function
	check_all() returns setof TestingResult
as $$
declare
	i int;
	testQ text;
	result text;
	out TestingResult;
	tests text[] := array['q1', 'q2', 'q3', 'q4', 'q5','q6','q7','q8',
	'q9a','q9b','q9c','q9d','q9e','q9f',
	'q10a','q10b','q10c','q10d','q10e','q10f'];
begin
	for i in array_lower(tests,1) .. array_upper(tests,1)
	loop
		testQ := 'select check_'||tests[i]||'()';
		execute testQ into result;
		out := (tests[i],result);
		return next out;
	end loop;
	return;
end;
$$ language plpgsql;


--------------------------------------------------------------
-- Check functions for specific test-cases in Project 1
--------------------------------------------------------------
create or replace function check_q1() returns text
as $chk$
select proj1_check('view','q1','q1_expected',
									 $$select * from q1$$)
$chk$ language sql;

create or replace function check_q2() returns text
as $chk$
select proj1_check('view','q2','q2_expected',
									 $$select * from q2$$)
$chk$ language sql;

create or replace function check_q3() returns text
as $chk$
select proj1_check('view','q3','q3_expected',
									 $$select * from q3$$)
$chk$ language sql;

create or replace function check_q4() returns text
as $chk$
select proj1_check('view','q4','q4_expected',
									 $$select * from q4$$)
$chk$ language sql;

create or replace function check_q5() returns text
as $chk$
select proj1_check('view','q5','q5_expected',
									 $$select * from q5$$)
$chk$ language sql;

create or replace function check_q6() returns text
as $chk$
select proj1_check('view','q6','q6_expected',
									 $$select * from q6$$)
$chk$ language sql;

create or replace function check_q7() returns text
as $chk$
select proj1_check('view','q7','q7_expected',
									 $$select * from q7$$)
$chk$ language sql;

create or replace function check_q8() returns text
as $chk$
select proj1_check('view','q8','q8_expected',
									 $$select * from q8$$)
$chk$ language sql;

----------------------------------------------------------
--
--  postgresql function
--
----------------------------------------------------------

-- Q9
create or replace function check_q9a() returns text
as $chk$
select proj1_check('function','q9','q9a_expected',
									 $$select q9(2245998)$$)
$chk$ language sql;

create or replace function check_q9b() returns text
as $chk$
select proj1_check('function','q9','q9b_expected',
									 $$select q9(3022731)$$)
$chk$ language sql;

create or replace function check_q9c() returns text
as $chk$
select proj1_check('function','q9','q9c_expected',
									 $$select q9(3273164)$$)
$chk$ language sql;

create or replace function check_q9d() returns text
as $chk$
select proj1_check('function','q9','q9d_expected',
									 $$select q9(3077250)$$)
$chk$ language sql;
create or replace function check_q9e() returns text
as $chk$
select proj1_check('function','q9','q9e_expected',
									 $$select q9(2250217)$$)
$chk$ language sql;
create or replace function check_q9f() returns text
as $chk$
select proj1_check('function','q9','q9f_expected',
									 $$select q9(2223134)$$)
$chk$ language sql;

-- Q10
create or replace function check_q10a() returns text
as $chk$
select proj1_check('function','q10','q10a_expected',
									 $$select q10(2245998)$$)
$chk$ language sql;

create or replace function check_q10b() returns text
as $chk$
select proj1_check('function','q10','q10b_expected',
									 $$select q10(3022731)$$)
$chk$ language sql;

create or replace function check_q10c() returns text
as $chk$
select proj1_check('function','q10','q10c_expected',
									 $$select q10(3273164)$$)
$chk$ language sql;

create or replace function check_q10d() returns text
as $chk$
select proj1_check('function','q10','q10d_expected',
									 $$select q10(2250217)$$)
$chk$ language sql;

create or replace function check_q10e() returns text
as $chk$
select proj1_check('function','q10','q10e_expected',
									 $$select q10(2246925)$$)
$chk$ language sql;

create or replace function check_q10f() returns text
as $chk$
select proj1_check('function','q10','q10f_expected',
									 $$select q10(2246995)$$)
$chk$ language sql;

----------------------------------------------------------
-- Tables of expected results for test cases
----------------------------------------------------------

drop table if exists q1_expected;
create table q1_expected (
	subject_code character(8)
);

drop table if exists q2_expected;
create table q2_expected (
	course_id integer
);

drop table if exists q3_expected;
create table q3_expected (
	unsw_id integer
);

drop table if exists q4_expected;
create table q4_expected (
	course_id integer, avg_mark numeric
);

drop table if exists q5_expected;
create table q5_expected (
	course_id integer, staff_name longname
);

drop table if exists q6_expected;
create table q6_expected (
	room_id integer, subject_code character(8)
);

drop table if exists q7_expected;
create table q7_expected (
	student_id integer, program_id integer
);

drop table if exists q8_expected;
create table q8_expected (
	staff_id integer, sum_roles integer, hdn_rate numeric
);


drop table if exists q9a_expected;
create table q9a_expected (
	q9 text
);

drop table if exists q9b_expected;
create table q9b_expected (
	q9 text
);

drop table if exists q9c_expected;
create table q9c_expected (
	q9 text
);

drop table if exists q9d_expected;
create table q9d_expected (
	q9 text
);

drop table if exists q9e_expected;
create table q9e_expected (
	q9 text
);

drop table if exists q9f_expected;
create table q9f_expected (
	q9 text
);
drop table if exists q10a_expected;
create table q10a_expected (
	q10 text
);

drop table if exists q10b_expected;
create table q10b_expected (
	q10 text
);

drop table if exists q10c_expected;
create table q10c_expected (
	q10 text
);

drop table if exists q10d_expected;
create table q10d_expected (
	q10 text
);
drop table if exists q10e_expected;
create table q10e_expected (
	q10 text
);

drop table if exists q10f_expected;
create table q10f_expected (
	q10 text
);


-- ( )+\|+( )+

COPY q1_expected (subject_code) FROM stdin;
ZEIT7105
ZEIT7101
ZEIT7103
ZEIT7106
ZEIT7401
GMAT7052
GMAT7512
GMAT7612
GMAT7722
GMAT7711
GMAT7001
INFS7988
GMAT7811
GMAT7532
\.

COPY q2_expected (course_id) FROM stdin;
37025
16522
36992
14377
29865
71899
44022
37002
40672
29884
40727
54815
26686
54808
43969
71882
22831
1567
19289
64984
37032
43983
51080
33608
61743
14379
12178
22849
61749
10034
51032
22816
12158
3507
16503
33556
36979
68708
19274
51041
51030
47786
58039
26711
40719
71861
37035
37024
14328
10001
16500
51056
54779
65005
33561
54814
19218
44018
22773
29888
68672
44020
40688
19241
36998
26702
16542
19282
71883
61747
71901
29863
16531
58048
54807
16511
47784
40720
64969
16492
54798
51028
33604
19243
14374
64975
51031
10035
54810
54788
58036
51076
61746
68717
40724
26705
26708
43986
29843
33578
14350
19263
47768
19269
19273
51023
44016
68683
71858
26703
19290
26688
71881
26698
33592
22818
16537
61693
64999
58024
71860
47756
33582
51058
26704
58042
14385
22788
22839
22836
29851
51068
26706
19225
26671
19235
58026
26663
29824
14384
40667
14348
14362
58003
14344
29830
58034
37028
10004
10029
65012
33610
58005
22784
47757
44002
37030
58041
47781
14339
40678
16480
40691
9987
22813
61699
58011
10030
57987
26707
71897
14361
12159
68702
71896
51033
43975
37013
29841
54813
26684
12176
1535
14380
64963
40713
14370
65010
65015
33611
37029
12142
68709
26645
68661
44011
64973
57993
19279
36996
47785
61753
51073
12171
40718
19281
36997
9999
40716
14373
54761
33612
51040
33567
5720
47787
7880
12145
58012
71849
29845
68703
33617
36994
61708
61730
22826
12149
71869
68663
58004
29844
71862
29886
14341
61740
40722
40702
54820
54812
44013
36985
40692
12128
51078
16512
33594
16496
5688
40660
7914
61718
37011
58040
51075
71895
37023
12184
10019
47793
33549
68658
10036
51017
65014
51070
47736
43981
33609
10027
65011
58001
10018
68711
43984
12174
71868
58044
19260
51074
44017
64976
29882
29860
26657
22843
54777
43999
64977
26652
10032
68692
57999
61710
43985
22766
13903
26701
47745
47778
33613
19230
40721
64997
61719
\.

COPY q3_expected (unsw_id) FROM stdin;
3202109
3202500
3202725
3203444
3203632
3205065
3205424
3209720
3209958
\.

COPY q4_expected (course_id, avg_mark) FROM stdin;
60658	82.35
62346	86.25
66202	94.67
67534	77.00
60991	94.50
63602	100.00
66946	90.50
60675	81.75
61436	84.75
67235	89.00
61631	90.50
64899	94.00
62020	83.85
65282	80.94
60838	96.00
62657	95.00
65957	98.00
60913	84.00
62935	82.17
66258	84.88
62194	82.85
66383	85.00
\.

COPY q5_expected (course_id, staff_name) FROM stdin;
59046	Anthony Haynes; Vaithilingam
66061	Bruce Ian; Vaithilingam
56311	John William Vanstan; Joseph Albert
49475	Peter Frank; Richard Allan
\.

COPY q6_expected (room_id, subject_code) FROM stdin;
404	PHYS1121
404	PHYS1131
\.

COPY q7_expected (student_id, program_id) FROM stdin;
3172691	564
3172691	678
3124095	506
3124095	953
3203587	531
3203587	867
\.

COPY q8_expected (staff_id, sum_roles, hdn_rate) FROM stdin;
9419569	10	0.77
9615246	3	0.69
8531071	7	0.60
9667880	8	0.56
3316176	5	0.55
2190365	3	0.53
8725627	4	0.50
7840922	9	0.48
9170148	10	0.43
8697508	9	0.40
2204559	3	0.40
3133620	4	0.38
9870542	4	0.37
2295779	3	0.37
3273227	3	0.37
9334555	17	0.35
7648766	3	0.35
3129296	10	0.33
3009190	6	0.33
2168267	3	0.33
3272574	3	0.33
\.

COPY q9a_expected (q9) FROM stdin;
SART2320 57
SAED2402 26
\.

COPY q9b_expected (q9) FROM stdin;
ACCT1511 71
INFS2609 6
MATH2801 5
INFS2603 2
INFS2607 6
INFS3603 1
INFS3605 5
JAPN2700 1
INFS3608 4
INFS5885 2
INFS5984 2
INFS5848 2
\.


COPY q9c_expected (q9) FROM stdin;
ACCT1511 202
ECON1102 131
MATH1251 33
ACTL2001 19
ACTL2002 19
FINS2624 31
ACTL2003 17
FINS3616 10
FINS3635 3
ACTL3001 3
ACTL3002 15
FINS3625 1
ACTL3003 18
ACTL3004 15
FINS3630 5
FINS3641 7
FINS5523 7
FINS5536 2
FINS5542 1
\.


COPY q9d_expected (q9) FROM stdin;
ARCH1301 1
ARCH1321 1
ARCH1371 1
ARCH1302 1
ARCH1371 5
ARCH1401 3
ARCH1402 1
ARCH1470 1
ARCH1501 5
ARCH1582 3
ARCH1502 2
\.

COPY q9e_expected (q9) FROM stdin;
WARNING: Invalid Student Input [2250217]
\.

COPY q9f_expected (q9) FROM stdin;
WARNING: Invalid Student Input [2223134]
\.

COPY q10a_expected (q10) FROM stdin;
2245998 Art Education 69.95
\.

COPY q10b_expected (q10) FROM stdin;
3022731 Technology & Innovation Mgmt 71.63
3022731 Information Systems 62.60
\.


COPY q10c_expected (q10) FROM stdin;
3273164 Commerce 74.92
3273164 Finance 82.00
\.

COPY q10d_expected (q10) FROM stdin;
2250217 Commerce 67.78
\.

COPY q10e_expected (q10) FROM stdin;
WARNING: Invalid Student Input [2246925]
\.

COPY q10f_expected (q10) FROM stdin;
2246995 Science 72.13
2246995 Petroleum Engineering No WAM Available
2246995 Science 72.50
\.

