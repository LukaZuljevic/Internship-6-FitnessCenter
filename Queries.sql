-- Ime, prezime, spol (ispisati ‘MUŠKI’, ‘ŽENSKI’, ‘NEPOZNATO’, ‘OSTALO’), ime države i prosječna plaća u toj državi za svakog trenera.
SELECT t.Name, Surname, Sex, c.Name AS country, c.AverageSalary AS average_salary FROM Trainer t
JOIN Country c ON t.CountryId = c.CountryId

-- Naziv i termin održavanja svake sportske igre zajedno s imenima glavnih trenera (u formatu Prezime, I.; npr. Horvat, M.; Petrović, T.).
SELECT a.ActivityId, Time AS Date, at.Type AS activity, CONCAT(t.Surname, ', ', LEFT(t.Name, 1), '.') AS main_trainer
FROM Schedule s
JOIN Activity a ON a.ActivityId = s.ActivityId
JOIN ActivityType at ON at.ActivityTypeId = a.TypeId 
JOIN ActivityTrainer atr ON atr.ActivityId = a.ActivityId
JOIN Trainer t ON t.TrainerId = atr.TrainerId
WHERE atr.TrainerType = 'Glavni'
ORDER BY s.time DESC

-- Top 3 fitness centra s najvećim brojem aktivnosti u rasporedu
SELECT c.Name AS fitness_center, COUNT(s.ActivityId) AS number_of_activities
FROM 
Schedule S
JOIN Activity a ON s.ActivityId = a.ActivityId
JOIN Trainer t ON t.TrainerId = (
     SELECT TrainerId 
     FROM ActivityTrainer 
     WHERE ActivityId = a.ActivityId 
     LIMIT 1 )
JOIN Center c ON t.CenterId = c.CenterId
GROUP BY c.Name
ORDER BY number_of_activities DESC
LIMIT 3;

-- Po svakom terneru koliko trenutno aktivnosti vodi; ako nema aktivnosti, ispiši “DOSTUPAN”, ako ima do 3 ispiši “AKTIVAN”, a ako je na više ispiši “POTPUNO ZAUZET”.
SELECT t.TrainerId, Name, Surname, 
CASE
	WHEN COUNT(at.ActivityId) = 0 THEN 'Dostupan'
	WHEN COUNT(at.ActivityId) BETWEEN 1 AND 3 THEN 'Aktivan'
	ELSE 'Potpuno zauzet' END AS Availability
FROM Trainer t 
JOIN ActivityTrainer at ON at.TrainerId = t.TrainerId
GROUP BY t.TrainerId

-- Imena svih članova koji trenutno sudjeluju na nekoj aktivnosti.
SELECT p.Name AS ParticipantName, p.Surname AS ParticipantSurname
FROM 
ActivityParticipant ap
JOIN Participant p ON ap.ParticipantId = p.ParticipantId
JOIN Schedule s ON ap.ActivityId = s.ActivityId
WHERE s.Time <= CURRENT_TIMESTAMP AND s.Time + INTERVAL '1 hour' > CURRENT_TIMESTAMP; --Ode sam pretpostavia da aktivnost traje 1 sat ali onda postoji mogucnost da nema trenutnih aktivnosti u tijeku

-- Sve trenere koji su vodili barem jednu aktivnost između 2019. i 2022.

-- Prosječan broj sudjelovanja po tipu aktivnosti po svakoj državi.

-- Top 10 država s najvećim brojem sudjelovanja u injury rehabilitation tipu aktivnosti

-- Ako aktivnost nije popunjena, ispiši uz nju “IMA MJESTA”, a ako je popunjena ispiši “POPUNJENO”

-- 10 najplaćenijih trenera, ako po svakoj aktivnosti dobije prihod kao brojSudionika * cijenaPoTerminu