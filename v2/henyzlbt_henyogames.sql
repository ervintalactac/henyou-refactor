-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 26, 2025 at 12:50 PM
-- Server version: 10.6.22-MariaDB-cll-lve-log
-- PHP Version: 8.3.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `henyzlbt_henyogames`
--

-- --------------------------------------------------------

--
-- Table structure for table `Gimme5Guesses`
--

CREATE TABLE `Gimme5Guesses` (
  `id` int(11) NOT NULL,
  `round` tinytext NOT NULL,
  `name` tinytext NOT NULL,
  `words` text NOT NULL,
  `attempts` mediumtext NOT NULL,
  `extradata` text NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `HenyoWords`
--

CREATE TABLE `HenyoWords` (
  `id` bigint(20) NOT NULL,
  `uploadDate` datetime NOT NULL,
  `wordsList` longtext NOT NULL,
  `dictionaryList` longtext NOT NULL,
  `multiplayerWordsList` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `JsonDictionary`
--

CREATE TABLE `JsonDictionary` (
  `id` int(11) NOT NULL,
  `dictionaryJson` longtext NOT NULL,
  `dictionaryDate` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `JsonGimme5Round1`
--

CREATE TABLE `JsonGimme5Round1` (
  `id` int(11) NOT NULL,
  `gimme5Round1Json` longtext NOT NULL,
  `gimme5Round1Date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `JsonMultiplayer`
--

CREATE TABLE `JsonMultiplayer` (
  `id` int(11) NOT NULL,
  `multiplayerJson` longtext NOT NULL,
  `multiplayerDate` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `JsonWords`
--

CREATE TABLE `JsonWords` (
  `id` int(11) NOT NULL,
  `wordsJson` longtext NOT NULL,
  `wordsDate` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `MultiPlayerGuesses`
--

CREATE TABLE `MultiPlayerGuesses` (
  `id` int(11) NOT NULL,
  `guesser` text NOT NULL,
  `cluegiver` text NOT NULL,
  `word` text NOT NULL,
  `attempts` mediumtext NOT NULL,
  `extradata` text NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `MultiPlayerRooms`
--

CREATE TABLE `MultiPlayerRooms` (
  `id` int(11) NOT NULL,
  `roomName` text NOT NULL,
  `guesser` text NOT NULL,
  `cluegiver` text NOT NULL,
  `status` text NOT NULL,
  `created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `NonceRecords`
--

CREATE TABLE `NonceRecords` (
  `id` bigint(20) NOT NULL,
  `nonce` tinytext NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `PartyModeGuesses`
--

CREATE TABLE `PartyModeGuesses` (
  `id` bigint(11) NOT NULL,
  `name` tinytext NOT NULL,
  `word` tinytext NOT NULL,
  `extraData` text NOT NULL,
  `attempts` text NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `RecordsBackup`
--

CREATE TABLE `RecordsBackup` (
  `id` int(11) NOT NULL,
  `name` tinytext NOT NULL,
  `email` text NOT NULL,
  `code` tinytext NOT NULL,
  `codeUsed` tinytext NOT NULL,
  `timeCreated` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `RecordsHenyo`
--

CREATE TABLE `RecordsHenyo` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `alias` varchar(255) NOT NULL,
  `score` bigint(20) NOT NULL,
  `totalScore` bigint(20) NOT NULL,
  `streak` bigint(20) NOT NULL,
  `totalStreak` bigint(20) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `extraData` longtext NOT NULL,
  `secureData` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- --------------------------------------------------------

--
-- Table structure for table `UserGuesses`
--

CREATE TABLE `UserGuesses` (
  `id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `word` varchar(255) NOT NULL,
  `attempts` mediumtext NOT NULL,
  `extraData` text NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- --------------------------------------------------------

--
-- Table structure for table `WeeklyRecords`
--

CREATE TABLE `WeeklyRecords` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `alias` tinytext NOT NULL,
  `score` smallint(6) NOT NULL,
  `streak` smallint(6) NOT NULL,
  `weekNumber` smallint(6) NOT NULL,
  `awardPaid` tinyint(1) NOT NULL,
  `awardAmount` smallint(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='weekly user score records';

-- --------------------------------------------------------

--
-- Table structure for table `WeeklyWinners`
--

CREATE TABLE `WeeklyWinners` (
  `id` int(11) NOT NULL,
  `weekNumber` smallint(6) NOT NULL,
  `firstPlace` text NOT NULL,
  `secondPlace` text NOT NULL,
  `thirdPlace` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Gimme5Guesses`
--
ALTER TABLE `Gimme5Guesses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `HenyoWords`
--
ALTER TABLE `HenyoWords`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `JsonDictionary`
--
ALTER TABLE `JsonDictionary`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `JsonGimme5Round1`
--
ALTER TABLE `JsonGimme5Round1`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `JsonMultiplayer`
--
ALTER TABLE `JsonMultiplayer`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `JsonWords`
--
ALTER TABLE `JsonWords`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `MultiPlayerGuesses`
--
ALTER TABLE `MultiPlayerGuesses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `MultiPlayerRooms`
--
ALTER TABLE `MultiPlayerRooms`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `NonceRecords`
--
ALTER TABLE `NonceRecords`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `PartyModeGuesses`
--
ALTER TABLE `PartyModeGuesses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `RecordsBackup`
--
ALTER TABLE `RecordsBackup`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `RecordsHenyo`
--
ALTER TABLE `RecordsHenyo`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `UserGuesses`
--
ALTER TABLE `UserGuesses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `WeeklyRecords`
--
ALTER TABLE `WeeklyRecords`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `WeeklyWinners`
--
ALTER TABLE `WeeklyWinners`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Gimme5Guesses`
--
ALTER TABLE `Gimme5Guesses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `HenyoWords`
--
ALTER TABLE `HenyoWords`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `JsonDictionary`
--
ALTER TABLE `JsonDictionary`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `JsonGimme5Round1`
--
ALTER TABLE `JsonGimme5Round1`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `JsonMultiplayer`
--
ALTER TABLE `JsonMultiplayer`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `JsonWords`
--
ALTER TABLE `JsonWords`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `MultiPlayerGuesses`
--
ALTER TABLE `MultiPlayerGuesses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `MultiPlayerRooms`
--
ALTER TABLE `MultiPlayerRooms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `NonceRecords`
--
ALTER TABLE `NonceRecords`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `PartyModeGuesses`
--
ALTER TABLE `PartyModeGuesses`
  MODIFY `id` bigint(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `RecordsBackup`
--
ALTER TABLE `RecordsBackup`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `RecordsHenyo`
--
ALTER TABLE `RecordsHenyo`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `UserGuesses`
--
ALTER TABLE `UserGuesses`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `WeeklyRecords`
--
ALTER TABLE `WeeklyRecords`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `WeeklyWinners`
--
ALTER TABLE `WeeklyWinners`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
