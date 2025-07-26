<?php
    class Gimme5Guesses{

        // Connection
        private $conn;

        // Table
        private $db_table = "Gimme5Guesses";

        // Columns
        public $id;
        public $round;
        public $name;
        public $words;
        public $extradata;
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
                        round = :round,
                        name = :name, 
                        words = :words,
                        timestamp = :timestamp,
                        extradata = :extradata,
                        attempts = :attempts";
        
            $stmt = $this->conn->prepare($sqlQuery);
            // sanitize
            // $this->name=htmlspecialchars(strip_tags($this->name));
            // $this->word=htmlspecialchars(strip_tags($this->word));
            // $this->attempts=htmlspecialchars(strip_tags($this->attempts));
        
            // bind data
            $stmt->bindParam(":round", $this->round);
            $stmt->bindParam(":name", $this->name);
            $stmt->bindParam(":words", $this->words);
            $stmt->bindParam(":timestamp", $this->timestamp);
            $stmt->bindParam(":extradata", $this->extradata);
            $stmt->bindParam(":attempts", $this->attempts);
        
            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        public function getAllEntries(){
            $sqlQuery = "SELECT id, round, name, words, timestamp, extradata, attempts  FROM " . $this->db_table . " 
                ORDER BY id DESC";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }
    }
?>