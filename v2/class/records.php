<?php
    class Records{

        // Connection
        private $conn;

        // Table
        private $db_table = "RecordsHenyo";

        // Columns
        public $id;
        public $name;
        public $alias;
        public $score;
        public $totalScore;
        public $streak;
        public $totalStreak;
        public $created;
        public $modified;
        public $extraData;
        public $secureData;

        // Db connection
        public function __construct($db){
            $this->conn = $db;
        }

        // GET ALL
        public function getRecords(){
            $sqlQuery = "SELECT id, name, alias, score, totalScore, streak, totalStreak FROM " . $this->db_table . "
                ORDER BY id DESC";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }

        public function getRecordsWithTime(){
            $sqlQuery = "SELECT id, name, alias, score, totalScore, streak, totalStreak, created, modified FROM " . $this->db_table . "
                ORDER BY id DESC";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }
        
        // CREATE
        public function createRecord(){
            $sqlQuery = "INSERT INTO
                        ". $this->db_table ."
                    SET
                        name = :name, 
                        alias = :alias, 
                        score = :score, 
                        totalScore = :totalScore, 
                        streak = :streak,
                        totalStreak = :totalStreak,
                        created = :created,
                        modified = :modified,
                        extraData = :extraData,
                        secureData = :secureData";
        
            $stmt = $this->conn->prepare($sqlQuery);
        
            // sanitize
            // $this->name=htmlspecialchars(strip_tags($this->name));
            // $this->alias=htmlspecialchars(strip_tags($this->alias));
            // $this->score=htmlspecialchars(strip_tags($this->score));
            // $this->totalScore=htmlspecialchars(strip_tags($this->totalScore));
            // $this->streak=htmlspecialchars(strip_tags($this->streak));
            // $this->totalStreak=htmlspecialchars(strip_tags($this->totalStreak));
            // $this->created=htmlspecialchars(strip_tags($this->created));
            // $this->modified=htmlspecialchars(strip_tags($this->modified));
            // $this->extraData=htmlspecialchars(strip_tags($this->extraData));
            // $this->secureData=htmlspecialchars(strip_tags($this->secureData));
            // error_log($this->name);
            
            // bind data
            $stmt->bindParam(":name", $this->name);
            $stmt->bindParam(":alias", $this->alias);
            $stmt->bindParam(":score", $this->score);
            $stmt->bindParam(":totalScore", $this->totalScore);
            $stmt->bindParam(":streak", $this->streak);
            $stmt->bindParam(":totalStreak", $this->totalStreak);
            $stmt->bindParam(":created", $this->created);
            $stmt->bindParam(":modified", $this->modified);
            $stmt->bindParam(":extraData", $this->extraData);
            $stmt->bindParam(":secureData", $this->secureData);
        
            if($stmt->execute()){
               return true;
            }
            return false;
        }
        
        // get extra data from a user
        public function getUserExtraData(){
            $sqlQuery = "SELECT
                        id,
                        name,
                        extraData
                      FROM
                        ". $this->db_table ."
                    WHERE 
                       name = ?
                    LIMIT 0,1";

            $stmt = $this->conn->prepare($sqlQuery);

            $stmt->bindParam(1, $this->name);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
           
            $this->id = $dataRow['id']; 
            $this->name = $dataRow['name'];
            $this->extraData = $dataRow['extraData'];
        }  

        // READ SINGLE
        // public function getSingleRecord(){
        //     $sqlQuery = "SELECT
        //                 id, 
        //                 name, 
        //                 alias, 
        //                 score, 
        //                 totalScore, 
        //                 streak,
        //                 totalStreak,
        //                 created,
        //                 modified,
        //                 extraData,
        //                 secureData
        //               FROM
        //                 ". $this->db_table ."
        //             WHERE 
        //               name = '" . $this->name . "'
        //             LIMIT 0,1";

        //     $stmt = $this->conn->prepare($sqlQuery);

        //     // $stmt->bindParam(0, $this->name);
        //     error_log($sqlQuery);
        //     // error_log($stmt);
        //     if(!$stmt->execute()){
        //         error_log('returning false $stmt->execute()');
        //       return false;
        //     }

        //     $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
        //     if($dataRow['id'] == null){
        //         error_log('user record not found');
        //         return false;
        //     }
           
        //     $this->id = $dataRow['id']; 
        //     $this->name = $dataRow['name'];
        //     $this->alias = $dataRow['alias'];
        //     $this->score = $dataRow['score'];
        //     $this->totalScore = $dataRow['totalScore'];
        //     $this->streak = $dataRow['streak'];
        //     $this->totalStreak = $dataRow['totalStreak'];
        //     $this->created = $dataRow['created'];
        //     $this->modified = $dataRow['modified'];
        //     $this->extraData = $dataRow['extraData'];
        //     $this->secureData = $dataRow['secureData'];
            
        //     return true;
        // }  
        public function getSingleRecord(){
            $sqlQuery = "SELECT
                        id, 
                        name, 
                        alias, 
                        score, 
                        totalScore, 
                        streak,
                        totalStreak,
                        created,
                        modified,
                        extraData,
                        secureData
                      FROM
                        ". $this->db_table ."
                    WHERE 
                       name = ?
                    LIMIT 0,1";
// $i = 0;
            $stmt = $this->conn->prepare($sqlQuery);
// error_log($this->name);
            $stmt->bindParam(1, $this->name);
// error_log(++$i);
            $stmt->execute();
// error_log(++$i);
            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
// error_log(++$i);
            $this->id = $dataRow['id']; 
            $this->name = $dataRow['name'];
            $this->alias = $dataRow['alias'];
            $this->score = $dataRow['score'];
            $this->totalScore = $dataRow['totalScore'];
            $this->streak = $dataRow['streak'];
            $this->totalStreak = $dataRow['totalStreak'];
            $this->created = $dataRow['created'];
            $this->modified = $dataRow['modified'];
            $this->extraData = $dataRow['extraData'];
            $this->secureData = $dataRow['secureData'];
error_log('fetch user record: ' . $this->created ? 'true' : 'false');
            return $this->created;
        }       

        // UPDATE
        public function updateRecord(){
            
            // $this->name=htmlspecialchars(strip_tags($this->name));
            $this->alias = htmlspecialchars(strip_tags($this->alias));
            // $this->score=htmlspecialchars(strip_tags($this->score));
            // $this->totalScore=htmlspecialchars(strip_tags($this->totalScore));
            // $this->streak=htmlspecialchars(strip_tags($this->streak));
            // $this->totalStreak=htmlspecialchars(strip_tags($this->totalStreak));
            // $this->modified=htmlspecialchars(strip_tags($this->modified));
            // $this->extraData=htmlspecialchars(strip_tags($this->extraData)); leave commented as it messes up formatting of json
            // $this->secureData=htmlspecialchars(strip_tags($this->secureData));

             $columns = "";
            // if($this->name != NULL and $this->name != ""){
            //     $columns = $columns ."name = ". $this->name .", ";
            // }
            if($this->alias != NULL and $this->alias != ""){
                $columns = $columns ."alias = '". $this->alias ."', ";
            }
            if($this->score != NULL and $this->score != ""){
                $columns = $columns ."score = '". $this->score ."', ";
            }
            if($this->totalScore != NULL and $this->totalScore != ""){
                $columns = $columns ."totalScore = '". $this->totalScore ."', ";
            }
            if($this->streak != NULL and $this->streak != ""){
                $columns = $columns ."streak = '". $this->streak ."', ";
            }
            if($this->totalStreak != NULL and $this->totalStreak != ""){
                $columns = $columns ."totalStreak = '". $this->totalStreak ."', ";
            }    
            if($this->extraData != NULL and $this->extraData != ""){
                $columns = $columns ."extraData = '". $this->extraData ."', ";
            }
            if($this->secureData != NULL and $this->secureData != ""){
                $columns = $columns ."secureData = '". $this->secureData ."', ";
            }
            $columns = $columns ."modified = '". $this->modified ."'";

            $sqlQuery = "UPDATE
                        ". $this->db_table ."
                    SET
                        ". $columns ."
                    WHERE 
                        name = '". $this->name ."'";

            $stmt = $this->conn->prepare($sqlQuery);
            
            // error_log($sqlQuery);
            
            // bind data
            // $stmt->bindParam(":name", $this->name);
            // $stmt->bindParam(":alias", $this->alias);
            // $stmt->bindParam(":score", $this->score);
            // $stmt->bindParam(":totalScore", $this->totalScore);
            // $stmt->bindParam(":streak", $this->streak);
            // $stmt->bindParam(":totalStreak", $this->totalStreak);
            // $stmt->bindParam(":modified", $this->modified);
            // $stmt->bindParam(":extraData", $this->extraData);
            // $stmt->bindParam(":secureData", $this->secureData);
            
            if($stmt->execute()){
               return true;
            }
            return false;
        }

        // DELETE
        function deleteRecord(){
            $sqlQuery = "DELETE FROM " . $this->db_table . " WHERE id = ?";
            $stmt = $this->conn->prepare($sqlQuery);
        
            $this->id=htmlspecialchars(strip_tags($this->id));
        
            $stmt->bindParam(1, $this->id);
        
            if($stmt->execute()){
                return true;
            }
            return false;
        }

    }
?>

