-- Illuminati Database Management System -- schema
--
-- Load into any database:  mysql <dbname> < sql/schema.sql
-- Deliberately contains no CREATE DATABASE / USE, so the same DDL can build
-- the demo database and a throwaway benchmark database.
--
-- Tables are declared in dependency order, so every foreign key resolves
-- without disabling FOREIGN_KEY_CHECKS.

SET NAMES utf8mb4;

-- Drops run in reverse dependency order so reloading is idempotent.
DROP TABLE IF EXISTS Surveys;
DROP TABLE IF EXISTS Organizations;
DROP TABLE IF EXISTS Individuals;
DROP TABLE IF EXISTS Surveillance;
DROP TABLE IF EXISTS Secret_Knowledge_Archives;
DROP TABLE IF EXISTS Curators;
DROP TABLE IF EXISTS Orchestrates;
DROP TABLE IF EXISTS Organizations_Under_Control;
DROP TABLE IF EXISTS Sacred_Timeline_Events;
DROP TABLE IF EXISTS Perform_Rituals;
DROP TABLE IF EXISTS Guards;
DROP TABLE IF EXISTS Powers;
DROP TABLE IF EXISTS Artifacts_And_Treasures;
DROP TABLE IF EXISTS Faction_Meetings;
DROP TABLE IF EXISTS Faction_Members;
DROP TABLE IF EXISTS Factions;
DROP TABLE IF EXISTS Key_Illuminati_Members;
DROP TABLE IF EXISTS Sanctum_Sanctorum;


-- ---------------------------------------------------------------------------
-- Core entities
-- ---------------------------------------------------------------------------

-- Sanctums are keyed by their mantra: a natural text key, not a surrogate id.
CREATE TABLE Sanctum_Sanctorum (
  Mantra              varchar(50)  NOT NULL,
  Street              varchar(255) NOT NULL,
  City                varchar(255) NOT NULL,
  Country             varchar(255) NOT NULL,
  Number_Of_Residents int          NOT NULL,
  History             text         NOT NULL,
  PRIMARY KEY (Mantra),
  CONSTRAINT chk_sanctum_residents CHECK (Number_Of_Residents >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- The 13 members. Title is the text key that nearly everything references.
-- Name stays nullable on purpose: one member ('Dementor') has no known identity.
CREATE TABLE Key_Illuminati_Members (
  Title                varchar(255) NOT NULL,
  Name                 varchar(255) DEFAULT NULL,
  Description_Of_Past  text         NOT NULL,
  Date_Of_Selling_Soul date         NOT NULL,
  ResidesIn            varchar(50)  DEFAULT NULL,
  PRIMARY KEY (Title),
  KEY idx_members_resides_in (ResidesIn),
  CONSTRAINT fk_members_sanctum FOREIGN KEY (ResidesIn)
    REFERENCES Sanctum_Sanctorum (Mantra)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Factions (
  Faction_Id int          NOT NULL,
  Aim        text         NOT NULL,
  Symbol     varchar(255) NOT NULL,
  HeadTitle  varchar(255) DEFAULT NULL,
  PRIMARY KEY (Faction_Id),
  KEY idx_factions_head (HeadTitle),
  CONSTRAINT fk_factions_head FOREIGN KEY (HeadTitle)
    REFERENCES Key_Illuminati_Members (Title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Self-referencing hierarchy. Roots have Leader_Id IS NULL; the recursive CTE
-- in the monthly report descends from those roots.
CREATE TABLE Faction_Members (
  Member_Id  int          NOT NULL,
  Fname      varchar(255) NOT NULL,
  Mname      varchar(255) DEFAULT NULL,
  Lname      varchar(255) NOT NULL,
  Dob        date         NOT NULL,
  Faction_Id int          NOT NULL,
  Leader_Id  int          DEFAULT NULL,
  PRIMARY KEY (Member_Id),
  KEY idx_faction_members_faction (Faction_Id),
  KEY idx_faction_members_leader (Leader_Id),
  CONSTRAINT fk_faction_members_faction FOREIGN KEY (Faction_Id)
    REFERENCES Factions (Faction_Id),
  CONSTRAINT fk_faction_members_leader FOREIGN KEY (Leader_Id)
    REFERENCES Faction_Members (Member_Id),
  -- A member cannot be their own leader. NULL Leader_Id yields NULL, which passes.
  CONSTRAINT chk_faction_members_not_self_led CHECK (Leader_Id <> Member_Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- A meeting is identified by faction plus when it happened.
CREATE TABLE Faction_Meetings (
  Faction_Id int          NOT NULL,
  Time       time         NOT NULL,
  Date       date         NOT NULL,
  Agenda     text         NOT NULL,
  Street     varchar(255) NOT NULL,
  City       varchar(255) NOT NULL,
  Country    varchar(255) NOT NULL,
  PRIMARY KEY (Faction_Id, Time, Date),
  CONSTRAINT fk_faction_meetings_faction FOREIGN KEY (Faction_Id)
    REFERENCES Factions (Faction_Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- ---------------------------------------------------------------------------
-- Artifacts and their children
--
-- All three child tables cascade on delete. The application previously emulated
-- this by hand; the constraint belongs in the schema, not in Python.
-- ---------------------------------------------------------------------------

CREATE TABLE Artifacts_And_Treasures (
  Artifact_Id         int  NOT NULL,
  Origin              text NOT NULL,
  Date_Of_Procurement date NOT NULL,
  Faction_Id          int  NOT NULL,
  PRIMARY KEY (Artifact_Id),
  KEY idx_artifacts_faction (Faction_Id),
  CONSTRAINT fk_artifacts_faction FOREIGN KEY (Faction_Id)
    REFERENCES Factions (Faction_Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- The multivalued attribute 'Power' split into its own table for 1NF.
CREATE TABLE Powers (
  Artifact_Id int          NOT NULL,
  Power       varchar(255) NOT NULL,
  PRIMARY KEY (Artifact_Id, Power),
  CONSTRAINT fk_powers_artifact FOREIGN KEY (Artifact_Id)
    REFERENCES Artifacts_And_Treasures (Artifact_Id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Guards (
  Member_Id   int NOT NULL,
  Artifact_Id int NOT NULL,
  PRIMARY KEY (Member_Id, Artifact_Id),
  KEY idx_guards_artifact (Artifact_Id),
  CONSTRAINT fk_guards_member FOREIGN KEY (Member_Id)
    REFERENCES Faction_Members (Member_Id),
  CONSTRAINT fk_guards_artifact FOREIGN KEY (Artifact_Id)
    REFERENCES Artifacts_And_Treasures (Artifact_Id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Perform_Rituals (
  Title       varchar(255) NOT NULL,
  Mantra      varchar(50)  NOT NULL,
  Artifact_Id int          NOT NULL,
  PRIMARY KEY (Title, Artifact_Id, Mantra),
  KEY idx_rituals_artifact (Artifact_Id),
  KEY idx_rituals_mantra (Mantra),
  CONSTRAINT fk_rituals_member FOREIGN KEY (Title)
    REFERENCES Key_Illuminati_Members (Title),
  CONSTRAINT fk_rituals_sanctum FOREIGN KEY (Mantra)
    REFERENCES Sanctum_Sanctorum (Mantra),
  CONSTRAINT fk_rituals_artifact FOREIGN KEY (Artifact_Id)
    REFERENCES Artifacts_And_Treasures (Artifact_Id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- ---------------------------------------------------------------------------
-- Events and the organizations under control
-- ---------------------------------------------------------------------------

-- Event_Id is a text key ('EVT001'), not an integer.
CREATE TABLE Sacred_Timeline_Events (
  Event_Id    varchar(255) NOT NULL,
  Date        date         NOT NULL,
  Time        time         NOT NULL,
  Status      varchar(255) NOT NULL,
  Description text         NOT NULL,
  PRIMARY KEY (Event_Id),
  CONSTRAINT chk_event_status
    CHECK (Status IN ('Planned', 'In Progress', 'Executed'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Organizations_Under_Control (
  Name            varchar(255) NOT NULL,
  Type            varchar(255) NOT NULL,
  Kind_Of_Control varchar(255) NOT NULL,
  PRIMARY KEY (Name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Three-way relationship: a member orchestrates an event on behalf of a faction,
-- acting through a controlled organization.
CREATE TABLE Orchestrates (
  Title      varchar(255) NOT NULL,
  Event_Id   varchar(255) NOT NULL,
  Faction_Id int          NOT NULL,
  Name       varchar(255) NOT NULL,
  PRIMARY KEY (Title, Event_Id, Faction_Id),
  KEY idx_orchestrates_event (Event_Id),
  KEY idx_orchestrates_faction (Faction_Id),
  KEY idx_orchestrates_org (Name),
  CONSTRAINT fk_orchestrates_member FOREIGN KEY (Title)
    REFERENCES Key_Illuminati_Members (Title),
  CONSTRAINT fk_orchestrates_event FOREIGN KEY (Event_Id)
    REFERENCES Sacred_Timeline_Events (Event_Id),
  CONSTRAINT fk_orchestrates_faction FOREIGN KEY (Faction_Id)
    REFERENCES Factions (Faction_Id),
  CONSTRAINT fk_orchestrates_org FOREIGN KEY (Name)
    REFERENCES Organizations_Under_Control (Name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- ---------------------------------------------------------------------------
-- Archives
--
-- Curators exists because Curator is functionally dependent on Category, not on
-- Archive_Id. Splitting it out is what takes the archives into 3NF.
-- ---------------------------------------------------------------------------

CREATE TABLE Curators (
  Category varchar(255) NOT NULL,
  Curator  varchar(255) NOT NULL,
  PRIMARY KEY (Category),
  KEY idx_curators_curator (Curator),
  CONSTRAINT fk_curators_member FOREIGN KEY (Curator)
    REFERENCES Key_Illuminati_Members (Title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Secret_Knowledge_Archives (
  Archive_Id          varchar(255) NOT NULL,
  Category            varchar(255) NOT NULL,
  -- Was varchar(255) holding ISO date strings; a date column is the correct type.
  Date_of_Last_Update date         NOT NULL,
  PRIMARY KEY (Archive_Id),
  KEY idx_archives_category (Category),
  CONSTRAINT fk_archives_category FOREIGN KEY (Category)
    REFERENCES Curators (Category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- ---------------------------------------------------------------------------
-- Surveillance, specialized into Individuals and Organizations
--
-- Both subclasses key on the parent's Surveillance_Id, so each row is at most
-- one of the two.
-- ---------------------------------------------------------------------------

CREATE TABLE Surveillance (
  Surveillance_Id      int  NOT NULL,
  Start_Date_Of_Survey date NOT NULL,
  PRIMARY KEY (Surveillance_Id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Individuals (
  Surveillance_Id        int          NOT NULL,
  Fname                  varchar(255) NOT NULL,
  Mname                  varchar(255) DEFAULT NULL,
  Lname                  varchar(255) NOT NULL,
  Current_Location       varchar(255) NOT NULL,
  Nationality            varchar(255) NOT NULL,
  Interests              text         NOT NULL,
  Past                   text         NOT NULL,
  Citizenship_Identifier varchar(255) NOT NULL,
  PRIMARY KEY (Surveillance_Id),
  CONSTRAINT fk_individuals_surveillance FOREIGN KEY (Surveillance_Id)
    REFERENCES Surveillance (Surveillance_Id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Organizations (
  Surveillance_Id int          NOT NULL,
  Name            varchar(255) NOT NULL,
  Type            varchar(255) NOT NULL,
  President       varchar(255) NOT NULL,
  PRIMARY KEY (Surveillance_Id),
  CONSTRAINT fk_organizations_surveillance FOREIGN KEY (Surveillance_Id)
    REFERENCES Surveillance (Surveillance_Id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE Surveys (
  Surveillance_Id int          NOT NULL,
  Title           varchar(255) NOT NULL,
  PRIMARY KEY (Title, Surveillance_Id),
  KEY idx_surveys_surveillance (Surveillance_Id),
  CONSTRAINT fk_surveys_surveillance FOREIGN KEY (Surveillance_Id)
    REFERENCES Surveillance (Surveillance_Id) ON DELETE CASCADE,
  CONSTRAINT fk_surveys_member FOREIGN KEY (Title)
    REFERENCES Key_Illuminati_Members (Title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
