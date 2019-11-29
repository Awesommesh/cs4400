CREATE DATABASE  IF NOT EXISTS `team73` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `team73`;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;



DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `username` varchar(50) NOT NULL,
  PRIMARY KEY (`username`),
  KEY `admin_username_idx` (`username`),
  CONSTRAINT `admin_usernameFK3` FOREIGN KEY (`username`) REFERENCES `employee` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES ('cool_class4400');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;



DROP TABLE IF EXISTS `company`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company` (
  `comName` varchar(50) NOT NULL,
  PRIMARY KEY (`comName`),
  UNIQUE KEY `comName` (`comName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `company` WRITE;
/*!40000 ALTER TABLE `company` DISABLE KEYS */;
INSERT INTO `company` VALUES ('4400 Theater Company'),('AI Theater Company'),('Awesome Theater Company'),('EZ Theater Company');
/*!40000 ALTER TABLE `company` ENABLE KEYS */;
UNLOCK TABLES;



DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `username` varchar(50) NOT NULL,
  PRIMARY KEY (`username`),
  CONSTRAINT `customer_username` FOREIGN KEY (`username`) REFERENCES `user` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES ('calcultron'),('calcultron2'),('calcwizard'),('clarinetbeast'),('cool_class4400'),('DNAhelix'),('does2Much'),('eeqmcsquare'),('entropyRox'),('fullMetal'),('georgep'),('ilikemoney$$'),('imready'),('isthisthekrustykrab'),('notFullMetal'),('programerAAL'),('RitzLover28'),('thePiGuy3.14'),('theScienceGuy');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;



DROP TABLE IF EXISTS `customercreditcard`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customercreditcard` (
  `username` varchar(50) NOT NULL,
  `creditCardNum` char(16) NOT NULL,
  PRIMARY KEY (`creditCardNum`),
  UNIQUE KEY `creditCardNum_UNIQUE` (`creditCardNum`),
  KEY `customercreditcard_ibfk_1_idx` (`username`),
  CONSTRAINT `customercreditcard_ibfk_1` FOREIGN KEY (`username`) REFERENCES `customer` (`username`),
  CHECK(LENGTH(`creditCardNum`) = 16)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `customercreditcard` WRITE;
/*!40000 ALTER TABLE `customercreditcard` DISABLE KEYS */;
INSERT INTO `customercreditcard` VALUES ('calcultron','1111111111000000'),('calcultron2','1111111100000000'),('calcultron2','1111111110000000'),('calcwizard','1111111111100000'),('cool_class4400','2222222222000000'),('DNAhelix','2220000000000000'),('does2Much','2222222200000000'),('eeqmcsquare','2222222222222200'),('entropyRox','2222222222200000'),('entropyRox','2222222222220000'),('fullMetal','1100000000000000'),('georgep','1111111111110000'),('georgep','1111111111111000'),('georgep','1111111111111100'),('georgep','1111111111111110'),('georgep','1111111111111111'),('ilikemoney$$','2222222222222220'),('ilikemoney$$','2222222222222222'),('ilikemoney$$','9000000000000000'),('imready','1111110000000000'),('isthisthekrustykrab','1110000000000000'),('isthisthekrustykrab','1111000000000000'),('isthisthekrustykrab','1111100000000000'),('notFullMetal','1000000000000000'),('programerAAL','2222222000000000'),('RitzLover28','3333333333333300'),('thePiGuy3.14','2222222220000000'),('theScienceGuy','2222222222222000');
/*!40000 ALTER TABLE `customercreditcard` ENABLE KEYS */;
UNLOCK TABLES;



DROP TABLE IF EXISTS `customerviewmovie`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customerviewmovie` (
  `movName` varchar(50) NOT NULL,
  `movReleaseDate` date NOT NULL,
  `movPlayDate` date NOT NULL,
  `thName` varchar(50) NOT NULL,
  `comName` varchar(50) NOT NULL,
  `creditCardNum` char(16) NOT NULL,
  PRIMARY KEY (`movName`,`movReleaseDate`,`movPlayDate`,`thName`,`comName`,`creditCardNum`),
  KEY `customerviewmovie_creditcard_idx` (`creditCardNum`),
  KEY `customerviewmovie_MoviePlay_idx` (`movName`,`thName`,`comName`),
  KEY `customerviewmovie_movieplay` (`thName`,`comName`),
  CONSTRAINT `customerviewmovie_MoviePlay` FOREIGN KEY (`movName`, `movReleaseDate`, `movPlayDate`, `thName`, `comName`) REFERENCES `movieplay` (`movName`, `movReleaseDate`, `movPlayDate`, `thName`, `comName`),
  CONSTRAINT `customerviewmovie_creditcard` FOREIGN KEY (`creditCardNum`) REFERENCES `customercreditcard` (`creditCardNum`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `customerviewmovie` WRITE;
/*!40000 ALTER TABLE `customerviewmovie` DISABLE KEYS */;
INSERT INTO `customerviewmovie` VALUES ('How to Train Your Dragon','2010-03-21','2010-03-25','Star Movies','EZ Theater Company','1111111111111100'),('How to Train Your Dragon','2010-03-21','2010-03-22','Main Movies','EZ Theater Company','1111111111111111'),('How to Train Your Dragon','2010-03-21','2010-03-23','Main Movies','EZ Theater Company','1111111111111111'),('How to Train Your Dragon','2010-03-21','2010-04-02','Cinema Star','4400 Theater Company','1111111111111111');
/*!40000 ALTER TABLE `customerviewmovie` ENABLE KEYS */;
UNLOCK TABLES;



DROP TABLE IF EXISTS `employee`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee` (
  `username` varchar(50) NOT NULL,
  PRIMARY KEY (`username`),
  UNIQUE KEY `username` (`username`),
  CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`username`) REFERENCES `user` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `employee` WRITE;
/*!40000 ALTER TABLE `employee` DISABLE KEYS */;
INSERT INTO `employee` VALUES ('calcultron'),('cool_class4400'),('entropyRox'),('fatherAI'),('georgep'),('ghcghc'),('imbatman'),('manager1'),('manager2'),('manager3'),('manager4'),('radioactivePoRa');
/*!40000 ALTER TABLE `employee` ENABLE KEYS */;
UNLOCK TABLES;



DROP TABLE IF EXISTS `manager`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manager` (
  `username` varchar(50) NOT NULL,
  `comName` varchar(50) NOT NULL,
  `manStreet` varchar(50) NOT NULL,
  `manCity` varchar(50) NOT NULL,
  `manState` char(2) NOT NULL,
  `manZipcode` char(5) NOT NULL,
  PRIMARY KEY (`username`),
  KEY `manager_company_idx` (`comName`),
  CONSTRAINT `manager_company` FOREIGN KEY (`comName`) REFERENCES `company` (`comName`),
  CONSTRAINT `manager_username` FOREIGN KEY (`username`) REFERENCES `employee` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `manager` WRITE;
/*!40000 ALTER TABLE `manager` DISABLE KEYS */;
INSERT INTO `manager` VALUES ('calcultron','EZ Theater Company','123 Peachtree St','Atlanta','GA','30308'),('entropyRox','4400 Theater Company','200 Cool Place','San Francisco','CA','94016'),('fatherAI','EZ Theater Company','456 Main St','New York','NY','10001'),('georgep','4400 Theater Company','10 Pearl Dr','Seattle','WA','98105'),('ghcghc','AI Theater Company','100 Pi St','Pallet Town','KS','31415'),('imbatman','Awesome Theater Company','800 Color Dr','Austin','TX','78653'),('manager1','4400 Theater Company','123 Ferst Drive','Atlanta','GA','30332'),('manager2','AI Theater Company','456 Ferst Drive','Atlanta','GA','30332'),('manager3','4400 Theater Company','789 Ferst Drive','Atlanta','GA','30332'),('manager4','4400 Theater Company','000 Ferst Drive','Atlanta','GA','30332'),('radioactivePoRa','4400 Theater Company','100 Blu St','Sunnyvale','CA','94088');
/*!40000 ALTER TABLE `manager` ENABLE KEYS */;
UNLOCK TABLES;



DROP TABLE IF EXISTS `movie`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movie` (
  `movName` varchar(50) NOT NULL,
  `movReleaseDate` date NOT NULL,
  `duration` int(11) NOT NULL,
  PRIMARY KEY (`movReleaseDate`,`movName`),
  UNIQUE KEY `movName` (`movName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `movie` WRITE;
/*!40000 ALTER TABLE `movie` DISABLE KEYS */;
INSERT INTO `movie` VALUES ('George P Burdell\'s Life Story','1927-08-12',100),('Georgia Tech The Movie','1985-08-13',100),('Spaceballs','1987-06-24',96),('The First Pokemon Movie','1998-07-19',75),('How to Train Your Dragon','2010-03-21',98),('The King\'s Speech','2010-11-26',119),('Spider-Man: Into the Spider-Verse','2018-12-01',117),('Avengers: Endgame','2019-04-26',181),('4400 The Movie','2019-08-12',130),('Calculus Returns: A ML Story','2019-09-19',314);
/*!40000 ALTER TABLE `movie` ENABLE KEYS */;
UNLOCK TABLES;



DROP TABLE IF EXISTS `movieplay`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movieplay` (
  `movName` varchar(50) NOT NULL,
  `movReleaseDate` date NOT NULL,
  `movPlayDate` date NOT NULL,
  `thName` varchar(50) NOT NULL,
  `comName` varchar(50) NOT NULL,
  PRIMARY KEY (`movName`,`movReleaseDate`,`movPlayDate`,`thName`,`comName`),
  KEY `movieplay_ibfk_1` (`thName`,`comName`),
  KEY `movieplay_ibfk_2` (`movReleaseDate`,`movName`),
  CONSTRAINT `movieplay_ibfk_1` FOREIGN KEY (`thName`, `comName`) REFERENCES `theater` (`thName`, `comName`),
  CONSTRAINT `movieplay_ibfk_2` FOREIGN KEY (`movReleaseDate`, `movName`) REFERENCES `movie` (`movReleaseDate`, `movName`),
  CHECK(`movReleaseDate` <= `movPlayDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `movieplay` WRITE;
/*!40000 ALTER TABLE `movieplay` DISABLE KEYS */;
INSERT INTO `movieplay` VALUES ('George P Burdell\'s Life Story','1927-08-12','2010-05-20','Cinema Star','4400 Theater Company'),('George P Burdell\'s Life Story','1927-08-12','2019-07-14','Main Movies','EZ Theater Company'),('George P Burdell\'s Life Story','1927-08-12','2019-10-22','Main Movies','EZ Theater Company'),('Georgia Tech The Movie','1985-08-13','1985-08-13','ABC Theater','Awesome Theater Company'),('Georgia Tech The Movie','1985-08-13','2019-09-30','Cinema Star','4400 Theater Company'),('Spaceballs','1987-06-24','1999-06-24','Main Movies','EZ Theater Company'),('Spaceballs','1987-06-24','2000-02-02','Cinema Star','4400 Theater Company'),('Spaceballs','1987-06-24','2010-04-02','ML Movies','AI Theater Company'),('Spaceballs','1987-06-24','2023-01-23','ML Movies','AI Theater Company'),('The First Pokemon Movie','1998-07-19','2018-07-19','ABC Theater','Awesome Theater Company'),('How to Train Your Dragon','2010-03-21','2010-03-22','Main Movies','EZ Theater Company'),('How to Train Your Dragon','2010-03-21','2010-03-23','Main Movies','EZ Theater Company'),('How to Train Your Dragon','2010-03-21','2010-03-25','Star Movies','EZ Theater Company'),('How to Train Your Dragon','2010-03-21','2010-04-02','Cinema Star','4400 Theater Company'),('The King\'s Speech','2010-11-26','2019-12-20','Cinema Star','4400 Theater Company'),('The King\'s Speech','2010-11-26','2019-12-20','Main Movies','EZ Theater Company'),('Spider-Man: Into the Spider-Verse','2018-12-01','2019-09-30','ML Movies','AI Theater Company'),('4400 The Movie','2019-08-12','2019-08-12','Star Movies','EZ Theater Company'),('4400 The Movie','2019-08-12','2019-09-12','Cinema Star','4400 Theater Company'),('4400 The Movie','2019-08-12','2019-10-12','ABC Theater','Awesome Theater Company'),('Calculus Returns: A ML Story','2019-09-19','2019-10-10','ML Movies','AI Theater Company'),('Calculus Returns: A ML Story','2019-09-19','2019-12-30','ML Movies','AI Theater Company');
/*!40000 ALTER TABLE `movieplay` ENABLE KEYS */;
UNLOCK TABLES;



DROP TABLE IF EXISTS `theater`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `theater` (
  `comName` varchar(50) NOT NULL,
  `thName` varchar(50) NOT NULL,
  `capacity` int(4) NOT NULL,
  `thStreet` varchar(50) NOT NULL,
  `thCity` varchar(50) NOT NULL,
  `thState` char(2) NOT NULL,
  `thZipcode` char(5) NOT NULL,
  `manUsername` varchar(50) NOT NULL,
  PRIMARY KEY (`thName`,`comName`),
  KEY `comName` (`comName`),
  KEY `theater_manusername_idx` (`manUsername`),
  CONSTRAINT `theater_comName` FOREIGN KEY (`comName`) REFERENCES `company` (`comName`),
  CONSTRAINT `theater_managerusername` FOREIGN KEY (`manUsername`) REFERENCES `manager` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `theater` WRITE;
/*!40000 ALTER TABLE `theater` DISABLE KEYS */;
INSERT INTO `theater` VALUES ('Awesome Theater Company','ABC Theater',5,'880 Color Dr','Austin','TX','73301','imbatman'),('4400 Theater Company','Cinema Star',4,'100 Cool Place','San Francisco','CA','94016','entropyRox'),('4400 Theater Company','Jonathan\'s Movies',2,'67 Pearl Dr','Seattle','WA','98101','georgep'),('EZ Theater Company','Main Movies',3,'123 Main St','New York','NY','10001','fatherAI'),('AI Theater Company','ML Movies',3,'314 Pi St','Pallet Town','KS','31415','ghcghc'),('4400 Theater Company','Star Movies',5,'4400 Rocks Ave','Boulder','CA','80301','radioactivePoRa'),('EZ Theater Company','Star Movies',2,'745 GT St','Atlanta','GA','30332','calcultron');
/*!40000 ALTER TABLE `theater` ENABLE KEYS */;
UNLOCK TABLES;



DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `username` varchar(50) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'Pending',
  `password` varchar(50) NOT NULL,
  `firstname` varchar(50) NOT NULL,
  `lastname` varchar(50) NOT NULL,
  PRIMARY KEY (`username`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES ('calcultron','Approved','77c9749b451ab8c713c48037ddfbb2c4','Dwight','Schrute'),('calcultron2','Approved','8792b8cf71d27dc96173b2ac79b96e0d','Jim','Halpert'),('calcwizard','Approved','0d777e9e30b918e9034ab610712c90cf','Issac','Newton'),('clarinetbeast','Declined','c8c605999f3d8352d7bb792cf3fdb25b','Squidward','Tentacles'),('cool_class4400','Approved','77c9749b451ab8c713c48037ddfbb2c4','A. TA','Washere'),('DNAhelix','Approved','ca94efe2a58c27168edf3d35102dbb6d','Rosalind','Franklin'),('does2Much','Approved','00cedcf91beffa9ee69f6cfe23a4602d','Carl','Gauss'),('eeqmcsquare','Approved','7c5858f7fcf63ec268f42565be3abb95','Albert','Einstein'),('entropyRox','Approved','c8c605999f3d8352d7bb792cf3fdb25b','Claude','Shannon'),('fatherAI','Approved','0d777e9e30b918e9034ab610712c90cf','Alan','Turing'),('fullMetal','Approved','d009d70ae4164e8989725e828db8c7c2','Edward','Elric'),('gdanger','Declined','3665a76e271ada5a75368b99f774e404','Gary','Danger'),('georgep','Approved','bbb8aae57c104cda40c93843ad5e6db8','George P.','Burdell'),('ghcghc','Approved','9f0863dd5f0256b0f586a7b523f8cfe8','Grace','Hopper'),('ilikemoney$$','Approved','7c5858f7fcf63ec268f42565be3abb95','Eugene','Krabs'),('imbatman','Approved','9f0863dd5f0256b0f586a7b523f8cfe8','Bruce','Wayne'),('imready','Approved','ca94efe2a58c27168edf3d35102dbb6d','Spongebob','Squarepants'),('isthisthekrustykrab','Approved','134fb0bf3bdd54ee9098f4cbc4351b9a','Patrick','Star'),('manager1','Approved','e58cce4fab03d2aea056398750dee16b','Manager','One'),('manager2','Approved','ba9485f02fc98cdbd2edadb0aa8f6390','Manager','Two'),('manager3','Approved','6e4fb18b49aa3219bef65195dac7be8c','Three','Three'),('manager4','Approved','d61dfee83aa2a6f9e32f268d60e789f5','Four','Four'),('notFullMetal','Approved','d009d70ae4164e8989725e828db8c7c2','Alphonse','Elric'),('programerAAL','Approved','ba9485f02fc98cdbd2edadb0aa8f6390','Ada','Lovelace'),('radioactivePoRa','Approved','e5d4b739db1226088177e6f8b70c3a6f','Marie','Curie'),('RitzLover28','Approved','8792b8cf71d27dc96173b2ac79b96e0d','Abby','Normal'),('smith_j','Pending','77c9749b451ab8c713c48037ddfbb2c4','John','Smith'),('texasStarKarate','Declined','7c5858f7fcf63ec268f42565be3abb95','Sandy','Cheeks'),('thePiGuy3.14','Approved','e11170b8cbd2d74102651cb967fa28e5','Archimedes','Syracuse'),('theScienceGuy','Approved','c8c605999f3d8352d7bb792cf3fdb25b','Bill','Nye');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;



DROP TABLE IF EXISTS `uservisittheater`;
/*!40101 SET @saved_cs_client = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `uservisittheater` (
  `visitID` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `thName` varchar(50) NOT NULL,
  `comName` varchar(50) NOT NULL,
  `visitDate` date NOT NULL,
  PRIMARY KEY (`visitID`),
  UNIQUE KEY `visitID` (`visitID`),
  KEY `thName` (`thName`,`comName`),
  KEY `uservisittheater_ibfk_1` (`username`),
  CONSTRAINT `uservisittheater_ibfk_1` FOREIGN KEY (`username`) REFERENCES `user` (`username`),
  CONSTRAINT `uservisittheater_ibfk_2` FOREIGN KEY (`thName`, `comName`) REFERENCES `theater` (`thName`, `comName`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `uservisittheater` WRITE;
/*!40000 ALTER TABLE `uservisittheater` DISABLE KEYS */;
INSERT INTO `uservisittheater` VALUES (1,'georgep','Main Movies','EZ Theater Company','2010-03-22'),(2,'calcwizard','Main Movies','EZ Theater Company','2010-03-22'),(3,'calcwizard','Star Movies','EZ Theater Company','2010-03-25'),(4,'imready','Star Movies','EZ Theater Company','2010-03-25'),(5,'calcwizard','ML Movies','AI Theater Company','2010-03-20');
/*!40000 ALTER TABLE `uservisittheater` ENABLE KEYS */;
UNLOCK TABLES;



/*!50003 DROP PROCEDURE IF EXISTS `user_filter_th` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `user_filter_th`(IN i_thName VARCHAR(50), IN i_comName VARCHAR(50), IN i_city VARCHAR(50), IN i_state VARCHAR(3))
BEGIN
    DROP TABLE IF EXISTS UserFilterTh;
    CREATE TABLE UserFilterTh
	SELECT thName, thStreet, thCity, thState, thZipcode, comName
    FROM Theater
    WHERE
		(thName = i_thName OR i_thName = "ALL") AND
        (comName = i_comName OR i_comName = "ALL") AND
        (thCity = i_city OR i_city = "") AND
        (thState = i_state OR i_state = "ALL");
END ;;
DELIMITER ;

/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `user_filter_visitHistory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `user_filter_visitHistory`(IN i_username VARCHAR(50), IN i_minVisitDate DATE, IN i_maxVisitDate DATE)
BEGIN
    DROP TABLE IF EXISTS UserVisitHistory;
    CREATE TABLE UserVisitHistory
	SELECT thName, thStreet, thCity, thState, thZipcode, comName, visitDate
    FROM UserVisitTheater
		NATURAL JOIN
        Theater
	WHERE
		(username = i_username) AND
        (i_minVisitDate IS NULL OR visitDate >= i_minVisitDate) AND
        (i_maxVisitDate IS NULL OR visitDate <= i_maxVisitDate);
END ;;
DELIMITER ;

/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `user_register` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `user_register`(IN i_username VARCHAR(50), IN i_password VARCHAR(50), IN i_firstname VARCHAR(50), IN i_lastname VARCHAR(50))
BEGIN
		INSERT INTO user (username, password, firstname, lastname) VALUES (i_username, MD5(i_password), i_firstname, i_lastname);
END ;;
DELIMITER ;

/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `user_visit_th` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `user_visit_th`(IN i_thName VARCHAR(50), IN i_comName VARCHAR(50), IN i_visitDate DATE, IN i_username VARCHAR(50))
BEGIN
    INSERT INTO UserVisitTheater (thName, comName, visitDate, username)
    VALUES (i_thName, i_comName, i_visitDate, i_username);
END ;;
DELIMITER ;

/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
