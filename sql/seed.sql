-- Illuminati Database Management System -- seed data
--
-- Load after sql/schema.sql:  mysql <dbname> < sql/seed.sql
-- Inserts run in dependency order, so no foreign key is ever violated.

SET NAMES utf8mb4;

-- Sanctums ------------------------------------------------------------------
INSERT INTO Sanctum_Sanctorum
  (Mantra, Street, City, Country, Number_Of_Residents, History) VALUES
  ('Ad Astra',        'Older Delhi',     'Delhi',     'India',          2, 'Temple of cosmic knowledge'),
  ('Carpe Noctem',    'Immortal Way',    'Alexandria','Egypt',          2, 'Ancient library of forbidden knowledge'),
  ('Ex Nihilo',       'Mystic Avenue',   'Tibet',     'China',          2, 'Mountain temple of eternal wisdom'),
  ('Lux In Tenebris', 'Shadow Lane',     'Venice',    'Italy',          2, 'Ancient palazzo hiding countless secrets'),
  ('Memento Mori',    'CR Rao Road',     'Hyderabad', 'India',          2, 'Sacred chambers beneath holy ground'),
  ('Per Aspera',      'Devils Quarter',  'Prague',    'Czech Republic', 2, 'Medieval stronghold of dark arts');

-- The thirteen. 'Dementor' has no known name, hence the NULL.
INSERT INTO Key_Illuminati_Members
  (Name, Title, Description_Of_Past, Date_Of_Selling_Soul, ResidesIn) VALUES
  ('Meryl Streep',      'Artemis',           'Legendary infiltrator and master of disguise',   '1749-06-21', 'Ex Nihilo'),
  ('Faltu Singh',       'Ashwathama',        'Immortal warrior and keeper of ancient weapons', '1245-07-13', 'Carpe Noctem'),
  ('PK',                'Corleone',          'Supreme commander of mortal influence',          '1923-11-11', 'Carpe Noctem'),
  (NULL,                'Dementor',          'Half blood prince',                              '1307-06-03', 'Memento Mori'),
  ('Farshit Lalwani',   'Hanan',             'Bearer of divine light and cosmic wisdom',       '1777-07-07', 'Per Aspera'),
  ('Dan Reynolds',      'Jove',              'Master of elements and natural forces',          '1901-03-17', 'Memento Mori'),
  ('Dogé Musk',         'Kubera',            'Controller of global wealth and resources',      '1956-04-01', 'Ad Astra'),
  ('FishFish Saraswat', 'La Eminence grise', 'Master of shadows and keeper of secrets',        '1523-03-15', 'Lux In Tenebris'),
  ('Bhimapuram',        'Lucifer',           'Architect of chaos and master strategist',       '1666-06-06', 'Per Aspera'),
  ('Dame Judy Trench',  'Nekhbet',           'Ancient guardian of forbidden knowledge',        '1652-12-01', 'Memento Mori'),
  ('Beyoncé',           'Nuwa',              'Creator of illusions and keeper of harmony',     '1888-12-25', 'Ex Nihilo'),
  ('Oprah',             'Pythia',            'Seer of futures and manipulator of destinies',   '1854-09-30', 'Ad Astra'),
  ('Faizal Khan',       'Vali',              'Vengeance incarnate and master of retribution',  '1789-08-21', 'Lux In Tenebris');

-- Factions ------------------------------------------------------------------
-- Note factions 4, 5 and 6 deliberately have no members: they exercise the
-- difference between "all factions" and "factions that have members".
INSERT INTO Factions (Faction_Id, Aim, Symbol, HeadTitle) VALUES
  (1, 'Global Financial Control', 'Golden Snake',   'Kubera'),
  (2, 'Media Manipulation',       'All-Seeing Eye', 'Artemis'),
  (3, 'Political Influence',      'Crown of Thorns','Corleone'),
  (4, 'Scientific Advancement',   'Quantum Spiral', 'La Eminence grise'),
  (5, 'Religious Control',        'Broken Cross',   'Pythia'),
  (6, 'Military Operations',      'Iron Fist',      'Vali');

-- Members are inserted leaders-first so each Leader_Id already exists.
INSERT INTO Faction_Members
  (Member_Id, Fname, Mname, Lname, Dob, Faction_Id, Leader_Id) VALUES
  ( 1, 'Viktor',    NULL,    'Petrov',    '1975-03-15', 1, NULL),
  ( 4, 'Hassan',    NULL,    'Al-Rashid', '1968-11-30', 2, NULL),
  ( 8, 'Alexandra', NULL,    'Volkov',    '1973-12-10', 3, NULL),
  ( 2, 'Sarah',     'Jane',  'Williams',  '1982-07-21', 1, 1),
  ( 3, 'James',     NULL,    'Chen',      '1979-11-30', 1, 1),
  ( 5, 'Ming',      NULL,    'Wei',       '1979-09-05', 2, 4),
  ( 6, 'Elena',     'Maria', 'Garcia',    '1985-04-15', 2, 4),
  ( 7, 'John',      NULL,    'Smith',     '1977-08-22', 2, 4),
  ( 9, 'Marcus',    'James', 'Brown',     '1980-06-25', 3, 8),
  (10, 'Isabella',  NULL,    'Romano',    '1982-03-18', 3, 8),
  (11, 'Alice',     NULL,    'Wunderkid', '1990-05-05', 1, 3),
  (12, 'Bob',       'the',   'Builder',   '1989-01-01', 3, 9),
  (13, 'Peter',     NULL,    'Pan',       '1993-09-03', 3, 12);

INSERT INTO Faction_Meetings
  (Faction_Id, Time, Date, Agenda, Street, City, Country) VALUES
  (1, '14:00:00', '2024-12-01', 'Financial Strategy Review',      'Secret Street 1', 'Geneva',     'Switzerland'),
  (2, '20:00:00', '2024-12-15', 'Media Control Operation',        'Hidden Ave 2',    'London',     'UK'),
  (3, '10:00:00', '2024-12-30', 'Political Influence Assessment', 'Shadow Road 3',   'Washington', 'USA');

-- Artifacts and children ----------------------------------------------------
INSERT INTO Artifacts_And_Treasures
  (Artifact_Id, Origin, Date_Of_Procurement, Faction_Id) VALUES
  (1, 'Ancient Egypt', '1523-01-01', 1),
  (2, 'Atlantis',      '1666-06-06', 2),
  (3, 'Tibet',         '1888-08-08', 3);

INSERT INTO Powers (Artifact_Id, Power) VALUES
  (1, 'Prophecy'),
  (1, 'Time Manipulation'),
  (2, 'Mind Control'),
  (2, 'Teleportation'),
  (3, 'Reality Alteration'),
  (3, 'Time Reversal');

INSERT INTO Guards (Member_Id, Artifact_Id) VALUES
  (1, 1),
  (2, 2),
  (3, 3);

INSERT INTO Perform_Rituals (Title, Mantra, Artifact_Id) VALUES
  ('La Eminence grise', 'Lux In Tenebris', 1),
  ('Pythia',            'Ex Nihilo',       2),
  ('Nekhbet',           'Memento Mori',    3);

-- Events and controlled organizations ---------------------------------------
INSERT INTO Sacred_Timeline_Events (Event_Id, Date, Time, Status, Description) VALUES
  ('EVT001', '2024-12-21', '00:00:00', 'Planned',     'Global Financial Reset'),
  ('EVT002', '2024-10-31', '15:30:00', 'In Progress', 'Media Blackout Operation'),
  ('EVT003', '2024-11-15', '12:00:00', 'Executed',    'Political Regime Change'),
  ('EVT004', '2025-01-01', '00:01:00', 'Planned',     'Technological Paradigm Shift'),
  ('EVT005', '2024-12-25', '23:59:59', 'In Progress', 'Mass Consciousness Alteration');

INSERT INTO Organizations_Under_Control (Name, Type, Kind_Of_Control) VALUES
  ('Advanced Research Division', 'Corporate',  'Financial'),
  ('Global Defense Initiative',  'Government', 'Political'),
  ('Temple of Ultimate Truth',   'Religious',  'Informational'),
  ('United Media Corp',          'Corporate',  'Informational'),
  ('World Bank',                 'Corporate',  'Financial');

INSERT INTO Orchestrates (Title, Event_Id, Faction_Id, Name) VALUES
  ('Vali',     'EVT004', 6, 'Advanced Research Division'),
  ('Corleone', 'EVT003', 3, 'Global Defense Initiative'),
  ('Lucifer',  'EVT005', 5, 'Temple of Ultimate Truth'),
  ('Artemis',  'EVT002', 2, 'United Media Corp'),
  ('Kubera',   'EVT001', 1, 'World Bank');

-- Archives ------------------------------------------------------------------
INSERT INTO Curators (Category, Curator) VALUES
  ('Modern Conspiracies', 'La Eminence grise'),
  ('Ancient Scripts',     'Nekhbet'),
  ('Forbidden Sciences',  'Pythia');

INSERT INTO Secret_Knowledge_Archives (Archive_Id, Category, Date_of_Last_Update) VALUES
  ('ARC001', 'Ancient Scripts',     '2024-01-01'),
  ('ARC002', 'Modern Conspiracies', '2024-06-15'),
  ('ARC003', 'Forbidden Sciences',  '2024-03-30');

-- Surveillance --------------------------------------------------------------
-- Operation 5 is intentionally neither an individual nor an organization.
INSERT INTO Surveillance (Surveillance_Id, Start_Date_Of_Survey) VALUES
  (1, '2024-01-01'),
  (2, '2024-02-15'),
  (3, '2024-03-30'),
  (4, '2024-04-15'),
  (5, '2024-05-01');

INSERT INTO Individuals
  (Surveillance_Id, Fname, Mname, Lname, Current_Location, Nationality, Interests, Past, Citizenship_Identifier) VALUES
  (1, 'John',  NULL,    'Smith',  'New York', 'American', 'Quantum Computing', 'Former Intelligence Officer', 'US-123456'),
  (2, 'Maria', 'Elena', 'Garcia', 'Madrid',   'Spanish',  'Biotechnology',     'Research Scientist',          'ESP-789012');

INSERT INTO Organizations (Surveillance_Id, Name, Type, President) VALUES
  (3, 'Tech Innovations Ltd',    'Corporate',  'James Wilson'),
  (4, 'Global Peace Foundation', 'Government', 'Elena Rodriguez');

INSERT INTO Surveys (Surveillance_Id, Title) VALUES
  (1, 'La Eminence grise'),
  (2, 'Artemis'),
  (3, 'Pythia');
