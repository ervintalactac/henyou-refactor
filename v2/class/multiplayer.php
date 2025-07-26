<?php
    class MultiPlayer{

        // Connection
        private $conn;

        // Table
        private $db_table = "MultiPlayerRooms";

        // Columns
        public $id;
        public $roomName;
        public $guesser;
        public $cluegiver;
        public $status;
        public $created;

        // Db connection
        public function __construct($db){
            $this->conn = $db;
        }

        // CREATE
        public function addRoom(){
            $sqlQuery = "INSERT INTO
                        ". $this->db_table ."
                    SET
                        roomName = :roomName, 
                        guesser = :guesser,
                        cluegiver = :cluegiver,
                        status = :status";
        
            $stmt = $this->conn->prepare($sqlQuery);
            // sanitize
            // $this->name=htmlspecialchars(strip_tags($this->name));
            // $this->word=htmlspecialchars(strip_tags($this->word));
            // $this->attempts=htmlspecialchars(strip_tags($this->attempts));
        
            // bind data
            $stmt->bindParam(":roomName", $this->roomName);
            $stmt->bindParam(":guesser", $this->guesser);
            $stmt->bindParam(":cluegiver", $this->cluegiver);
            $stmt->bindParam(":status", $this->status);
        
            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        public function updateRoom($payload){
            
            // $this->roomName=htmlspecialchars(strip_tags($this->roomName));
            // $this->guesser=htmlspecialchars(strip_tags($this->guesser));
            // $this->cluegiver=htmlspecialchars(strip_tags($this->cluegiver));
            // $this->status=htmlspecialchars(strip_tags($this->status));
            // $this->created=htmlspecialchars(strip_tags($this->created));

             $columns = "";
            // if($this->roomName != NULL and $this->roomName != ""){
            //     $columns = $columns ."roomName = '". $this->roomName ."'";
            // }
            if(str_contains($payload, "guesser")){
                // if(strlen($columns) > 0){
                //     $columns = $columns . ',';
                // }
                $columns = $columns ."guesser = '". $this->guesser ."'";
            }
            if(str_contains($payload, "cluegiver")){
                if(strlen($columns) > 0){
                    $columns = $columns . ',';
                }
                $columns = $columns ."cluegiver = '". $this->cluegiver ."'";
            }
            if(str_contains($payload, "status")){
                if(strlen($columns) > 0){
                    $columns = $columns . ',';
                }
                $columns = $columns ."status = '". $this->status ."'";
            }
            // if(str_contains($payload, "created")){
                if(strlen($columns) > 0){
                    $columns = $columns . ',';
                }
                $columns = $columns ."created = '". $this->created ."'";
            // }    

            $sqlQuery = "UPDATE
                        ". $this->db_table ."
                    SET
                        ". $columns ."
                    WHERE 
                        roomName = '". $this->roomName ."'";
// echo $sqlQuery;
            $stmt = $this->conn->prepare($sqlQuery);
            
            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        public function getRoom(){
            $sqlQuery = "SELECT id, roomName, guesser, cluegiver, status, created FROM " . $this->db_table . "
                    WHERE roomName = ? LIMIT 0,1";

            $stmt = $this->conn->prepare($sqlQuery);

            $stmt->bindParam(1, $this->roomName);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
           
            $this->id = $dataRow['id']; 
            $this->roomName = $dataRow['roomName'];
            $this->guesser = $dataRow['guesser'];
            $this->cluegiver = $dataRow['cluegiver'];
            $this->status = $dataRow['status'];
            $this->created = $dataRow['created'];
        }
        
        public function getAllRooms(){
            $sqlQuery = "SELECT id, roomName, guesser, cluegiver, status, created FROM " . $this->db_table . " WHERE status <> 'closed' 
                ORDER BY id DESC";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }
    }
?>