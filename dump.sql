-- MySQL dump 10.13  Distrib 5.7.24, for osx11.1 (x86_64)
--
-- Host: localhost    Database: Illuminati
-- ------------------------------------------------------
-- Server version	9.0.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Artifacts_And_Treasures`
--

DROP TABLE IF EXISTS `Artifacts_And_Treasures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Artifacts_And_Treasures` (
  `Artifact_Id` int NOT NULL,
  `Origin` text,
  `Date_Of_Procurement` date DEFAULT NULL,
  `Faction_Id` int DEFAULT NULL,
  PRIMARY KEY (`Artifact_Id`),
  KEY `Faction_Id` (`Faction_Id`),
  CONSTRAINT `artifacts_and_treasures_ibfk_1` FOREIGN KEY (`Faction_Id`) REFERENCES `Factions` (`Faction_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Artifacts_And_Treasures`
--

LOCK TABLES `Artifacts_And_Treasures` WRITE;
/*!40000 ALTER TABLE `Artifacts_And_Treasures` DISABLE KEYS */;
INSERT INTO `Artifacts_And_Treasures` VALUES (1,'Ancient Egypt','1523-01-01',1),(2,'Atlantis','1666-06-06',2),(3,'Tibet','1888-08-08',3);
/*!40000 ALTER TABLE `Artifacts_And_Treasures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Curators`
--

DROP TABLE IF EXISTS `Curators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Curators` (
  `Category` varchar(255) NOT NULL,
  `Curator` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Category`),
  KEY `Curator` (`Curator`),
  CONSTRAINT `curators_ibfk_1` FOREIGN KEY (`Curator`) REFERENCES `Key_Illuminati_Members` (`Title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Curators`
--

LOCK TABLES `Curators` WRITE;
/*!40000 ALTER TABLE `Curators` DISABLE KEYS */;
INSERT INTO `Curators` VALUES ('Modern Conspiracies','La Eminence grise'),('Ancient Scripts','Nekhbet'),('Forbidden Sciences','Pythia');
/*!40000 ALTER TABLE `Curators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Faction_Meetings`
--

DROP TABLE IF EXISTS `Faction_Meetings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Faction_Meetings` (
  `Faction_Id` int NOT NULL,
  `Time` time NOT NULL,
  `Date` date NOT NULL,
  `Agenda` text,
  `Street` varchar(255) DEFAULT NULL,
  `City` varchar(255) DEFAULT NULL,
  `Country` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Faction_Id`,`Time`,`Date`),
  CONSTRAINT `faction_meetings_ibfk_1` FOREIGN KEY (`Faction_Id`) REFERENCES `Factions` (`Faction_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Faction_Meetings`
--

LOCK TABLES `Faction_Meetings` WRITE;
/*!40000 ALTER TABLE `Faction_Meetings` DISABLE KEYS */;
INSERT INTO `Faction_Meetings` VALUES (1,'14:00:00','2024-12-01','Financial Strategy Review','Secret Street 1','Geneva','Switzerland'),(2,'20:00:00','2024-12-15','Media Control Operation','Hidden Ave 2','London','UK'),(3,'10:00:00','2024-12-30','Political Influence Assessment','Shadow Road 3','Washington','USA');
/*!40000 ALTER TABLE `Faction_Meetings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Faction_Members`
--

DROP TABLE IF EXISTS `Faction_Members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Faction_Members` (
  `Member_Id` int NOT NULL,
  `Fname` varchar(255) DEFAULT NULL,
  `Mname` varchar(255) DEFAULT NULL,
  `Lname` varchar(255) DEFAULT NULL,
  `Dob` date DEFAULT NULL,
  `Faction_Id` int DEFAULT NULL,
  `Leader_Id` int DEFAULT NULL,
  PRIMARY KEY (`Member_Id`),
  KEY `Faction_Id` (`Faction_Id`),
  KEY `Leader_Id` (`Leader_Id`),
  CONSTRAINT `faction_members_ibfk_1` FOREIGN KEY (`Faction_Id`) REFERENCES `Factions` (`Faction_Id`),
  CONSTRAINT `faction_members_ibfk_2` FOREIGN KEY (`Leader_Id`) REFERENCES `Faction_Members` (`Member_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Faction_Members`
--

LOCK TABLES `Faction_Members` WRITE;
/*!40000 ALTER TABLE `Faction_Members` DISABLE KEYS */;
INSERT INTO `Faction_Members` VALUES (1,'Viktor',NULL,'Petrov','1975-03-15',1,NULL),(2,'Sarah','Jane','Williams','1982-07-21',1,1),(3,'James',NULL,'Chen','1979-11-30',1,1),(4,'Hassan',NULL,'Al-Rashid','1968-11-30',2,NULL),(5,'Ming',NULL,'Wei','1979-09-05',2,4),(6,'Elena','Maria','Garcia','1985-04-15',2,4),(7,'John',NULL,'Smith','1977-08-22',2,4),(8,'Alexandra',NULL,'Volkov','1973-12-10',3,NULL),(9,'Marcus','James','Brown','1980-06-25',3,8),(10,'Isabella',NULL,'Romano','1982-03-18',3,8),(11,'Alice',NULL,'Wunderkid','1990-05-05',1,3),(12,'Bob','the','Builder','1989-01-01',3,9),(13,'Peter',NULL,'Pan','1993-09-03',3,12);
/*!40000 ALTER TABLE `Faction_Members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Factions`
--

DROP TABLE IF EXISTS `Factions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Factions` (
  `Faction_Id` int NOT NULL,
  `Aim` text,
  `Symbol` varchar(255) DEFAULT NULL,
  `HeadTitle` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Faction_Id`),
  KEY `HeadTitle` (`HeadTitle`),
  CONSTRAINT `factions_ibfk_1` FOREIGN KEY (`HeadTitle`) REFERENCES `Key_Illuminati_Members` (`Title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Factions`
--

LOCK TABLES `Factions` WRITE;
/*!40000 ALTER TABLE `Factions` DISABLE KEYS */;
INSERT INTO `Factions` VALUES (1,'Global Financial Control','Golden Snake','Kubera'),(2,'Media Manipulation','All-Seeing Eye','Artemis'),(3,'Political Influence','Crown of Thorns','Corleone'),(4,'Scientific Advancement','Quantum Spiral','La Eminence grise'),(5,'Religious Control','Broken Cross','Pythia'),(6,'Military Operations','Iron Fist','Vali');
/*!40000 ALTER TABLE `Factions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Guards`
--

DROP TABLE IF EXISTS `Guards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Guards` (
  `Member_Id` int NOT NULL,
  `Artifact_Id` int NOT NULL,
  PRIMARY KEY (`Member_Id`,`Artifact_Id`),
  KEY `Artifact_Id` (`Artifact_Id`),
  CONSTRAINT `guards_ibfk_1` FOREIGN KEY (`Member_Id`) REFERENCES `Faction_Members` (`Member_Id`),
  CONSTRAINT `guards_ibfk_2` FOREIGN KEY (`Artifact_Id`) REFERENCES `Artifacts_And_Treasures` (`Artifact_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Guards`
--

LOCK TABLES `Guards` WRITE;
/*!40000 ALTER TABLE `Guards` DISABLE KEYS */;
INSERT INTO `Guards` VALUES (1,1),(2,2),(3,3);
/*!40000 ALTER TABLE `Guards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Individuals`
--

DROP TABLE IF EXISTS `Individuals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Individuals` (
  `Surveillance_Id` int NOT NULL,
  `Fname` varchar(255) DEFAULT NULL,
  `Mname` varchar(255) DEFAULT NULL,
  `Lname` varchar(255) DEFAULT NULL,
  `Current_Location` varchar(255) DEFAULT NULL,
  `Nationality` varchar(255) DEFAULT NULL,
  `Interests` text,
  `Past` text,
  `Citizenship_Identifier` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Surveillance_Id`),
  CONSTRAINT `individuals_ibfk_1` FOREIGN KEY (`Surveillance_Id`) REFERENCES `Surveillance` (`Surveillance_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Individuals`
--

LOCK TABLES `Individuals` WRITE;
/*!40000 ALTER TABLE `Individuals` DISABLE KEYS */;
INSERT INTO `Individuals` VALUES (1,'John',NULL,'Smith','New York','American','Quantum Computing','Former Intelligence Officer','US-123456'),(2,'Maria','Elena','Garcia','Madrid','Spanish','Biotechnology','Research Scientist','ESP-789012');
/*!40000 ALTER TABLE `Individuals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Key_Illuminati_Members`
--

DROP TABLE IF EXISTS `Key_Illuminati_Members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Key_Illuminati_Members` (
  `Name` varchar(255) DEFAULT NULL,
  `Title` varchar(255) NOT NULL,
  `Description_Of_Past` text,
  `Date_Of_Selling_Soul` date DEFAULT NULL,
  `ResidesIn` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Title`),
  KEY `key_illuminati_members_ibfk_1` (`ResidesIn`),
  CONSTRAINT `key_illuminati_members_ibfk_1` FOREIGN KEY (`ResidesIn`) REFERENCES `Sanctum_Sanctorum` (`Mantra`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Key_Illuminati_Members`
--

LOCK TABLES `Key_Illuminati_Members` WRITE;
/*!40000 ALTER TABLE `Key_Illuminati_Members` DISABLE KEYS */;
INSERT INTO `Key_Illuminati_Members` VALUES ('Meryl Streep','Artemis','Legendary infiltrator and master of disguise','1749-06-21','Ex Nihilo'),('Faltu Singh','Ashwathama','Immortal warrior and keeper of ancient weapons','1245-07-13','Carpe Noctem'),('PK','Corleone','Supreme commander of mortal influence','1923-11-11','Carpe Noctem'),(NULL,'Dementor','Half blood prince','1307-06-03','Memento Mori'),('Farshit Lalwani','Hanan','Bearer of divine light and cosmic wisdom','1777-07-07','Per Aspera'),('Dan Reynolds','Jove','Master of elements and natural forces','1901-03-17','Memento Mori'),('Dogé Musk','Kubera','Controller of global wealth and resources','1956-04-01','Ad Astra'),('FishFish Saraswat','La Eminence grise','Master of shadows and keeper of secrets','1523-03-15','Lux In Tenebris'),('Bhimapuram','Lucifer','Architect of chaos and master strategist','1666-06-06','Per Aspera'),('Dame Judy Trench','Nekhbet','Ancient guardian of forbidden knowledge','1652-12-01','Memento Mori'),('Beyoncé','Nuwa','Creator of illusions and keeper of harmony','1888-12-25','Ex Nihilo'),('Oprah','Pythia','Seer of futures and manipulator of destinies','1854-09-30','Ad Astra'),('Faizal Khan','Vali','Vengeance incarnate and master of retribution','1789-08-21','Lux In Tenebris');
/*!40000 ALTER TABLE `Key_Illuminati_Members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Orchestrates`
--

DROP TABLE IF EXISTS `Orchestrates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Orchestrates` (
  `Title` varchar(255) NOT NULL,
  `Event_Id` varchar(255) NOT NULL,
  `Faction_Id` int NOT NULL,
  `Name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Title`,`Event_Id`,`Faction_Id`),
  KEY `Event_Id` (`Event_Id`),
  KEY `Faction_Id` (`Faction_Id`),
  KEY `Name` (`Name`),
  CONSTRAINT `orchestrates_ibfk_1` FOREIGN KEY (`Title`) REFERENCES `Key_Illuminati_Members` (`Title`),
  CONSTRAINT `orchestrates_ibfk_2` FOREIGN KEY (`Event_Id`) REFERENCES `Sacred_Timeline_Events` (`Event_Id`),
  CONSTRAINT `orchestrates_ibfk_3` FOREIGN KEY (`Faction_Id`) REFERENCES `Factions` (`Faction_Id`),
  CONSTRAINT `orchestrates_ibfk_4` FOREIGN KEY (`Name`) REFERENCES `Organizations_Under_Control` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Orchestrates`
--

LOCK TABLES `Orchestrates` WRITE;
/*!40000 ALTER TABLE `Orchestrates` DISABLE KEYS */;
INSERT INTO `Orchestrates` VALUES ('Vali','EVT004',6,'Advanced Research Division'),('Corleone','EVT003',3,'Global Defense Initiative'),('Lucifer','EVT005',5,'Temple of Ultimate Truth'),('Artemis','EVT002',2,'United Media Corp'),('Kubera','EVT001',1,'World Bank');
/*!40000 ALTER TABLE `Orchestrates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Organizations`
--

DROP TABLE IF EXISTS `Organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Organizations` (
  `Surveillance_Id` int NOT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `Type` varchar(255) DEFAULT NULL,
  `President` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Surveillance_Id`),
  CONSTRAINT `organizations_ibfk_1` FOREIGN KEY (`Surveillance_Id`) REFERENCES `Surveillance` (`Surveillance_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Organizations`
--

LOCK TABLES `Organizations` WRITE;
/*!40000 ALTER TABLE `Organizations` DISABLE KEYS */;
INSERT INTO `Organizations` VALUES (3,'Tech Innovations Ltd','Corporate','James Wilson'),(4,'Global Peace Foundation','Government','Elena Rodriguez');
/*!40000 ALTER TABLE `Organizations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Organizations_Under_Control`
--

DROP TABLE IF EXISTS `Organizations_Under_Control`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Organizations_Under_Control` (
  `Name` varchar(255) NOT NULL,
  `Type` varchar(255) DEFAULT NULL,
  `Kind_Of_Control` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Organizations_Under_Control`
--

LOCK TABLES `Organizations_Under_Control` WRITE;
/*!40000 ALTER TABLE `Organizations_Under_Control` DISABLE KEYS */;
INSERT INTO `Organizations_Under_Control` VALUES ('Advanced Research Division','Corporate','Financial'),('Global Defense Initiative','Government','Political'),('Temple of Ultimate Truth','Religious','Informational'),('United Media Corp','Corporate','Informational'),('World Bank','Corporate','Financial');
/*!40000 ALTER TABLE `Organizations_Under_Control` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Perform_Rituals`
--

DROP TABLE IF EXISTS `Perform_Rituals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Perform_Rituals` (
  `Title` varchar(255) NOT NULL,
  `Mantra` varchar(50) NOT NULL,
  `Artifact_Id` int NOT NULL,
  PRIMARY KEY (`Title`,`Artifact_Id`,`Mantra`),
  KEY `Artifact_Id` (`Artifact_Id`),
  KEY `perform_rituals_ibfk_2` (`Mantra`),
  CONSTRAINT `perform_rituals_ibfk_1` FOREIGN KEY (`Title`) REFERENCES `Key_Illuminati_Members` (`Title`),
  CONSTRAINT `perform_rituals_ibfk_2` FOREIGN KEY (`Mantra`) REFERENCES `Sanctum_Sanctorum` (`Mantra`),
  CONSTRAINT `perform_rituals_ibfk_3` FOREIGN KEY (`Artifact_Id`) REFERENCES `Artifacts_And_Treasures` (`Artifact_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Perform_Rituals`
--

LOCK TABLES `Perform_Rituals` WRITE;
/*!40000 ALTER TABLE `Perform_Rituals` DISABLE KEYS */;
INSERT INTO `Perform_Rituals` VALUES ('La Eminence grise','Lux In Tenebris',1),('Pythia','Ex Nihilo',2),('Nekhbet','Memento Mori',3);
/*!40000 ALTER TABLE `Perform_Rituals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Powers`
--

DROP TABLE IF EXISTS `Powers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Powers` (
  `Artifact_Id` int NOT NULL,
  `Power` varchar(255) NOT NULL,
  PRIMARY KEY (`Artifact_Id`,`Power`),
  CONSTRAINT `powers_ibfk_1` FOREIGN KEY (`Artifact_Id`) REFERENCES `Artifacts_And_Treasures` (`Artifact_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Powers`
--

LOCK TABLES `Powers` WRITE;
/*!40000 ALTER TABLE `Powers` DISABLE KEYS */;
INSERT INTO `Powers` VALUES (1,'Prophecy'),(1,'Time Manipulation'),(2,'Mind Control'),(2,'Teleportation'),(3,'Reality Alteration'),(3,'Time Reversal');
/*!40000 ALTER TABLE `Powers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Sacred_Timeline_Events`
--

DROP TABLE IF EXISTS `Sacred_Timeline_Events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Sacred_Timeline_Events` (
  `Event_Id` varchar(255) NOT NULL,
  `Date` date DEFAULT NULL,
  `Time` time DEFAULT NULL,
  `Status` varchar(255) DEFAULT NULL,
  `Description` text,
  PRIMARY KEY (`Event_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Sacred_Timeline_Events`
--

LOCK TABLES `Sacred_Timeline_Events` WRITE;
/*!40000 ALTER TABLE `Sacred_Timeline_Events` DISABLE KEYS */;
INSERT INTO `Sacred_Timeline_Events` VALUES ('EVT001','2024-12-21','00:00:00','Planned','Global Financial Reset'),('EVT002','2024-10-31','15:30:00','In Progress','Media Blackout Operation'),('EVT003','2024-11-15','12:00:00','Executed','Political Regime Change'),('EVT004','2025-01-01','00:01:00','Planned','Technological Paradigm Shift'),('EVT005','2024-12-25','23:59:59','In Progress','Mass Consciousness Alteration');
/*!40000 ALTER TABLE `Sacred_Timeline_Events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Sanctum_Sanctorum`
--

DROP TABLE IF EXISTS `Sanctum_Sanctorum`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Sanctum_Sanctorum` (
  `Mantra` varchar(50) NOT NULL,
  `Street` varchar(255) DEFAULT NULL,
  `City` varchar(255) DEFAULT NULL,
  `Country` varchar(255) DEFAULT NULL,
  `Number_Of_Residents` int DEFAULT NULL,
  `History` text,
  PRIMARY KEY (`Mantra`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Sanctum_Sanctorum`
--

LOCK TABLES `Sanctum_Sanctorum` WRITE;
/*!40000 ALTER TABLE `Sanctum_Sanctorum` DISABLE KEYS */;
INSERT INTO `Sanctum_Sanctorum` VALUES ('Ad Astra','Older Delhi','Delhi','India',2,'Temple of cosmic knowledge'),('Carpe Noctem','Immortal Way','Alexandria','Egypt',2,'Ancient library of forbidden knowledge'),('Ex Nihilo','Mystic Avenue','Tibet','China',2,'Mountain temple of eternal wisdom'),('Lux In Tenebris','Shadow Lane','Venice','Italy',2,'Ancient palazzo hiding countless secrets'),('Memento Mori','CR Rao Road','Hyderabad','India',2,'Sacred chambers beneath holy ground'),('Per Aspera','Devils Quarter','Prague','Czech Republic',2,'Medieval stronghold of dark arts');
/*!40000 ALTER TABLE `Sanctum_Sanctorum` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Secret_Knowledge_Archives`
--

DROP TABLE IF EXISTS `Secret_Knowledge_Archives`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Secret_Knowledge_Archives` (
  `Archive_Id` varchar(255) NOT NULL,
  `Category` varchar(255) DEFAULT NULL,
  `Date_of_Last_Update` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Archive_Id`),
  KEY `Category` (`Category`),
  CONSTRAINT `secret_knowledge_archives_ibfk_1` FOREIGN KEY (`Category`) REFERENCES `Curators` (`Category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Secret_Knowledge_Archives`
--

LOCK TABLES `Secret_Knowledge_Archives` WRITE;
/*!40000 ALTER TABLE `Secret_Knowledge_Archives` DISABLE KEYS */;
INSERT INTO `Secret_Knowledge_Archives` VALUES ('ARC001','Ancient Scripts','2024-01-01'),('ARC002','Modern Conspiracies','2024-06-15'),('ARC003','Forbidden Sciences','2024-03-30');
/*!40000 ALTER TABLE `Secret_Knowledge_Archives` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Surveillance`
--

DROP TABLE IF EXISTS `Surveillance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Surveillance` (
  `Surveillance_Id` int NOT NULL,
  `Start_Date_Of_Survey` date DEFAULT NULL,
  PRIMARY KEY (`Surveillance_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Surveillance`
--

LOCK TABLES `Surveillance` WRITE;
/*!40000 ALTER TABLE `Surveillance` DISABLE KEYS */;
INSERT INTO `Surveillance` VALUES (1,'2024-01-01'),(2,'2024-02-15'),(3,'2024-03-30'),(4,'2024-04-15'),(5,'2024-05-01');
/*!40000 ALTER TABLE `Surveillance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Surveys`
--

DROP TABLE IF EXISTS `Surveys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Surveys` (
  `Surveillance_Id` int NOT NULL,
  `Title` varchar(255) NOT NULL,
  PRIMARY KEY (`Title`,`Surveillance_Id`),
  KEY `Surveillance_Id` (`Surveillance_Id`),
  CONSTRAINT `surveys_ibfk_1` FOREIGN KEY (`Surveillance_Id`) REFERENCES `Surveillance` (`Surveillance_Id`),
  CONSTRAINT `surveys_ibfk_2` FOREIGN KEY (`Title`) REFERENCES `Key_Illuminati_Members` (`Title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Surveys`
--

LOCK TABLES `Surveys` WRITE;
/*!40000 ALTER TABLE `Surveys` DISABLE KEYS */;
INSERT INTO `Surveys` VALUES (1,'La Eminence grise'),(2,'Artemis'),(3,'Pythia');
/*!40000 ALTER TABLE `Surveys` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-11-29 22:16:45
