<?php
class RecordsSecure {
    private $conn;
    private $db_table = "RecordsHenyo";
    
    // Properties
    public $id;
    public $name;
    public $alias;
    public $score;
    public $totalScore;
    public $streak;
    public $totalStreak;
    public $modified;
    public $extraData;
    public $secureData;
    
    // Constructor
    public function __construct($db) {
        $this->conn = $db;
    }
    
    /**
     * Create new record
     */
    public function createRecord() {
        $sqlQuery = "INSERT INTO " . $this->db_table . " 
                    (name, alias, score, totalScore, streak, totalStreak, extraData, secureData, modified) 
                    VALUES 
                    (:name, :alias, :score, :totalScore, :streak, :totalStreak, :extraData, :secureData, :modified)";
        
        $stmt = $this->conn->prepare($sqlQuery);
        
        // Sanitize and bind parameters
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":alias", $this->alias);
        $stmt->bindParam(":score", $this->score, PDO::PARAM_INT);
        $stmt->bindParam(":totalScore", $this->totalScore, PDO::PARAM_INT);
        $stmt->bindParam(":streak", $this->streak, PDO::PARAM_INT);
        $stmt->bindParam(":totalStreak", $this->totalStreak, PDO::PARAM_INT);
        $stmt->bindParam(":extraData", $this->extraData);
        $stmt->bindParam(":secureData", $this->secureData);
        $stmt->bindParam(":modified", $this->modified);
        
        try {
            if ($stmt->execute()) {
                return true;
            }
        } catch (PDOException $e) {
            error_log("Error creating record: " . $e->getMessage());
        }
        
        return false;
    }
    
    /**
     * Get all records
     */
    public function getRecords() {
        $sqlQuery = "SELECT id, name, alias, score, totalScore, streak, totalStreak, 
                            extraData, secureData, modified 
                     FROM " . $this->db_table . " 
                     ORDER BY totalScore DESC";
        
        $stmt = $this->conn->prepare($sqlQuery);
        $stmt->execute();
        
        return $stmt;
    }
    
    /**
     * Get single record by name
     */
    public function getSingleRecord() {
        $sqlQuery = "SELECT id, name, alias, score, totalScore, streak, totalStreak, 
                            extraData, secureData, modified 
                     FROM " . $this->db_table . " 
                     WHERE name = :name 
                     LIMIT 1";
        
        $stmt = $this->conn->prepare($sqlQuery);
        $stmt->bindParam(":name", $this->name);
        $stmt->execute();
        
        $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($dataRow) {
            $this->id = $dataRow['id'];
            $this->name = $dataRow['name'];
            $this->alias = $dataRow['alias'];
            $this->score = $dataRow['score'];
            $this->totalScore = $dataRow['totalScore'];
            $this->streak = $dataRow['streak'];
            $this->totalStreak = $dataRow['totalStreak'];
            $this->extraData = $dataRow['extraData'];
            $this->secureData = $dataRow['secureData'];
            $this->modified = $dataRow['modified'];
            return true;
        }
        
        return false;
    }
    
    /**
     * Update record - SECURE VERSION
     */
    public function updateRecord() {
        // Build update query with only non-null fields
        $updateFields = [];
        $params = [];
        
        if ($this->alias !== null && $this->alias !== "") {
            $updateFields[] = "alias = :alias";
            $params[':alias'] = $this->alias;
        }
        
        if ($this->score !== null && $this->score !== "") {
            $updateFields[] = "score = :score";
            $params[':score'] = $this->score;
        }
        
        if ($this->totalScore !== null && $this->totalScore !== "") {
            $updateFields[] = "totalScore = :totalScore";
            $params[':totalScore'] = $this->totalScore;
        }
        
        if ($this->streak !== null && $this->streak !== "") {
            $updateFields[] = "streak = :streak";
            $params[':streak'] = $this->streak;
        }
        
        if ($this->totalStreak !== null && $this->totalStreak !== "") {
            $updateFields[] = "totalStreak = :totalStreak";
            $params[':totalStreak'] = $this->totalStreak;
        }
        
        if ($this->extraData !== null && $this->extraData !== "") {
            $updateFields[] = "extraData = :extraData";
            $params[':extraData'] = $this->extraData;
        }
        
        if ($this->secureData !== null && $this->secureData !== "") {
            $updateFields[] = "secureData = :secureData";
            $params[':secureData'] = $this->secureData;
        }
        
        // Always update modified timestamp
        $updateFields[] = "modified = :modified";
        $params[':modified'] = $this->modified;
        
        // Add name for WHERE clause
        $params[':name'] = $this->name;
        
        if (empty($updateFields)) {
            return false;
        }
        
        $sqlQuery = "UPDATE " . $this->db_table . " 
                     SET " . implode(", ", $updateFields) . " 
                     WHERE name = :name";
        
        $stmt = $this->conn->prepare($sqlQuery);
        
        try {
            if ($stmt->execute($params)) {
                return true;
            }
        } catch (PDOException $e) {
            error_log("Error updating record: " . $e->getMessage());
        }
        
        return false;
    }
    
    /**
     * Delete record
     */
    public function deleteRecord() {
        $sqlQuery = "DELETE FROM " . $this->db_table . " WHERE id = :id";
        
        $stmt = $this->conn->prepare($sqlQuery);
        $stmt->bindParam(":id", $this->id, PDO::PARAM_INT);
        
        try {
            if ($stmt->execute()) {
                return true;
            }
        } catch (PDOException $e) {
            error_log("Error deleting record: " . $e->getMessage());
        }
        
        return false;
    }
    
    /**
     * Check if record exists
     */
    public function recordExists() {
        $sqlQuery = "SELECT COUNT(*) as count FROM " . $this->db_table . " WHERE name = :name";
        
        $stmt = $this->conn->prepare($sqlQuery);
        $stmt->bindParam(":name", $this->name);
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row['count'] > 0;
    }
    
    /**
     * Get top records (for leaderboard)
     */
    public function getTopRecords($limit = 10) {
        $sqlQuery = "SELECT id, name, alias, score, totalScore, streak, totalStreak, modified 
                     FROM " . $this->db_table . " 
                     ORDER BY totalScore DESC 
                     LIMIT :limit";
        
        $stmt = $this->conn->prepare($sqlQuery);
        $stmt->bindParam(":limit", $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt;
    }
    
    /**
     * Search records by alias
     */
    public function searchByAlias($searchTerm) {
        $sqlQuery = "SELECT id, name, alias, score, totalScore, streak, totalStreak, modified 
                     FROM " . $this->db_table . " 
                     WHERE alias LIKE :searchTerm 
                     ORDER BY totalScore DESC";
        
        $stmt = $this->conn->prepare($sqlQuery);
        $searchTerm = "%" . $searchTerm . "%";
        $stmt->bindParam(":searchTerm", $searchTerm);
        $stmt->execute();
        
        return $stmt;
    }
    
    /**
     * Update specific field
     */
    public function updateField($field, $value) {
        // Whitelist allowed fields
        $allowedFields = ['alias', 'score', 'totalScore', 'streak', 'totalStreak', 
                         'extraData', 'secureData'];
        
        if (!in_array($field, $allowedFields)) {
            throw new Exception("Invalid field name");
        }
        
        $sqlQuery = "UPDATE " . $this->db_table . " 
                     SET " . $field . " = :value, modified = :modified 
                     WHERE name = :name";
        
        $stmt = $this->conn->prepare($sqlQuery);
        $stmt->bindParam(":value", $value);
        $stmt->bindParam(":modified", $this->modified);
        $stmt->bindParam(":name", $this->name);
        
        try {
            if ($stmt->execute()) {
                return true;
            }
        } catch (PDOException $e) {
            error_log("Error updating field: " . $e->getMessage());
        }
        
        return false;
    }
    
    /**
     * Sanitize input data
     */
    public function sanitizeInput($data) {
        $data = trim($data);
        $data = stripslashes($data);
        $data = htmlspecialchars($data, ENT_QUOTES, 'UTF-8');
        return $data;
    }
    
    /**
     * Validate score/streak values
     */
    public function validateNumeric($value) {
        return is_numeric($value) && $value >= 0;
    }
}
?>