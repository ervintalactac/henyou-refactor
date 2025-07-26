<?php
    class MultiPlayerGuesses{

        // Connection
        private $conn;

        // Table
        private $db_table = "MultiPlayerGuesses";

        // Columns
        public $id;
        public $guesser;
        public $cluegiver;
        public $word;
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
                        guesser = :guesser, 
                        cluegiver = :cluegiver, 
                        word = :word,
                        timestamp = :timestamp,
                        extradata = :extradata,
                        attempts = :attempts";
        
            $stmt = $this->conn->prepare($sqlQuery);
            // sanitize
            // $this->name=htmlspecialchars(strip_tags($this->name));
            // $this->word=htmlspecialchars(strip_tags($this->word));
            // $this->attempts=htmlspecialchars(strip_tags($this->attempts));
        
            // bind data
            $stmt->bindParam(":guesser", $this->guesser);
            $stmt->bindParam(":cluegiver", $this->cluegiver);
            $stmt->bindParam(":word", $this->word);
            $stmt->bindParam(":timestamp", $this->timestamp);
            $stmt->bindParam(":extradata", $this->extradata);
            $stmt->bindParam(":attempts", $this->attempts);
        
            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        public function getAllEntries(){
            $sqlQuery = "SELECT id, guesser, cluegiver, word, timestamp, extradata, attempts  FROM " . $this->db_table . " 
                ORDER BY id DESC";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }
    }
?>