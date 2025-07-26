<?php
    class NonceRecords{

        // Connection
        private $conn;

        // Table
        private $db_table = "NonceRecords";

        // Db connection
        public function __construct($db){
            $this->conn = $db;
        }
        
        // check if nonce already exists
        public function nonceExists($nonce){
            $sqlQuery = "SELECT
                        id,
                        nonce,
                        created
                      FROM
                        ". $this->db_table ."
                    WHERE 
                       nonce = :nonce
                    LIMIT 0,1";

            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->bindParam(":nonce", $nonce);
            $stmt->execute();
            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
           
            return isset($dataRow['nonce']);
        }
        
        // DELETE
        function deleteOldRecords(){
            $t = time() - 86400;
            $sqlQuery = "DELETE FROM " . $this->db_table . 
                " WHERE created < '". date('Y-m-d H:i:s', $t) ."'";
            $stmt = $this->conn->prepare($sqlQuery);
        
            if($stmt->execute()){
                return true;
            }
            return false;
        }
        
        public function getOldRecords(){
            $t = time();
            $sqlQuery = "SELECT * FROM ". $this->db_table .
                    " WHERE created < '". date('Y-m-d H:i:s', $t) ."'";

            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            
            return $stmt;
        }
        
        public function createNonceRecord($nonce){
            $sqlQuery = "INSERT INTO ". $this->db_table .
                    " SET nonce = :nonce";
        
            $stmt = $this->conn->prepare($sqlQuery);
            
            // bind data
            $stmt->bindParam(":nonce", $nonce);
            return $stmt->execute();
        }
         

    }
?>

