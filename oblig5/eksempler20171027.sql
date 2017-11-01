-- Oversikt over norske produksjoner
-- denne blir ikke riktig. Hvorfor?

select I.filmid, I.filmtype, F.title, S.maintitle
from film F
   FULL OUTER join
     filmcountry C
   on F.filmid = C.filmid
   join Filmitem I on C.filmid = I.filmid
   join Series S on S.seriesid = I.filmid
where C.country = 'Norway';












select I.filmid, I.filmtype, F.title, S.maintitle
from film F
   FULL OUTER join
    filmcountry C
    on F.filmid = C.filmid
   INNER join Filmitem I
    on C.filmid=I.filmid
   FULL OUTER join  Series S
    on S.seriesid = I.filmid
where C.country = 'Norway';

-- Noe som hverken er Film eller Serie?

select I.filmid, I.filmtype, F.title, S.maintitle
from film F
   FULL OUTER join
    filmcountry C
    on F.filmid = C.filmid
   join Filmitem I
    on C.filmid = I.filmid
   FULL OUTER join  Series S
    on S.seriesid = I.filmid
where C.country = 'Norway' and
      F.filmid is null and S.seriesid is null;


-- Kan vi finne noen tittel for disse episodene?


select I.filmid, I.filmtype, F.title, S.maintitle, E.subtitle
from film F
   FULL OUTER join
    filmcountry C
    on F.filmid = C.filmid
   join Filmitem I
    on C.filmid = I.filmid
   FULL OUTER join  Series S
    on S.seriesid = I.filmid
   FULL OUTER join Episode E
    on E.episodeid = I.filmid
where C.country = 'Norway' and
      F.filmid is null and S.seriesid is null;


-- Er det noen filmer i Film som ikke har filmtype = 'C' i Filmitem?

select count(F.filmid)
from Film F
     natural join Filmitem I
where I.filmtype <> 'C'; -- Cinema
-- 142579


-- Denne gir mer oversikt:

select I.filmtype, count(F.filmid)
from Film F
     natural join Filmitem I
group by I.filmtype;

/*

 filmtype | count  
----------+--------
 VG       |   6804         Videospill
 TV       |  74725         TV-film
 C        | 549782         Vanlig kinofilm
 V        |  61050         Videofilm
(4 rows)               */


-- eller:

select I.filmtype, count(F.filmid)
from  Film F
     RIGHT OUTER join
      Filmitem I
     on F.filmid=I.filmid
group by I.filmtype;


-- Er det filmer som har filmtype = 'C' i Filmitem som ikke er i Film?

select count(F.filmid)
from Film F
     FULL OUTER join Filmitem I
       on F.filmid = I.filmid
where I.filmtype = 'C'
     and F.filmid is null;


-- filmer produsert i Norge

select count (F.filmid)
from film F
   FULL OUTER join
     filmcountry C
   on F.filmid = C.filmid
where C.country = 'Norway';

-- bare i Norge

select count (F.filmid)
from film F
   FULL OUTER join
     filmcountry C
   on F.filmid = C.filmid
where C.country = 'Norway'
   and not exists ( select * from Filmcountry FC
                    where F.filmid = FC.filmid
                      and FC.country <> 'Norway' );


-- hvilken film også produsert i Norge, har flest forekomster i Filmcountry?
-- hvorfor gir ikke denne rett svar?

select C.filmid, F.title, count(C.country) as ant_land
from film F
   FULL OUTER join
     filmcountry C
   on F.filmid = C.filmid
where C.country = 'Norway'
group by C.filmid, F.title
order by ant_land;





-- Hva med denne?

select C.filmid, F.title, count(C.country) as ant_land
from film F
   FULL OUTER join
     filmcountry C
   on F.filmid = C.filmid
where 'Norway' in (select country from Filmcountry FC where C.filmid=FC.filmid)
group by C.filmid, F.title
having count(C.country) > 4
order by ant_land desc;


-- sammenlign med


select C.filmid, F.title, count(C.country) as ant_land
from film F
   INNER join
     filmcountry C
   on F.filmid = C.filmid
where 'Norway' in (select FC.country from Filmcountry FC where C.filmid=FC.filmid)
group by C.filmid, F.title
having count(C.country) > 4
order by ant_land desc;



-- Gir Series oss tittelen til de 8 som vi mangler?


select C.filmid, S.maintitle, count(C.country) as ant_land
from Series S
   INNER join
     filmcountry C
   on S.seriesid = C.filmid
where 'Norway' in (select FC.country from Filmcountry FC where C.filmid=FC.filmid)
group by C.filmid, S.maintitle
having count(C.country) > 4
order by ant_land desc;


select C.filmid, E.subtitle, count(C.country) as ant_land
from Episode E
   INNER join
     filmcountry C
   on E.episodeid = C.filmid
where 'Norway' in (select FC.country from Filmcountry FC where C.filmid=FC.filmid)
group by C.filmid, E.subtitle
having count(C.country) > 4
order by ant_land desc;


-- Da får vi fullstendig oversikt med

create view NorskeOGInternasjonaleFilmer(filmid, tittel, antProdLand) as
( 1 )
union
( 2 )
union
( 3 )






-- Oppgave: Bruk exists i stedet for in:


where exists
       ( select FC.country
         from Filmcountry FC
         where FC.country = 'Norway'
           and C.filmid=FC.filmid )
              

-- Da setter vi sammen:


select C.filmid, F.title, count(C.country) as ant_land
from film F
   INNER join
     filmcountry C
   on F.filmid = C.filmid
where exists
       ( select FC.country
         from Filmcountry FC
         where FC.country = 'Norway'
           and C.filmid=FC.filmid )
group by C.filmid, F.title
having count(C.country) > 4
order by ant_land desc;



-- Samme spørsmål, men lager egen tabell over filmer produsert i (bl.a.) Norge

-- tabell filmer produsert i (bl.a.) Norge:
select distinct filmid  -- distinct?
from Filmcountry C
where C.country = 'Norway'; -- 2245 filmer


-- Denne brukes som tabell (kalt N) i from-delen:

select C.filmid,
       -- F.title, 
       count(C.country) as ant_land
from filmitem F -- Filmitem har mange fler filmer enn Film
   natural join
     filmcountry C
--   on F.filmid = C.filmid
   join ( select distinct filmid
          from Filmcountry C
          where C.country = 'Norway' ) as N
   on C.filmid=N.filmid
where F.filmtype in ('C', 'V', 'TV', 'VG') -- Dette er filmer som også er i Film
group by C.filmid --, F.title
having count(C.country) > 4;



create view NorskeFilmer as
          select distinct filmid
          from Filmcountry C
          where C.country = 'Norway';


select C.filmid,
       count(C.country) as ant_land
from filmitem F -- Filmitem har mange fler filmer enn Film
   natural join
     filmcountry C
   natural join ( select distinct filmid
                  from Filmcountry C
                  where C.country = 'Norway' ) as N
where F.filmtype in ('C', 'V', 'TV', 'VG') -- Dette er filmer som også er i Film
group by C.filmid
having count(C.country) > 4;

-- kan da forenkles til 

select C.filmid,
       count(C.country) as ant_land
from filmitem F -- Filmitem har mange fler filmer enn Film
   natural join
     filmcountry C
   natural join 
     NorskeFilmer
where F.filmtype in ('C', 'V', 'TV', 'VG') -- Dette er filmer som også er i Film
group by C.filmid
having count(C.country) > 4;

-- Er dette samme tabell?
-- tar differansen:

(
select C.filmid,
       F.title,
       count(C.country) as ant_land
from film F
   INNER join
     filmcountry C
   on F.filmid = C.filmid
where 'Norway' in (select country from Filmcountry FC where C.filmid=FC.filmid)
group by C.filmid, F.title
having count(C.country) > 4
)
except
(
select C.filmid,
       count(C.country) as ant_land
from filmitem F -- Filmitem har mange fler filmer enn Film
   natural join
     filmcountry C
   join ( select distinct filmid
          from Filmcountry C
          where C.country = 'Norway' ) as N
   on C.filmid=N.filmid
where F.filmtype in ('C', 'V', 'TV', 'VG') -- Dette er filmer som også er i Film
group by C.filmid
having count(C.country) > 4
)




-- Hva er det vanligste landet utenom Norge for filmer produsert i Norge
-- og som er produsert i mer enn 4 land?


-- ta vekk attributter vi ikke trenger

select C.filmid,
       F.title,
       count(C.country) as ant_land
from film F
   INNER join
     filmcountry C
   on F.filmid = C.filmid
where exists
       ( select FC.country
         from Filmcountry FC
         where FC.country = 'Norway'
           and C.filmid=FC.filmid )
group by C.filmid, F.title
having count(C.country) > 4
order by ant_land desc;



( select C.filmid
  from film F
   INNER join
     filmcountry C
   on F.filmid = C.filmid
  where exists
       ( select FC.country
         from Filmcountry FC
         where FC.country = 'Norway'
           and C.filmid=FC.filmid )
  group by C.filmid
  having count(C.country) > 4
                                 ) as N5


select C.country,
       count(*)

from Filmcountry C

  natural join

     ( select C.filmid
       from film F
         INNER join
       filmcountry C
         on F.filmid = C.filmid
       where exists
         ( select FC.country
           from Filmcountry FC
           where FC.country = 'Norway'
             and C.filmid=FC.filmid )
       group by C.filmid
       having count(C.country) > 4) as N5

group by C.country
having C.country <> 'Norway';


/* Tabellen over gir alle land.

Hvordan få til dette som svar:

 country | count 
---------+-------
 Sweden  |    22
(1 row)


?       */


select
       count(*) as ant_filmer
from Filmcountry C
  natural join
     ( select C.filmid
       from film F
         INNER join
       filmcountry C
         on F.filmid = C.filmid
       where exists
         ( select FC.country
           from Filmcountry FC
           where FC.country = 'Norway'
             and C.filmid=FC.filmid )
       group by C.filmid
       having count(C.country) > 4) as N5
group by C.country
having C.country <> 'Norway';

select max(Q.ant_filmer)
from ( select
       count(*) as ant_filmer
       from Filmcountry C
       natural join
            ( select C.filmid
              from film F
              INNER join
              filmcountry C
              on F.filmid = C.filmid
              where exists
               ( select FC.country
                 from Filmcountry FC
                 where FC.country = 'Norway'
                 and C.filmid=FC.filmid )
              group by C.filmid
              having count(C.country) > 4) as N5
       group by C.country
       having C.country <> 'Norway' ) as Q
;


select C.country,
       count(*)
from Filmcountry C
  natural join
     ( select C.filmid
       from film F
         INNER join
       filmcountry C
         on F.filmid = C.filmid
       where exists
         ( select FC.country
           from Filmcountry FC
           where FC.country = 'Norway'
             and C.filmid=FC.filmid )
       group by C.filmid
       having count(C.country) > 4) as N5
group by C.country
having count(*)
=
(
select max(Q.ant_filmer)
from ( select
       count(*) as ant_filmer
       from Filmcountry C
       natural join
            ( select C.filmid
              from film F
              INNER join
              filmcountry C
              on F.filmid = C.filmid
              where exists
               ( select FC.country
                 from Filmcountry FC
                 where FC.country = 'Norway'
                 and C.filmid=FC.filmid )
              group by C.filmid
              having count(C.country) > 4) as N5
       group by C.country
       having C.country <> 'Norway' ) as Q
);

-- Hvilke(t) er de sjeldneste?


select C.country,
       count(*)
from Filmcountry C
  natural join
     ( select C.filmid
       from film F
         INNER join
       filmcountry C
         on F.filmid = C.filmid
       where exists
         ( select FC.country
           from Filmcountry FC
           where FC.country = 'Norway'
             and C.filmid=FC.filmid )
       group by C.filmid
       having count(C.country) > 4) as N5
group by C.country
having count(*)
=
(
select MIN(Q.ant_filmer) -- MIN istedet for MAX
from ( select
       count(*) as ant_filmer
       from Filmcountry C
       natural join
            ( select C.filmid
              from film F
              INNER join
              filmcountry C
              on F.filmid = C.filmid
              where exists
               ( select FC.country
                 from Filmcountry FC
                 where FC.country = 'Norway'
                 and C.filmid=FC.filmid )
              group by C.filmid
              having count(C.country) > 4) as N5
       group by C.country
       having C.country <> 'Norway' ) as Q
);


-- Da kan vi lett finne hvilke land som er produksjonsland sammen med Norge også for samtlige filmer produsert i minst ett land utenom Norge.



select C.country,
       count(*)
from Filmcountry C
  natural join
     ( select C.filmid
       from film F
         INNER join
       filmcountry C
         on F.filmid = C.filmid
       where exists
         ( select FC.country
           from Filmcountry FC
           where FC.country = 'Norway'
             and C.filmid=FC.filmid )
       group by C.filmid
       having count(C.country) > 1) as N1  --- 2 eller fler
group by C.country
having count(*)
=
(
select max(Q.ant_filmer)
from ( select
       count(*) as ant_filmer
       from Filmcountry C
       natural join
            ( select C.filmid
              from film F
              INNER join
              filmcountry C
              on F.filmid = C.filmid
              where exists
               ( select FC.country
                 from Filmcountry FC
                 where FC.country = 'Norway'
                 and C.filmid=FC.filmid )
              group by C.filmid
              having count(C.country) > 1) as N1
       group by C.country
       having C.country <> 'Norway' ) as Q
);


-- Og sjeldneste medproduksjonsland er:



select C.country,
       count(*)
from Filmcountry C
  natural join
     ( select C.filmid
       from film F
         INNER join
       filmcountry C
         on F.filmid = C.filmid
       where exists
         ( select FC.country
           from Filmcountry FC
           where FC.country = 'Norway'
             and C.filmid=FC.filmid )
       group by C.filmid
       having count(C.country) > 1) as N1
group by C.country
having count(*)
=
(
select min(Q.ant_filmer)
from ( select
       count(*) as ant_filmer
       from Filmcountry C
       natural join
            ( select C.filmid
              from film F
              INNER join
              filmcountry C
              on F.filmid = C.filmid
              where exists
               ( select FC.country
                 from Filmcountry FC
                 where FC.country = 'Norway'
                 and C.filmid=FC.filmid )
              group by C.filmid
              having count(C.country) > 1) as N1
       group by C.country
       having C.country <> 'Norway' ) as Q
);



-- La oss se hele tabellen:


select C.country,
       count(*) antall_filmer
from Filmcountry C
  natural join
     ( select C.filmid
       from film F
         INNER join
       filmcountry C
         on F.filmid = C.filmid
       where exists
         ( select FC.country
           from Filmcountry FC
           where FC.country = 'Norway'
             and C.filmid=FC.filmid )
       group by C.filmid
       having count(C.country) > 1) as N1
group by C.country
having C.country <> 'Norway'
order by antall_filmer desc;





-- Da skal vi se litt på funksjoner (parttype) i filmdeltakelsestabellen:

select
     FP.parttype as funksjon,
     count(FP.filmid) as antall
from Filmparticipation FP
group by FP.parttype
order by antall desc;

-- Hvor mange filmer er registrert i FP?

select
     count(distinct FP.filmid) as antall
from Filmparticipation FP;


-- Filmer uten regissør (director):

select count(distinct FP.filmid) -- hvorfor distinct?
from Filmparticipation FP
where not exists ( select *
                   from Filmparticipation FPP
                   where FP.filmid = FPP.filmid
                      and FPP.parttype = 'director' );


-- Filmer uten skuespillere (cast):

select count(distinct FP.filmid) -- hvorfor distinct?
from Filmparticipation FP
where not exists ( select *
                   from Filmparticipation FPP
                   where FP.filmid = FPP.filmid
                      and FPP.parttype = 'cast' );



-- Filmer med hverken skuespillere eller regissør?

select count(distinct FP.filmid) -- hvorfor distinct?
from Filmparticipation FP
where not exists ( select *
                   from Filmparticipation FPP
                   where FP.filmid = FPP.filmid
                      and FPP.parttype in ('cast', 'director')
                 );


-- Hvilke(n) film(er) uten regissør har flest andre medvirkende?


select FP.filmid, count(FP.filmid) -- hvorfor ikke distinct?
from Filmparticipation FP
where not exists ( select *
                   from Filmparticipation FPP
                   where FP.filmid = FPP.filmid
                      and FPP.parttype = 'director' )
group by FP.filmid
having count(FP.filmid) > 150
order by count(FP.filmid) desc;


-- Hva slags type film er disse?

select FP.filmid, I.filmtype, -- grupperingsattributter
       count(FP.filmid)       -- hvorfor ikke distinct?
from Filmparticipation FP
     natural join
     Filmitem I
where not exists ( select *
                   from Filmparticipation FPP
                   where FP.filmid = FPP.filmid
                      and FPP.parttype = 'director' )
group by FP.filmid, I.filmtype
having count(FP.filmid) > 150
order by count(FP.filmid) desc;

-- Noen er faktisk kinofilmer (filmtype = 'C'), undersøker disse nærmere

 
select FP.filmid,             -- grupperingsattributt
       count(FP.filmid)       -- hvorfor ikke distinct?
from Filmparticipation FP
     natural join
     Filmitem I
where not exists ( select *
                   from Filmparticipation FPP
                   where FP.filmid = FPP.filmid
                      and FPP.parttype = 'director' )
      and I.filmtype = 'C'
group by FP.filmid
having count(FP.filmid) > 44
order by count(FP.filmid) desc;


-- Tabell med Filmtittel, filmid og for hver filmid hvor mange dektakere av forskjellige
-- deltakerfunksjoner for filmene i tabellen over:

select FP.filmid, F.title, FP.parttype,
       count(FP.filmid) 
from Filmparticipation FP
    natural join
     Filmitem I
    natural join

     ( select FP.filmid 
       from Filmparticipation FP
            natural join
            Filmitem I
       where not exists ( select *
                          from Filmparticipation FPP
                          where FP.filmid = FPP.filmid
                             and FPP.parttype = 'director' )
             and I.filmtype = 'C'
       group by FP.filmid
       having count(FP.filmid) > 44
      ) as R

     natural join
      Film F   
group by FP.filmid, F.title, FP.parttype
order by FP.filmid, count(FP.filmid) desc;


-- Navn på skuespillere som bare har deltatt i kinofilmer uten regissør


--1. Kinofilmer ('C') MED regissør ('director'):


                          ( select distinct FPRCN.filmid
                      from Filmparticipation FP
                                     natural join
                           Filmitem I  
                      where FPRCN.parttype = 'director'
                               and I.filmtype = 'C'
                    ) as KFR -- KinoFilmer med Regissør

--2. Alle kinofilmer en bestemt personid ( X.personid ) har vært skuespiller
 
                    ( select distinct FP.filmid
                      from Filmparticipation FP
                               natural join
                           Filmitem I
                      where  FP.parttype = 'cast'
                         and FP.personid = X.personid )

--3. Alle kinofilmer en bestemt personid ( X.personid ) har vært skuespiller
--   og hvor ingen av filmene har regissør:

                    ( select distinct FP.filmid
                      from Filmparticipation FP
                               natural join
                           Filmitem I
                      where  FP.parttype = 'cast'
                         and FP.personid = X.personid
                         and not exists 
                                 ( select *
                                 from Filmparticipation FPRCN
                                 where FPRCN.parttype = 'director'
                                       and FPRCN.filmid = FP.filmid )
     


select P.personid, P.firstname||' '||P.lastname as skuespiller,
       count(*)                        antall_filmer
from   Person P
     natural join
       Filmparticipation FP
     natural join
       Filmitem I
where FP.parttype='cast'
  and I.filmtype='C'
  and  not exists ( select FP.filmid
                   from Filmparticipation FP
                               natural join
                           Filmitem I
                      where  FP.parttype = 'cast'
                         and FP.personid = P.personid
                         and I.filmtype = 'C'
                         and exists 
                                 ( select *
                                 from Filmparticipation FPRCN
                                 where FPRCN.parttype = 'director'
                                       and FPRCN.filmid = FP.filmid )
                   )
group by P.personid, P.firstname, P.lastname
having count(*) > 7;





/*
 La oss for ordens skyld sjekke denne:

 personid |   skuespiller    | antall_filmer 
----------+------------------+---------------
  3580290 | Frances Keyes    |            24
*/


-- Alle kinofilmer Frances Keyes har spilt i:

(
select distinct FP.filmid
from   Person P
     natural join
       Filmparticipation FP
     natural join
       Filmitem I
where FP.parttype='cast'
  and I.filmtype='C'
  and P.personid=3580290
)                         as FKeyes


select *
from Filmparticipation FP
  natural join
     (
      select distinct FP.filmid
      from   Person P
           natural join
             Filmparticipation FP
           natural join
             Filmitem I
      where FP.parttype='cast'
        and I.filmtype='C'
        and P.personid=3580290
     )                         as FKeyes
where FP.parttype = 'director';





-- Skuespillere som bare har spilt i flere enn 50 filmer, alle filmer med komponist

-- Navn på skuespillere som ikke har spilt (not exists filmid) i noen film
-- som ikke har komponist (not exists parttype='composer').

select P.personid, P.firstname||' '||P.lastname as skuespiller,
       count(*)                        antall_filmer
from   Person P
     natural join
       Filmparticipation FP
     natural join
       Filmitem I
where FP.parttype='cast'
  and I.filmtype='C'
  and  not exists ( select FP.filmid
                   from Filmparticipation FP
                               natural join
                           Filmitem I
                      where  FP.parttype = 'cast'
                         and FP.personid = P.personid
                         and I.filmtype = 'C'
                         and not exists 
                                 ( select *
                                 from Filmparticipation FPRCN
                                 where FPRCN.parttype = 'composer'
                                       and FPRCN.filmid = FP.filmid )
                   )
group by P.personid, P.firstname, P.lastname
having count(*) > 50;


/*
La oss igjen sjekke komponister for Asikainens filmer:

 personid |   skuespiller   | antall_filmer 
----------+-----------------+---------------
   181177 | Joel Asikainen  |            55

*/

(
select distinct FP.filmid
from   Person P
     natural join
       Filmparticipation FP
     natural join
       Filmitem I
where FP.parttype='cast'
  and I.filmtype='C'
  and P.personid=181177
)                         as Asikainen




select distinct FP.filmid
from Filmparticipation FP
  natural join
     (
      select distinct FP.filmid
      from   Person P
           natural join
             Filmparticipation FP
           natural join
             Filmitem I
      where FP.parttype='cast'
        and I.filmtype='C'
        and P.personid=181177
     )                         as Asikainen
where FP.parttype = 'composer';








select count(*)
from
   Film F
     LEFT OUTER join
   Filmitem I
     on F.filmid = I.filmid
where I.filmid is null;

select count(*)
from
   Filmparticipation F
     LEFT OUTER join
   Filmitem I
     on F.filmid = I.filmid
where I.filmid is null;

select count(*)
from
   Filmcountry F
     LEFT OUTER join
   Filmitem I
     on F.filmid = I.filmid
where I.filmid is null;

select count(*)
from
   Series F
     LEFT OUTER join
   Filmitem I
     on F.filmid = I.filmid
where I.filmid is null;
     


