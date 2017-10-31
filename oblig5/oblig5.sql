-- 1. Skriv ut tabell med rollefigur og hvor ofte rollen dukker opp

SELECT filmcharacter, count(*)
FROM Filmcharacter f
GROUP By filmcharacter
HAVING Count(f.filmcharacter) > 800
ORDER BY COUNT(*) DESC
LIMIT( 365);

-- 2. Skriv ut personid og etternavn til Ingrid-er som har spilt rollen 'Ingrid'. Ta med filmtittel og land 

SELECT  personid, lastname,title, country
FROM person p NATURAL JOIN filmparticipation f 
NATURAL JOIN filmcharacter c
NATURAL JOIN filmcountry co
NATURAL JOIN film
where p.firstname = 'Ingrid' AND c.filmcharacter = 'Ingrid';

-- 3. Skriv ut fornavn, etternavn, rollenavn som skuespilleren med id 3914169 har hatt, og i hvilke filmer

SELECT firstname,lastname,filmcharacter, title
FROM person p NATURAL JOIN filmparticipation f
NATURAL JOIN filmcharacter c
NATURAL JOIN film
WHERE p.personid = 3914169 AND c.filmcharacter <> '';

-- 4. Hvem (ID og navn) har spilt en rollefigur med navn Ingrid flest ganger? Skriv også antall ganger

SELECT personid, firstname || ' ' || lastname AS navn, count(*)

