<?php
    class WeeklyRecords{

        // Connection
        private $conn;

        // Table
        private $db_table = "WeeklyRecords";

        // Columns
        public $id;
        public $name;
        public $alias;
        public $score;
        public $streak;
        public $weekNumber;
        public $awardPaid;
        public $awardAmount;

        // Db connection
        public function __construct($db){
            $this->conn = $db;
        }

        // GET ALL
        public function getWeeklyRecords(){
            $sqlQuery = "SELECT id, name, alias, score, streak, weekNumber, awardPaid, awardAmount FROM " . $this->db_table . "
                ORDER BY id DESC";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }

        // GET TOP 3
        public function getTopThreeWeeklyRecords($weekNumber){
            $sqlQuery = "SELECT id, name, alias, score, streak, weekNumber, awardPaid, awardAmount FROM " . $this->db_table . " WHERE weekNumber=" .
                $weekNumber . " ORDER BY score DESC LIMIT 0,3";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }
        
        // CREATE
        public function createWeeklyRecord(){
            $sqlQuery = "INSERT INTO
                        ". $this->db_table ."
                    SET
                        name = :name,
                        alias = :alias,
                        score = :score,
                        streak = :streak,
                        weekNumber = :weekNumber";
        
            $stmt = $this->conn->prepare($sqlQuery);

            // bind data
            $stmt->bindParam(":name", $this->name);
            $stmt->bindParam(":alias", $this->alias);
            $stmt->bindParam(":score", $this->score);
            $stmt->bindParam(":streak", $this->streak);
            $stmt->bindParam(":weekNumber", $this->weekNumber);

            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        public function isUserAndWeekNumberExists(){
            $sqlQuery = "SELECT name, weekNumber FROM ". $this->db_table ." WHERE name=:name AND weekNumber=:weekNumber LIMIT 0,1";

            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->bindParam(":name", $this->name);
            $stmt->bindParam(":weekNumber", $this->weekNumber);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
            // echo $dataRow['name'];

            return isset($dataRow['name']) AND isset($dataRow['weekNumber']);
        }   

        // READ SINGLE
        public function getUserWeeklyRecord(){
            $sqlQuery = "SELECT id, name, alias, score, streak, weekNumber, awardPaid, awardAmount FROM ". $this->db_table ." WHERE name=? AND weekNumber=? LIMIT 0,1";

            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->bindParam(1, $this->name);
            $stmt->bindParam(2, $this->weekNumber);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->id = $dataRow['id']; 
            $this->name = $dataRow['name'];
            $this->alias = $dataRow['alias'];
            $this->score = $dataRow['score'];
            $this->streak = $dataRow['streak'];
            $this->weekNumber = $dataRow['weekNumber'];
            $this->awardPaid = $dataRow['awardPaid'];
            $this->awardAmount = $dataRow['awardAmount'];
        }        

        // UPDATE
        public function updateUserWeeklyRecord(){
            $sqlQuery = "UPDATE ". $this->db_table ." SET alias=:alias, score=:score, streak=:streak, awardPaid=:awardPaid, awardAmount=:awardAmount WHERE name=:name AND weekNumber=:weekNumber";

            $stmt = $this->conn->prepare($sqlQuery);
            
            // bind data
            $stmt->bindParam(":name", $this->name);
            $stmt->bindParam(":alias", $this->alias);
            $stmt->bindParam(":score", $this->score);
            $stmt->bindParam(":streak", $this->streak);
            $stmt->bindParam(":weekNumber", $this->weekNumber);
            $stmt->bindParam(":awardPaid", $this->awardPaid);
            $stmt->bindParam(":awardAmount", $this->awardAmount);

            if($stmt->execute()){
               return true;
            }
            return false;
        }

    }
?>

