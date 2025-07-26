<?php
    class WeeklyWinners{

        // Connection
        private $conn;

        // Table
        private $db_table = "WeeklyWinners";

        // Columns
        public $id;
        public $weekNumber;
        public $firstPlace;
        public $secondPlace;
        public $thirdPlace;

        // Db connection
        public function __construct($db){
            $this->conn = $db;
        }

        // GET ALL
        public function getWeeklyWinners(){
            $sqlQuery = "SELECT id, weekNumber, firstPlace, secondPlace, thirdPlace FROM " . $this->db_table . "
                ORDER BY id DESC";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }

        // CREATE
        public function createWeeklyWinner(){
            $sqlQuery = "INSERT INTO
                        ". $this->db_table ."
                    SET
                        weekNumber = :weekNumber,
                        firstPlace = :firstPlace,
                        secondPlace = :secondPlace,
                        thirdPlace = :thirdPlace";
        
            $stmt = $this->conn->prepare($sqlQuery);

            $weekNumber = $this->getCurrentWeekNumber() - 1;
            if($this->isWeekNumberExists($weekNumber)){
                echo 'entry for ' + $weekNumber + ' already exists!';
                return false;
            }

            // bind data
            $stmt->bindParam(":firstPlace", $this->firstPlace);
            $stmt->bindParam(":secondPlace", $this->secondPlace);
            $stmt->bindParam(":thirdPlace", $this->thirdPlace);
            $stmt->bindParam(":weekNumber", $weekNumber);

            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        public function isWeekNumberExists($weekNumber){
            $sqlQuery = "SELECT weekNumber FROM ". $this->db_table ." WHERE weekNumber=:weekNumber LIMIT 0,1";

            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->bindParam(":weekNumber", $weekNumber);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);

            return isset($dataRow['weekNumber']);
        }   

        // READ SINGLE
        public function getWinnersByWeekNumber(){
            $sqlQuery = "SELECT id, weekNumber, firstPlace, secondPlace, thirdPlace FROM ". $this->db_table ." WHERE weekNumber=? LIMIT 0,1";

            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->bindParam(1, $this->weekNumber);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->id = $dataRow['id']; 
            $this->firstPlace = $dataRow['firstPlace'];
            $this->secondPlace = $dataRow['secondPlace'];
            $this->thirdPlace = $dataRow['thirdPlace'];
            $this->weekNumber = $dataRow['weekNumber'];
        }        

        // UPDATE
        public function updateWinnersByWeekNumber(){

             $columns = "";
            if($this->firstPlace != NULL and $this->firstPlace != ""){
                $columns = $columns ."firstPlace = '". $this->firstPlace ."'";
            }
            if($this->secondPlace != NULL and $this->secondPlace != ""){
                $columns = $columns ."secondPlace = '". $this->secondPlace ."'";
            }
            if($this->thirdPlace != NULL and $this->thirdPlace != ""){
                $columns = $columns ."thirdPlace = '". $this->thirdPlace ."'";
            }
            // $columns = $columns ."weekNumber = '". $this->weekNumber ."'";

            $sqlQuery = "UPDATE
                        ". $this->db_table ."
                    SET
                        ". $columns ."
                    WHERE 
                        weekNumber = '". $this->weekNumber ."'";

            $stmt = $this->conn->prepare($sqlQuery);

            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        public function getCurrentWeekNumber(){
            // return 'testing';
            return floor((time() - 345000) / 604800);
        }

    }
?>

