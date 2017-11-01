/*
Finn tittel og produksjonsår for filmer laget i Grønland.
*/
SELECT f.title, f.prodyear
FROM film f INNER JOIN filmcountry c ON f.filmid = c.filmid
--WHERE c.country LIKE '%Greenland%';
WHERE c.country = 'Greenland';



/*
Utvid spørringen over med filmer fra Saudi Arabia og Sudan.

('Greenland', 'Saudi Arabia', 'Sudan')
*/
SELECT f.title, f.prodyear, c.country
FROM film f INNER JOIN filmcountry c ON f.filmid = c.filmid
WHERE c.country IN ('Greenland', 'Saudi Arabia', 'Sudan');




/*
Hva er tittelen på de 5 høyest rangerte filmene?
Ta kun med filmer med over 5000 stemmer.
*/
select f.title, r.rank
from film f inner join filmrating r on f.filmid = r.filmid
where r.votes > 5000
order by r.rank desc
limit 5;


/*
Hvilket år ble det produsert flest filmer?
*/
select prodyear
from film
group by prodyear
order by count(*) desc
limit 1;

-- mer komplisert måte å gjøre det på
create view prodaar as select prodyear, count(*) as antallfilmer
from film
group by prodyear;

select prodyear
from prodaar
where antallfilmer = (select max(antallfilmer) from prodaar);

-- med with
with prodaar as (
    select prodyear, count(*) as antallfilmer
    from film
    group by prodyear
)
select prodyear
from prodaar
where antallfilmer = (select max(antallfilmer) from prodaar);

/*
Flere TV-serier har delt førsteplass for høyest rangerte serie.
Hva er navnet på TV-seriene som deler den høyeste rangeringen,
blant serier med over 1000 stemmer?
*/
select s.maintitle, r.rank
from series s inner join filmrating r on s.seriesid = r.filmid
where votes > 1000 and r.rank = (
    select max(r.rank)
    from filmrating r inner join series s on s.seriesid = r.filmid
    where r.votes > 1000
);




/*
Hvor mange land har vært involvert i filmer fra Grønland?
Skriv ut filmid, tittel og antall land.

Hint: Begynn med å skrive ut alle land involvert i filmer fra Grønland.
*/
SELECT f.filmid, f.title, count(*)
FROM film f INNER JOIN filmcountry c ON f.filmid = c.filmid
WHERE f.filmid IN (
    SELECT filmid
    FROM filmcountry
    WHERE country = 'Greenland'
)
GROUP BY f.filmid, f.title;

-- inner join
SELECT f.filmid, f.title, count(*)
FROM film f INNER JOIN filmcountry c ON f.filmid = c.filmid
    INNER JOIN (
        SELECT filmid
        FROM filmcountry
        WHERE country = 'Greenland'
    ) greenlandmovies ON greenlandmovies.filmid = f.filmid
GROUP BY f.filmid, f.title;

-- inner join med with
with greenlandmovies as (
    SELECT filmid
    FROM filmcountry
    WHERE country = 'Greenland'
)
SELECT f.filmid, f.title, count(*)
FROM film f INNER JOIN filmcountry c ON f.filmid = c.filmid
    INNER JOIN greenlandmovies ON greenlandmovies.filmid = f.filmid
GROUP BY f.filmid, f.title;

-- med EXISTS
SELECT f.filmid, f.title, count(*)
FROM film f INNER JOIN filmcountry c ON f.filmid = c.filmid
WHERE EXISTS (
    SELECT 'hei'
    FROM filmcountry fc
    WHERE fc.country = 'Greenland'
        AND fc.filmid = c.filmid
)
GROUP BY f.filmid, f.title;




/*
Hvilke filmer som Quentin Tarantino har regisert har høyere rating enn
Michael Bay's film med høyest rating?
*/
SELECT f.title, r.rank
FROM film f natural join filmparticipation fp
    natural join person p natural join filmrating r
WHERE firstname = 'Quentin' and lastname = 'Tarantino'
    and parttype = 'director' and r.rank > (
        SELECT max(r.rank)
        FROM filmrating r inner join filmparticipation fp on r.filmid = fp.filmid
            INNER JOIN person p on p.personid = fp.personid
        WHERE firstname = 'Michael' and lastname = 'Bay' and parttype = 'director'
);




/*
Navn på regissør og filmtittel for filmer hvor mer enn 200 personer har deltatt.
Ta ikke med filmer som har hatt flere (mer enn én) regissører.
-- (denne rakk vi ikke på plenumstimen)
*/
select p.firstname || ' ' || p.lastname as name, f.title
from film f natural join filmparticipation fp natural join person p
inner join (
    select filmid
    from filmparticipation
    where parttype = 'director'
    and filmid in (
        select filmid
        from filmparticipation fp
        group by filmid
        having count(*) > 200
    )
    group by filmid
    having count(*) = 1
) q on q.filmid = fp.filmid
where parttype = 'director';