create table acad_object_groups
(
    id         integer                not null,
    name       longname,
    gtype      acadobjectgrouptype    not null,
    glogic     acadobjectgrouplogictype,
    gdefby     acadobjectgroupdeftype not null,
    negated    boolean default false,
    parent     integer,
    definition textstring
);

alter table acad_object_groups
    add primary key (id);

alter table acad_object_groups
    add foreign key (parent) references acad_object_groups;

create table academic_standing
(
    id       integer   not null,
    standing shortname not null,
    notes    textstring
);

alter table academic_standing
    add primary key (id);

create table affiliations
(
    staff     integer not null,
    orgunit   integer not null,
    role      integer not null,
    isprimary boolean,
    starting  date    not null,
    ending    date
);

alter table affiliations
    add primary key (staff, orgunit, role, starting);

create table buildings
(
    id      integer     not null,
    unswid  shortstring not null,
    name    longname    not null,
    campus  campustype,
    gridref char(4)
);

alter table buildings
    add primary key (id);

alter table buildings
    add unique (unswid);

create table class_types
(
    id          integer     not null,
    unswid      shortstring not null,
    name        mediumname  not null,
    description mediumstring
);

alter table class_types
    add primary key (id);

alter table class_types
    add unique (unswid);

create table classes
(
    id        integer not null,
    course    integer not null,
    room      integer not null,
    ctype     integer not null,
    dayofwk   integer not null,
    starttime integer not null,
    endtime   integer not null,
    startdate date    not null,
    enddate   date    not null,
    repeats   integer
);

alter table classes
    add primary key (id);

alter table classes
    add foreign key (ctype) references class_types;

alter table classes
    add constraint classes_dayofwk_check
        check ((dayofwk >= 0) AND (dayofwk <= 6));

alter table classes
    add constraint classes_endtime_check
        check ((endtime >= 9) AND (endtime <= 23));

alter table classes
    add constraint classes_starttime_check
        check ((starttime >= 8) AND (starttime <= 22));

create table countries
(
    id   integer  not null,
    code char(3)  not null,
    name longname not null
);

alter table countries
    add primary key (id);

alter table countries
    add unique (code);

create table course_enrolments
(
    student integer not null,
    course  integer not null,
    mark    integer,
    grade   gradetype,
    stueval integer
);

alter table course_enrolments
    add primary key (student, course);

alter table course_enrolments
    add constraint course_enrolments_mark_check
        check ((mark >= 0) AND (mark <= 100));

alter table course_enrolments
    add constraint course_enrolments_stueval_check
        check ((stueval >= 1) AND (stueval <= 6));

create table course_staff
(
    course integer not null,
    staff  integer not null,
    role   integer not null
);

alter table course_staff
    add primary key (course, staff, role);

create table courses
(
    id       integer not null,
    subject  integer not null,
    semester integer not null,
    homepage urlstring
);

alter table courses
    add primary key (id);

alter table classes
    add foreign key (course) references courses;

alter table course_enrolments
    add foreign key (course) references courses;

alter table course_staff
    add foreign key (course) references courses;

create table degree_types
(
    id        integer      not null,
    unswid    shortname    not null,
    name      mediumstring not null,
    prefix    mediumstring,
    career    careertype,
    aqf_level integer
);

alter table degree_types
    add primary key (id);

alter table degree_types
    add unique (unswid);

alter table degree_types
    add constraint degree_types_aqf_level_check
        check (aqf_level > 0);

create table facilities
(
    id          integer      not null,
    description mediumstring not null
);

alter table facilities
    add primary key (id);

create table orgunit_groups
(
    owner  integer not null,
    member integer not null
);

alter table orgunit_groups
    add primary key (owner, member);

create table orgunit_types
(
    id   integer   not null,
    name shortname not null
);

alter table orgunit_types
    add primary key (id);

create table orgunits
(
    id       integer      not null,
    utype    integer      not null,
    name     mediumstring not null,
    longname longstring,
    unswid   shortstring,
    phone    phonenumber,
    email    emailstring,
    website  urlstring,
    starting date,
    ending   date
);

alter table orgunits
    add primary key (id);

alter table affiliations
    add foreign key (orgunit) references orgunits;

alter table orgunit_groups
    add foreign key (member) references orgunits;

alter table orgunit_groups
    add foreign key (owner) references orgunits;

alter table orgunits
    add foreign key (utype) references orgunit_types;

create table people
(
    id        integer     not null,
    unswid    integer,
    password  shortstring not null,
    family    longname,
    given     longname    not null,
    title     shortname,
    sortname  longname    not null,
    name      longname    not null,
    street    longstring,
    city      mediumstring,
    state     mediumstring,
    postcode  shortstring,
    country   integer,
    homephone phonenumber,
    mobphone  phonenumber,
    email     emailstring not null,
    homepage  urlstring,
    gender    char,
    birthday  date,
    origin    integer
);

alter table people
    add primary key (id);

alter table people
    add unique (unswid);

alter table people
    add foreign key (country) references countries;

alter table people
    add foreign key (origin) references countries;

alter table people
    add constraint people_gender_check
        check (gender = ANY (ARRAY ['m'::bpchar, 'f'::bpchar]));

create table program_degrees
(
    id      integer    not null,
    program integer,
    dtype   integer,
    name    longstring not null,
    abbrev  mediumstring
);

alter table program_degrees
    add primary key (id);

alter table program_degrees
    add foreign key (dtype) references degree_types;

create table program_enrolments
(
    id       integer not null,
    student  integer not null,
    semester integer not null,
    program  integer not null,
    wam      real,
    standing integer,
    advisor  integer,
    notes    textstring
);

alter table program_enrolments
    add primary key (id);

alter table program_enrolments
    add foreign key (standing) references academic_standing;

create table program_group_members
(
    program  integer not null,
    ao_group integer not null
);

alter table program_group_members
    add primary key (program, ao_group);

alter table program_group_members
    add foreign key (ao_group) references acad_object_groups;

create table programs
(
    id          integer  not null,
    code        char(4)  not null,
    name        longname not null,
    uoc         integer,
    offeredby   integer,
    career      careertype,
    duration    integer,
    description textstring,
    firstoffer  integer,
    lastoffer   integer
);

alter table programs
    add primary key (id);

alter table program_degrees
    add foreign key (program) references programs;

alter table program_enrolments
    add foreign key (program) references programs;

alter table program_group_members
    add foreign key (program) references programs;

alter table programs
    add foreign key (offeredby) references orgunits;

alter table programs
    add constraint programs_uoc_check
        check (uoc >= 0);

create table room_facilities
(
    room     integer not null,
    facility integer not null
);

alter table room_facilities
    add primary key (room, facility);

alter table room_facilities
    add foreign key (facility) references facilities;

create table room_types
(
    id          integer      not null,
    description mediumstring not null
);

alter table room_types
    add primary key (id);

create table rooms
(
    id       integer     not null,
    unswid   shortstring not null,
    rtype    integer,
    name     shortname   not null,
    longname longname,
    building integer,
    capacity integer
);

alter table rooms
    add primary key (id);

alter table classes
    add foreign key (room) references rooms;

alter table room_facilities
    add foreign key (room) references rooms;

alter table rooms
    add unique (unswid);

alter table rooms
    add foreign key (building) references buildings;

alter table rooms
    add foreign key (rtype) references room_types;

alter table rooms
    add constraint rooms_capacity_check
        check (capacity >= 0);

create table semesters
(
    id       integer   not null,
    unswid   integer   not null,
    year     courseyeartype,
    term     char(2)   not null,
    name     shortname not null,
    longname longname  not null,
    starting date      not null,
    ending   date      not null,
    startbrk date,
    endbrk   date,
    endwd    date,
    endenrol date,
    census   date
);

alter table semesters
    add primary key (id);

alter table courses
    add foreign key (semester) references semesters;

alter table program_enrolments
    add foreign key (semester) references semesters;

alter table programs
    add foreign key (firstoffer) references semesters;

alter table programs
    add foreign key (lastoffer) references semesters;

alter table semesters
    add unique (unswid);

alter table semesters
    add constraint semesters_term_check
        check (term = ANY (ARRAY ['S1'::bpchar, 'S2'::bpchar, 'X1'::bpchar, 'X2'::bpchar]));

create table staff
(
    id         integer not null,
    office     integer,
    phone      phonenumber,
    employed   date    not null,
    supervisor integer
);

alter table staff
    add primary key (id);

alter table affiliations
    add foreign key (staff) references staff;

alter table course_staff
    add foreign key (staff) references staff;

alter table program_enrolments
    add foreign key (advisor) references staff;

alter table staff
    add foreign key (id) references people;

alter table staff
    add foreign key (office) references rooms;

alter table staff
    add foreign key (supervisor) references staff;

create table staff_role_classes
(
    id          char not null,
    description shortstring
);

alter table staff_role_classes
    add primary key (id);

create table staff_role_types
(
    id          char not null,
    description shortstring
);

alter table staff_role_types
    add primary key (id);

create table staff_roles
(
    id          integer    not null,
    rtype       char,
    rclass      char,
    name        longstring not null,
    description longstring
);

alter table staff_roles
    add primary key (id);

alter table affiliations
    add foreign key (role) references staff_roles;

alter table course_staff
    add foreign key (role) references staff_roles;

alter table staff_roles
    add foreign key (rclass) references staff_role_classes;

alter table staff_roles
    add foreign key (rtype) references staff_role_types;

create table stream_enrolments
(
    partof integer not null,
    stream integer not null
);

alter table stream_enrolments
    add primary key (partof, stream);

alter table stream_enrolments
    add foreign key (partof) references program_enrolments;

create table stream_group_members
(
    stream   integer not null,
    ao_group integer not null
);

alter table stream_group_members
    add primary key (stream, ao_group);

alter table stream_group_members
    add foreign key (ao_group) references acad_object_groups;

create table stream_types
(
    id          integer     not null,
    career      careertype  not null,
    code        char        not null,
    description shortstring not null
);

alter table stream_types
    add primary key (id);

create table streams
(
    id          integer  not null,
    code        char(6)  not null,
    name        longname not null,
    offeredby   integer,
    stype       integer,
    description textstring,
    firstoffer  integer,
    lastoffer   integer
);

alter table streams
    add primary key (id);

alter table stream_enrolments
    add foreign key (stream) references streams;

alter table stream_group_members
    add foreign key (stream) references streams;

alter table streams
    add foreign key (firstoffer) references semesters;

alter table streams
    add foreign key (lastoffer) references semesters;

alter table streams
    add foreign key (offeredby) references orgunits;

alter table streams
    add foreign key (stype) references stream_types;

create table students
(
    id    integer not null,
    stype varchar(5)
);

alter table students
    add primary key (id);

alter table course_enrolments
    add foreign key (student) references students;

alter table program_enrolments
    add foreign key (student) references students;

alter table students
    add foreign key (id) references people;

alter table students
    add constraint students_stype_check
        check ((stype)::text = ANY (ARRAY [('local'::character varying)::text, ('intl'::character varying)::text]));

create table subject_group_members
(
    subject  integer not null,
    ao_group integer not null
);

alter table subject_group_members
    add primary key (subject, ao_group);

alter table subject_group_members
    add foreign key (ao_group) references acad_object_groups;

create table subjects
(
    id          integer    not null,
    code        char(8)    not null,
    name        mediumname not null,
    longname    longname,
    uoc         integer,
    offeredby   integer,
    eftsload    double precision,
    career      careertype,
    syllabus    textstring,
    contacthpw  double precision,
    _excluded   text,
    excluded    integer,
    _equivalent text,
    equivalent  integer,
    _prereq     text,
    prereq      integer,
    replaces    integer,
    firstoffer  integer,
    lastoffer   integer
);

alter table subjects
    add primary key (id);

alter table courses
    add foreign key (subject) references subjects;

alter table subject_group_members
    add foreign key (subject) references subjects;

alter table subjects
    add foreign key (equivalent) references acad_object_groups;

alter table subjects
    add foreign key (excluded) references acad_object_groups;

alter table subjects
    add foreign key (firstoffer) references semesters;

alter table subjects
    add foreign key (lastoffer) references semesters;

alter table subjects
    add foreign key (offeredby) references orgunits;

alter table subjects
    add foreign key (replaces) references subjects;

alter table subjects
    add constraint subjects_uoc_check
        check (uoc >= 0);

