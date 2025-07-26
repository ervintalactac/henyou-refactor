<?php
    class RecordsBackup{

        // Connection
        private $conn;

        // Table
        private $db_table = "RecordsBackup";

        // Columns
        public $id;
        public $name;
        public $email;
        public $code;
        public $codeUsed;

        // Db connection
        public function __construct($db){
            $this->conn = $db;
        }

        // GET ALL
        public function getRecords(){
            $sqlQuery = "SELECT id, name, email, code, codeUsed FROM " . $this->db_table . "
                ORDER BY id DESC";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }
        
        public function getCodeByEmail($emailFromUser, $crypto){
            $stmt = $this->getRecords();
            
            $tempCode = 0;
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
                extract($row);
                $user_email = $crypto->decryptWithServerPK($email);
                // echo $emailFromUser;
                // echo $user_email;
                if($emailFromUser == $user_email){
                    if($codeUsed == 'true'){
                        $tempCode = -1;
                        continue;
                    }
                    return $code;
                }
            }
            return $tempCode;
        }

        // CREATE
        public function createRecordBackup(){
            $sqlQuery = "INSERT INTO
                        ". $this->db_table ."
                    SET
                        name = :name, 
                        email = :email, 
                        code = :code, 
                        codeUsed = :codeUsed";
        
            $stmt = $this->conn->prepare($sqlQuery);
        
            // sanitize
            // $this->name=htmlspecialchars(strip_tags($this->name));
            $code = substr(str_shuffle(MD5(microtime())), 0, 10);
            $codeUsed = 'false';
            // echo $code . ' ' . $codeUsed;
            // bind data
            $stmt->bindParam(":name", $this->name);
            $stmt->bindParam(":email", $this->email);
            $stmt->bindParam(":code", $code);
            $stmt->bindParam(":codeUsed", $codeUsed);
        
            if($stmt->execute()){
               return true;
            }
            return false;
        }

        // READ SINGLE
        public function getRecordWithCode(){
            $sqlQuery = "SELECT
                        id, 
                        name, 
                        email,
                        code, 
                        codeUsed
                      FROM
                        ". $this->db_table ."
                    WHERE 
                      code = ?
                    LIMIT 0,1";

            $stmt = $this->conn->prepare($sqlQuery);

            $stmt->bindParam(1, $this->code);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
           
            $this->id = $dataRow['id']; 
            $this->name = $dataRow['name'];
            $this->email = $dataRow['email'];
            $this->code = $dataRow['code'];
            $this->codeUsed = $dataRow['codeUsed'];
        } 
        
        // UPDATE
        public function updateRecordBackup(){

            $columns = "";
            if($this->name != NULL and $this->name != ""){
                // if(strlen($columns) > 0){
                //     $columns = $columns .", ";
                // }
                $columns = $columns ."name = '". $this->name;
            }
            if($this->email != NULL and $this->email != ""){
                if(strlen($columns) > 0){
                    $columns = $columns ."', ";
                }
                $columns = $columns ."email = '". $this->email;
            }
            if($this->code != NULL and $this->code != ""){
                if(strlen($columns) > 0){
                    $columns = $columns ."', ";
                }
                $columns = $columns ."code = '". $this->code;
            }
            if($this->codeUsed != NULL and $this->codeUsed != ""){
                if(strlen($columns) > 0){
                    $columns = $columns ."', ";
                }
                $columns = $columns ."codeUsed = '". $this->codeUsed;
            }
            $columns = $columns . "'";

            $sqlQuery = "UPDATE
                        ". $this->db_table ."
                    SET
                        ". $columns ."
                    WHERE 
                        name = '". $this->name ."'";

            $stmt = $this->conn->prepare($sqlQuery);
            
            // error_log($sqlQuery);
            
            if($stmt->execute()){
              return true;
            }
            return false;
        }

        // get extra data from a user
        // public function getUserExtraData(){
        //     $sqlQuery = "SELECT
        //                 id,
        //                 name,
        //                 extraData
        //               FROM
        //                 ". $this->db_table ."
        //             WHERE 
        //               name = ?
        //             LIMIT 0,1";

        //     $stmt = $this->conn->prepare($sqlQuery);

        //     $stmt->bindParam(1, $this->name);

        //     $stmt->execute();

        //     $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
           
        //     $this->id = $dataRow['id']; 
        //     $this->name = $dataRow['name'];
        //     $this->extraData = $dataRow['extraData'];
        // }  
        


        // // DELETE
        // function deleteRecord(){
        //     $sqlQuery = "DELETE FROM " . $this->db_table . " WHERE id = ?";
        //     $stmt = $this->conn->prepare($sqlQuery);
        
        //     $this->id=htmlspecialchars(strip_tags($this->id));
        
        //     $stmt->bindParam(1, $this->id);
        
        //     if($stmt->execute()){
        //         return true;
        //     }
        //     return false;
        // }

    }
?>

