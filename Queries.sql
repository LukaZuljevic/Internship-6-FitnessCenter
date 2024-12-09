-- Ime, prezime, spol (ispisati ‘MUŠKI’, ‘ŽENSKI’, ‘NEPOZNATO’, ‘OSTALO’), ime države i prosječna plaća u toj državi za svakog trenera.
SELECT t.Name, Surname, Sex, c.Name AS country, c.AverageSalary AS average_salary 
FROM Trainer t
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
FROM Schedule S
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
SELECT p.Name AS participant_name, p.Surname AS participant_surname, aty.type AS activity, s.Time
FROM ActivityParticipant ap
JOIN Participant p ON ap.ParticipantId = p.ParticipantId
JOIN Schedule s ON ap.ActivityId = s.ActivityId
JOIN Activity a ON a.ActivityId = s.ActivityId
JOIN ActivityType aty ON aty.ActivityTypeId = a.TypeId 
WHERE s.Time <= CURRENT_TIMESTAMP AND s.Time + INTERVAL '1 hour' > CURRENT_TIMESTAMP; --Ode sam pretpostavia da aktivnost traje 1 sat ali onda postoji mogucnost da nema trenutnih aktivnosti u tijeku

-- Sve trenere koji su vodili barem jednu aktivnost između 2019. i 2022.
SELECT DISTINCT t.TrainerId, Name, Surname 
FROM Trainer t
JOIN ActivityTrainer at ON at.TrainerId = t.TrainerId
JOIN Schedule s ON s.ActivityId = at.ActivityId
WHERE s.Time BETWEEN '2019-01-01' AND '2022-12-31'

-- Prosječan broj sudjelovanja po tipu aktivnosti po svakoj državi.
SELECT c.Name AS country_name, at.Type AS activity, ROUND(AVG(ap.ParticipantCount), 3) AS average_participation
FROM Country c
CROSS JOIN ActivityType at
JOIN Trainer t ON t.CountryId = c.CountryId
JOIN ActivityTrainer atr ON t.TrainerId = atr.TrainerId
JOIN Activity a ON atr.ActivityId = a.ActivityId AND a.TypeId = at.ActivityTypeId
JOIN(SELECT ActivityId, COUNT(ParticipantId) AS ParticipantCount
     FROM ActivityParticipant
     GROUP BY ActivityId) ap ON a.ActivityId = ap.ActivityId
	 
GROUP BY c.Name, at.Type
ORDER BY c.Name, at.Type;

-- Top 10 država s najvećim brojem sudjelovanja u injury rehabilitation tipu aktivnosti
SELECT c.Name AS country_name, at.Type AS activity, SUM(ap.ParticipantCount) AS total_participation
FROM Country c
JOIN Trainer t ON t.CountryId = c.CountryId
JOIN ActivityTrainer atr ON t.TrainerId = atr.TrainerId
JOIN Activity a ON atr.ActivityId = a.ActivityId
JOIN ActivityType at ON a.TypeId = at.ActivityTypeId
JOIN (SELECT ActivityId, COUNT(ParticipantId) AS ParticipantCount
     FROM ActivityParticipant
     GROUP BY ActivityId) ap ON a.ActivityId = ap.ActivityId
	 
WHERE at.Type = 'Injury rehabilitation'
GROUP BY c.Name, at.Type
ORDER BY total_participation DESC
LIMIT 10;

-- Ako aktivnost nije popunjena, ispiši uz nju “IMA MJESTA”, a ako je popunjena ispiši “POPUNJENO”
SELECT S.ActivityId,
CASE 
    WHEN (SELECT COUNT(*) 
         FROM ActivityParticipant 
         WHERE ActivityId = s.ActivityId) < s.Capacity THEN 'Ima mista'
    ELSE 'Popunjeno'
END AS Availability
FROM Schedule s;

-- 10 najplaćenijih trenera, ako po svakoj aktivnosti dobije prihod kao brojSudionika * cijenaPoTerminu
SELECT t.TrainerId, Name, Surname, SUM(ap.ParticipantCount * a.Price) AS total_profit
FROM Trainer t
JOIN ActivityTrainer at ON t.TrainerId = at.TrainerId
JOIN Activity a ON at.ActivityId = a.ActivityId
JOIN (SELECT ActivityId, COUNT(ParticipantId) AS ParticipantCount
     FROM ActivityParticipant
     GROUP BY ActivityId) ap ON a.ActivityId = ap.ActivityId
	 
GROUP BY t.TrainerId, Name, Surname
ORDER BY total_profit DESC
LIMIT 10;