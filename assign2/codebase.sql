-- Group3

CREATE TABLE public.cast_and_crew
(
    castid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    birthyear smallint,
    deathyear smallint,
    usual_role1 text,
    usual_role2 text,
    usual_role3 text,
    known_for1 text,
    known_for2 text,
    known_for3 text,
    known_for4 text,
    PRIMARY KEY (castid)
);

CREATE TABLE public.characters
(
    id character varying(255) NOT NULL,
    castid character varying(255) NOT NULL,
    character_name text NOT NULL
);

CREATE TABLE public.entity_awards
(
    eventid character varying(255),
    eventname text,
    awardname text,
    year smallint,
    categoryname text,
    name text,
    originalname text,
    songname text,
    episodename text,
    iswinner boolean,
    const character varying(255)
);

CREATE TABLE public.episodes
(
    episode_title_id character varying(255) NOT NULL,
    parent_tv_show_title_id character varying(255) NOT NULL,
    season_number integer,
    episode_number integer,
    PRIMARY KEY (episode_title_id)
);

CREATE TABLE public.events
(
    eventid character varying(255) NOT NULL,
    eventname text,
    PRIMARY KEY (eventid)
);


-- public.extra is a table corresponding to some newly scraped data.  This was deleted later once we extracted the required columns into the already existing tables.
CREATE TABLE public.extra
(
    imdb_id character varying(255) NOT NULL,
    budget bigint,
    revenue bigint,
    website text,
    keywords text,
    plot_outline text,
    production_company text,
    release_date text,
    release_year smallint
);

CREATE TABLE public.imdb_entities
(
    id character varying(255) NOT NULL,
    title_type character varying(50),
    primary_title text,
    original_title text,
    pg_rating boolean,
    startyear integer,
    endyear integer,
    runtime integer,
    genre1 character varying(255),
    genre2 character varying(255),
    genre3 character varying(255)
);

CREATE TABLE public.individual_awards
(
    eventid character varying(255),
    eventname text,
    awardname text,
    year smallint,
    categoryname text,
    name text,
    originalname text,
    songname text,
    episodename text,
    charactername text,
    iswinner boolean,
    const character varying(255)
);

CREATE TABLE public.other_titles
(
    id character varying(255) NOT NULL,
    title text,
    region character(4),
    language character(4),
    is_original_title boolean
);

CREATE TABLE public.awards
(
    eventid character varying(255) NOT NULL,
    eventName text,
    awardName text,
    year smallint,
    categoryName text,
    name text,
    originalName text,
    songName text,
    episodeName text,
    characterName text,
    isWinner boolean,
    isPerson boolean,
    isTitle boolean,
    const character varying(255)
);

CREATE TABLE public.production_company
(
    id character varying(255) NOT NULL,
    company_name character varying(255)
);

CREATE TABLE public.worked_in
(
    id character varying(255),
    castid character varying(255) NOT NULL,
    role character varying(255)
);
CREATE TABLE public.ratings
(
   id character varying(255),
   average_rating double precision,
   num_votes integer;
);
--Copying Data into files
COPY public.cast_and_crew (CastID, name, birthyear, deathyear, usual_role1, usual_role2, usual_role3, known_for1, known_for2, known_for3, known_for4) FROM 'Cast_and_Crew.tsv' NULL AS '\N' DELIMITER E'\t' CSV HEADER QUOTE E'"' ESCAPE E'"';
COPY public.Imdb_entities (ID, title_type, primary_title, original_title, pg_rating, startyear, endyear, runtime, genre1, genre2, genre3) FROM 'Imdb_entities.tsv' NULL AS '\N' DELIMITER E'\t' CSV HEADER QUOTE E'"' ESCAPE E'"';
COPY public.characters(ID, CastID, character_name) FROM 'Characters.tsv' DELIMITER E'\t' CSV HEADER QUOTE E'"' ESCAPE E'"';
COPY public.other_titles (ID, title, region, language, is_original_title) FROM 'Other_titles.tsv' DELIMITER E'\t' NULL AS '\N' CSV HEADER QUOTE E'"' ESCAPE E'"';
COPY public.worked_in (ID, castid, role) FROM 'Worked_in.tsv' DELIMITER E'\t' NULL AS '\N' CSV HEADER QUOTE E'"' ESCAPE E'"';
COPY public.episodes (epiosode_title_id, parent_tv_show_title_id, season_number, episode_number) FROM 'title.episode.csv' DELIMITER E'\t' NULL AS '\N' CSV HEADER QUOTE E'"' ESCAPE E'"';
-- copying/updating extra/crawled data
COPY public.events (eventID, eventname) FROM 'events.tsv' DELIMITER E'\t' NULL AS '\N' CSV HEADER QUOTE E'"' ESCAPE E'"';
COPY public.ratings (id, average_rating, num_votes) FROM 'title.ratings.tsv' DELIMITER E'\t' CSV HEADER QUOTE E'"' NULL '\N' ESCAPE E'"';
COPY public.awards (eventid, eventname, awardname, year, categoryname, individual_name, originalname, songname, episodename, charactername, iswinner, isperson, istitle, const) FROM 'awards.csv' DELIMITER ',' CSV HEADER QUOTE E'"' ESCAPE E'"';
COPY public.production_company (id, company_name) FROM 'Production_companies.tsv' DELIMITER E'\t' NULL AS '\N' CSV HEADER QUOTE E'"' ESCAPE E'"';

-- Deleting entries that don't satisfy foreign key constraints
DELETE FROM public.ratings WHERE NOT EXISTS (
    SELECT * FROM imdb_entities WHERE ratings.id = imdb_entities.id
);
DELETE FROM public.episodes WHERE NOT EXISTS (
    SELECT * FROM imdb_entities WHERE episodes.episode_title_id = imdb_entities.id
) OR NOT EXISTS (
    SELECT * FROM imdb_entities WHERE episodes.parent_tv_show_title_id = imdb_entities.id
);
DELETE FROM public.characters WHERE NOT EXISTS (
    SELECT * FROM imdb_entities WHERE characters.id = imdb_entities.id
) OR NOT EXISTS (
    SELECT * FROM cast_and_crew WHERE characters.castid = cast_and_crew.castid
);
DELETE FROM public.worked_in WHERE NOT EXISTS (
    SELECT * FROM imdb_entities WHERE worked_in.id = imdb_entities.id
) OR NOT EXISTS (
    SELECT * FROM cast_and_crew WHERE worked_in.castid = cast_and_crew.castid
);
DELETE FROM public.other_titles WHERE NOT EXISTS (
    SELECT * FROM imdb_entities WHERE other_titles.id = imdb_entities.id
);
DELETE FROM public.extra WHERE NOT EXISTS (
	SELECT * FROM imdb_entities WHERE extra.imdb_id = imdb_entities.id
);


--Adding Foreign Key Constraints
ALTER TABLE public.cast_and_crew
    ADD FOREIGN KEY (known_for1)
    REFERENCES public.imdb_entities (id);

ALTER TABLE public.cast_and_crew
    ADD FOREIGN KEY (known_for2)
    REFERENCES public.imdb_entities (id);

ALTER TABLE public.cast_and_crew
    ADD FOREIGN KEY (known_for3)
    REFERENCES public.imdb_entities (id);


ALTER TABLE public.cast_and_crew
    ADD FOREIGN KEY (known_for4)
    REFERENCES public.imdb_entities (id);


ALTER TABLE public.characters
    ADD FOREIGN KEY (castid)
    REFERENCES public.cast_and_crew (castid);


ALTER TABLE public.characters
    ADD FOREIGN KEY (id)
    REFERENCES public.imdb_entities (id);


ALTER TABLE public.episodes
    ADD FOREIGN KEY (episode_title_id)
    REFERENCES public.imdb_entities (id);


ALTER TABLE public.episodes
    ADD FOREIGN KEY (parent_tv_show_title_id)
    REFERENCES public.imdb_entities (id);

ALTER TABLE public.extra
    ADD FOREIGN KEY (imdb_id)
    REFERENCES public.imdb_entities (id);


ALTER TABLE public.other_titles
    ADD FOREIGN KEY (id)
    REFERENCES public.imdb_entities (id);

ALTER TABLE public.ratings
    ADD FOREIGN KEY (id)
    REFERENCES public.imdb_entities (id);

ALTER TABLE public.production_company
    ADD FOREIGN KEY (id)
    REFERENCES public.imdb_entities (id);


ALTER TABLE public.worked_in
    ADD FOREIGN KEY (castid)
    REFERENCES public.cast_and_crew (castid);

ALTER TABLE public.worked_in
    ADD FOREIGN KEY (id)
    REFERENCES public.imdb_entities (id);
-- Adding new columns to imdb_entities for copying some of the newly scraped information into it from the temporary tables like extra and ratings

ALTER TABLE public.imdb_entities
(
	add column budget integer,
	add column revenue integer,
	add column website text,
	add column keywords text,
	add column plot_outline text,
	add column release_date text,
	add column release_year smallint
);
ALTER TABLE public.imdb_entities
(
	add column num_votes integer,
add column average_rating double precision
);
ALTER TABLE public.imdb_entities
(
	add column production_company text
);
-- Splitting awards into individual awards and entity awards based on their IDs

SELECT eventid, eventname, awardname, year,
    categoryname, name, originalname, songname,
    episodename, charactername,iswinner, const 
INTO public.individual_awards 
FROM public.awards
WHERE const like 'nm%';

--Renaming some columns
ALTER TABLE public.individual_awards
RENAME COLUMN name TO individual_name;

ALTER TABLE public.individual_awards
RENAME COLUMN const TO cast_id;

SELECT eventid, eventname, awardname, year,
    categoryname, name, originalname, songname,
    episodename, iswinner, const
INTO public.entity_awards 
FROM public.awards
WHERE const like 'tt%' ;

--Renaming some columns
ALTER TABLE public.entity_awards
RENAME COLUMN name TO entity_name;

ALTER TABLE public.entity_awards
RENAME COLUMN const TO imdb_id;

-- Removing records in the two awards tables that don’t satisfy foriegn key constraints and then adding the corresponding constraints

DELETE FROM public.individual_awards WHERE NOT EXISTS (
    SELECT * FROM imdb_entities WHERE individual_awards.imdb_id = imdb_entities.eventid
) OR NOT EXISTS (
    SELECT * FROM events WHERE individual_awards.eventid = events.eventid 
);
DELETE FROM public.entity_awards WHERE NOT EXISTS (
    SELECT * FROM cast_and_crew WHERE entity_awards.id = cast_and_crew.cast_id
) OR NOT EXISTS (
    SELECT * FROM events WHERE entity_awards.eventid = events.eventid 
);
ALTER TABLE public.individual_awards
    ADD FOREIGN KEY (cast_id)
    REFERENCES public.imdb_entities (id);

ALTER TABLE public.individual_awards
    ADD FOREIGN KEY (eventid)
    REFERENCES public.events (eventid);

ALTER TABLE public.entity_awards
    ADD FOREIGN KEY (eventid)
    REFERENCES public.events (eventid);


ALTER TABLE public.entity_awards
    ADD FOREIGN KEY (imdb_id)
    REFERENCES public.imdb_entities (id);

-- We populate the newly added columns of imdb_entities using the UPDATE command by accessing the scraped data which has already been loaded into certain other tables.
UPDATE public.imdb_entities
SET budget = (
SELECT extra.budget
FROM extra
WHERE extra.imdb_id = imdb_entities.id
);
UPDATE public.imdb_entities
SET revenue = (
SELECT extra.revenue
FROM extra
WHERE extra.imdb_id = imdb_entities.id
);
UPDATE public.imdb_entities
SET website = (
SELECT extra.website 
FROM extra
WHERE extra.imdb_id = imdb_entities.id
);
UPDATE public.imdb_entities
SET keywords = (
SELECT extra.keywords 
FROM extra
WHERE extra.imdb_id = imdb_entities.id
);
UPDATE public.imdb_entities
SET plot_outline = (
SELECT extra.plot_outline 
FROM extra
WHERE extra.imdb_id = imdb_entities.id
);
UPDATE public.imdb_entities
SET release_date = (
SELECT extra.release_date   
FROM extra
WHERE extra.imdb_id = imdb_entities.id
);
UPDATE public.imdb_entities
SET release_year = (
SELECT extra.release_year    
FROM extra
WHERE extra.imdb_id = imdb_entities.id
);


UPDATE public.imdb_entities
SET num_votes = (
SELECT ratings.num_votes
FROM ratings
WHERE ratings.id = imdb_entities.id
);
UPDATE public.imdb_entities
SET average_rating = (
SELECT ratings.average_rating
FROM ratings
WHERE ratings.id = imdb_entities.id
);
UPDATE public.imdb_entities
SET production_company = (
SELECT production_company.company_name 
FROM extra
WHERE production_company.id = imdb_entities.id
);

DROP TABLE public.extra;
DROP TABLE public.awards;
DROP TABLE public.ratings;




