<?php
    class UserGuesses{

        // Connection
        private $conn;

        // Table
        private $db_table = "UserGuesses";

        // Columns
        public $id;
        public $name;
        public $word;
        public $extraData;
        public $timestamp;
        public $attempts;

        // Db connection
        public function __construct($db){
            $this->conn = $db;
        }

        // CREATE
        public function addEntry(){
            $sqlQuery = "INSERT INTO
                        ". $this->db_table ."
                    SET
                        name = :name, 
                        word = :word,
                        timestamp = :timestamp,
                        extraData = :extraData,
                        attempts = :attempts";
        
            $stmt = $this->conn->prepare($sqlQuery);
            // sanitize
            $this->name=htmlspecialchars(strip_tags($this->name));
            $this->word=htmlspecialchars(strip_tags($this->word));
            // $this->attempts=htmlspecialchars(strip_tags($this->attempts));
        
            // bind data
            $stmt->bindParam(":name", $this->name);
            $stmt->bindParam(":word", $this->word);
            $stmt->bindParam(":timestamp", $this->timestamp);
            $stmt->bindParam(":extraData", $this->extraData);
            $stmt->bindParam(":attempts", $this->attempts);
        
            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        public function getAllEntries(){
            $sqlQuery = "SELECT id, name, word, timestamp, extraData, attempts  FROM " . $this->db_table . " 
                ORDER BY id DESC";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }
    }
?>