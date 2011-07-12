-- MySQL dump 10.13  Distrib 5.1.54, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: flattendb_temp_1310038141_10671
-- ------------------------------------------------------
-- Server version	5.1.54-1ubuntu4

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
-- Table structure for table `attr1`
--

DROP TABLE IF EXISTS `attr1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attr1` (
  `ObjID` int(11) NOT NULL,
  `attr1ID` int(11) NOT NULL,
  `Val` int(11) NOT NULL,
  PRIMARY KEY (`attr1ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attr1`
--

LOCK TABLES `attr1` WRITE;
/*!40000 ALTER TABLE `attr1` DISABLE KEYS */;
INSERT INTO `attr1` VALUES (1,1,3),(2,2,2),(3,3,1);
/*!40000 ALTER TABLE `attr1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attr2`
--

DROP TABLE IF EXISTS `attr2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attr2` (
  `ObjID` int(11) NOT NULL,
  `attr2ID` int(11) NOT NULL,
  `Val` int(11) NOT NULL,
  PRIMARY KEY (`attr2ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attr2`
--

LOCK TABLES `attr2` WRITE;
/*!40000 ALTER TABLE `attr2` DISABLE KEYS */;
INSERT INTO `attr2` VALUES (1,3,4),(2,2,5),(3,1,6);
/*!40000 ALTER TABLE `attr2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attr3`
--

DROP TABLE IF EXISTS `attr3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attr3` (
  `attr3ID` int(11) NOT NULL,
  `Val` int(11) NOT NULL,
  PRIMARY KEY (`attr3ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attr3`
--

LOCK TABLES `attr3` WRITE;
/*!40000 ALTER TABLE `attr3` DISABLE KEYS */;
INSERT INTO `attr3` VALUES (1,0),(2,8),(3,7);
/*!40000 ALTER TABLE `attr3` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attr4`
--

DROP TABLE IF EXISTS `attr4`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attr4` (
  `attr4ID` int(11) NOT NULL,
  `Val` int(11) NOT NULL,
  PRIMARY KEY (`attr4ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attr4`
--

LOCK TABLES `attr4` WRITE;
/*!40000 ALTER TABLE `attr4` DISABLE KEYS */;
INSERT INTO `attr4` VALUES (1,0),(2,0),(3,9);
/*!40000 ALTER TABLE `attr4` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `barobject`
--

DROP TABLE IF EXISTS `barobject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `barobject` (
  `ObjID` int(11) NOT NULL,
  `attr4ID` int(11) NOT NULL,
  `Bar` int(11) NOT NULL,
  PRIMARY KEY (`ObjID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `barobject`
--

LOCK TABLES `barobject` WRITE;
/*!40000 ALTER TABLE `barobject` DISABLE KEYS */;
INSERT INTO `barobject` VALUES (1,2,1002),(2,1,1200),(3,3,1000);
/*!40000 ALTER TABLE `barobject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fooobject`
--

DROP TABLE IF EXISTS `fooobject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fooobject` (
  `ObjID` int(11) NOT NULL,
  `attr1ID` int(11) NOT NULL,
  `attr3ID` int(11) NOT NULL,
  `Foo` int(11) NOT NULL,
  PRIMARY KEY (`ObjID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fooobject`
--

LOCK TABLES `fooobject` WRITE;
/*!40000 ALTER TABLE `fooobject` DISABLE KEYS */;
INSERT INTO `fooobject` VALUES (1,1,2,112),(2,2,1,122);
INSERT INTO `fooobject` VALUES (3,3,3,111);
/*!40000 ALTER TABLE `fooobject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object`
--

DROP TABLE IF EXISTS `object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `object` (
  `ObjID` int(11) NOT NULL,
  `Bla` int(11) NOT NULL,
  `Blub` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ObjID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object`
--

LOCK TABLES `object` WRITE;
/*!40000 ALTER TABLE `object` DISABLE KEYS */;
INSERT INTO `object` VALUES (1,12,NULL),(2,12,'h),(i'),(30,1,'h\'o');
/*!40000 ALTER TABLE `object` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-07-07 13:31:05
