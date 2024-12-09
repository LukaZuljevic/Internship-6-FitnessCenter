CREATE TABLE Country(
    CountryId SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    AverageSalary FLOAT DEFAULT 0 CHECK(AverageSalary >= 0),
    Population INT CHECK(Population > 0)
);

CREATE TABLE Center(
    CenterId SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    WorkingHours VARCHAR(30) NOT NULL,
    CountryId INT References Country(CountryId),
    UNIQUE(CenterId, CountryId)
);

CREATE TABLE Trainer(
    TrainerId SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Surname VARCHAR(50) NOT NULL,
    BirthDate TIMESTAMP CHECK(BirthDate < CURRENT_TIMESTAMP),
    Sex VARCHAR(30) CHECK (Sex IN ('Muski', 'Zenski', 'Nepoznato', 'Ostalo')),
    CountryId INT References Country(CountryId),
    CenterId INT References Center(CenterId)
);

CREATE TABLE ActivityType(
    ActivityTypeId SERIAL PRIMARY KEY,
    Type VARCHAR(30) NOT NULL
);

CREATE TABLE Activity(
    ActivityId SERIAL PRIMARY KEY,
    TypeId INT References ActivityType(ActivityTypeId),
    Price FLOAT CHECK(Price > 0)
);

CREATE TABLE Schedule(
    ScheduleId SERIAL PRIMARY KEY,
    ActivityId INT References Activity(ActivityId),
    Capacity INT CHECK(Capacity > 0),
    Time TIMESTAMP NOT NULL,
    ActivityCode VARCHAR(9) UNIQUE
);

CREATE TABLE Participant(
    ParticipantId SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Surname VARCHAR(50) NOT NULL,
    CountryId INT References Country(CountryId)
);

CREATE TABLE ActivityParticipant(
    ActivityParticipantId SERIAL PRIMARY KEY,
    ActivityId INT References Activity(ActivityId),
    ParticipantId INT References Participant(ParticipantId),
    UNIQUE(ActivityId, ParticipantId)
);

CREATE TABLE ActivityTrainer(
    ActivityTrainerId SERIAL PRIMARY KEY,
    ActivityId INT References Activity(ActivityId),
    TrainerId INT References Trainer(TrainerId),
    TrainerType VARCHAR(10) CHECK(TrainerType IN ('Glavni', 'Pomocni')),
    UNIQUE(ActivityId, TrainerId)
);

CREATE UNIQUE INDEX UniqueMainTrainerPerActivity
ON ActivityTrainer(ActivityId)
WHERE TrainerType = 'Glavni';


