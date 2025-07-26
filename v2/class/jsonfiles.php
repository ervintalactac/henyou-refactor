<?php
    class JsonWords{

        // Connection
        private $conn;

        // Table
        private $db_table = "JsonWords";

        // Columns
        public $id;
        public $wordsJson;
        public $wordsDate;
        
        // Db connection
        public function __construct($db){
            $this->conn = $db;
        }

        // CREATE
        public function createJsonWords(){
        
            $sqlQuery = "INSERT INTO
                        ". $this->db_table ."
                    SET
                        uploadDate = :uploadDate, 
                        wordsList = :wordsList, 
                        dictionaryList = :dictionaryList";
                        
            $stmt = $this->conn->prepare($sqlQuery);

            // sanitize and bind data
            $stmt->bindParam(":uploadDate", $this->uploadDate);
            $stmt->bindParam(":wordsList", $this->wordsList);
            $stmt->bindParam(":dictionaryList", $this->dictionaryList);

            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        public function getJsonWords(){
            
            $sqlQuery = "SELECT * FROM ". $this->db_table ." ORDER BY id DESC LIMIT 1";
            
            $stmt = $this->conn->prepare($sqlQuery);
            if($stmt->execute()){
                $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
               
                $this->id = $dataRow['id']; 
                $this->wordsJson = $dataRow['wordsJson'];
                $this->wordsDate = $dataRow['wordsDate'];
                return true;
            }else{
                return false;
            }
        }
        
        public function getLatestJsonWordsDate(){
            
            $sqlQuery = "SELECT id, wordsDate FROM ". $this->db_table ." ORDER BY id DESC LIMIT 1";
            
            $stmt = $this->conn->prepare($sqlQuery);
            if($stmt->execute()){
                $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
               
                $this->id = $dataRow['id']; 
                $this->wordsDate = $dataRow['wordsDate'];
                return true;
            
            }else{
                return false;
            }
        }
    }
    
    class JsonMultiplayer{

        // Connection
        private $conn;

        // Table
        private $db_table = "JsonMultiplayer";

        // Columns
        public $id;
        public $multiplayerJson;
        public $multiplayerDate;
        
        // Db connection
        public function __construct($db){
            $this->conn = $db;
        }

        // CREATE
        public function createJsonMultiplayer(){
        
            $sqlQuery = "INSERT INTO
                        ". $this->db_table ."
                    SET
                        multiplayerDate = :multiplayerDate, 
                        multiplayerJson = :multiplayerJson";
                        
            $stmt = $this->conn->prepare($sqlQuery);

            // sanitize and bind data
            $stmt->bindParam(":multiplayerDate", $this->multiplayerDate);
            $stmt->bindParam(":multiplayerJson", $this->multiplayerJson);
            
            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        public function getJsonMultiplayer(){
            
            $sqlQuery = "SELECT * FROM ". $this->db_table ." ORDER BY id DESC LIMIT 1";
            
            $stmt = $this->conn->prepare($sqlQuery);
            if($stmt->execute()){
                $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
               
                $this->id = $dataRow['id']; 
                $this->multiplayerJson = $dataRow['multiplayerJson'];
                $this->multiplayerDate = $dataRow['multiplayerDate'];
                return true;
            }else{
                return false;
            }
        }
        
        public function getLatestJsonMultiplayerDate(){
            
            $sqlQuery = "SELECT id, multiplayerDate FROM ". $this->db_table ." ORDER BY id DESC LIMIT 1";
            
            $stmt = $this->conn->prepare($sqlQuery);
            if($stmt->execute()){
                $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
               
                $this->id = $dataRow['id']; 
                $this->multiplayerDate = $dataRow['multiplayerDate'];
                return true;
            
            }else{
                return false;
            }
        }
    }
    
    class JsonGimme5Round1{

        // Connection
        private $conn;

        // Table
        private $db_table = "JsonGimme5Round1";

        // Columns
        public $id;
        public $gimme5Round1Json;
        public $gimme5Round1Date;
        
        // Db connection
        public function __construct($db){
            $this->conn = $db;
        }

        // CREATE
        public function createJsonGimme5Round1(){
        
            $sqlQuery = "INSERT INTO
                        ". $this->db_table ."
                    SET
                        gimme5Round1Date = :gimme5Round1Date, 
                        gimme5Round1Json = :gimme5Round1Json";
                        
            $stmt = $this->conn->prepare($sqlQuery);

            // sanitize and bind data
            $stmt->bindParam(":gimme5Round1Date", $this->gimme5Round1Date);
            $stmt->bindParam(":gimme5Round1Json", $this->gimme5Round1Json);

            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        public function getJsonGimme5Round1(){
            
            $sqlQuery = "SELECT * FROM ". $this->db_table ." ORDER BY id DESC LIMIT 1";
            
            $stmt = $this->conn->prepare($sqlQuery);
            if($stmt->execute()){
                $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
               
                $this->id = $dataRow['id']; 
                $this->gimme5Round1Json = $dataRow['gimme5Round1Json'];
                $this->gimme5Round1Date = $dataRow['gimme5Round1Date'];
                return true;
            }else{
                return false;
            }
        }
        
        public function getLatestJsonGimme5Round1Date(){
            
            $sqlQuery = "SELECT id, gimme5Round1Date FROM ". $this->db_table ." ORDER BY id DESC LIMIT 1";
            
            $stmt = $this->conn->prepare($sqlQuery);
            if($stmt->execute()){
                $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
               
                $this->id = $dataRow['id']; 
                $this->gimme5Round1Date = $dataRow['gimme5Round1Date'];
                return true;
            
            }else{
                return false;
            }
        }
    }
    
    class JsonDictionary{

        // Connection
        private $conn;

        // Table
        private $db_table = "JsonDictionary";

        // Columns
        public $id;
        public $dictionaryJson;
        public $dictionaryDate;
        
        // Db connection
        public function __construct($db){
            $this->conn = $db;
        }

        // CREATE
        public function createJsonDictionary(){
        
            $sqlQuery = "INSERT INTO
                        ". $this->db_table ."
                    SET
                        dictionaryDate = :dictionaryDate, 
                        dictionaryJson = :dictionaryJson";
                        
            $stmt = $this->conn->prepare($sqlQuery);

            // sanitize and bind data
            $stmt->bindParam(":dictionaryDate", $this->dictionaryDate);
            $stmt->bindParam(":dictionaryJson", $this->dictionaryJson);

            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        public function getJsonDictionary(){
            
            $sqlQuery = "SELECT * FROM ". $this->db_table ." ORDER BY id DESC LIMIT 1";
            
            $stmt = $this->conn->prepare($sqlQuery);
            if($stmt->execute()){
                $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
               
                $this->id = $dataRow['id']; 
                $this->dictionaryJson = $dataRow['dictionaryJson'];
                $this->dictionaryDate = $dataRow['dictionaryDate'];
                return true;
            }else{
                return false;
            }
        }
        
        public function getLatestJsonDictionaryDate(){
            
            $sqlQuery = "SELECT id, dictionaryDate FROM ". $this->db_table ." ORDER BY id DESC LIMIT 1";
            
            $stmt = $this->conn->prepare($sqlQuery);
            if($stmt->execute()){
                $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
               
                $this->id = $dataRow['id']; 
                $this->dictionaryDate = $dataRow['dictionaryDate'];
                return true;
            
            }else{
                return false;
            }
        }
    }
?>

