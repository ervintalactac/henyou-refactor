<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    
    include_once '../config/database.php';
    include_once '../class/records.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $items = new Records($db);
    $stmt = $items->getRecords();
    $itemCount = $stmt->rowCount();

    if($itemCount > 0){
        
        $recordArr = array();
        $recordArr["body"] = array();
        $recordArr["itemCount"] = $itemCount;

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
            extract($row);
            $e = array(
                "id" => $id,
                "name" => $name,
                "alias" => $alias,
                "score" => $score,
                "totalScore" => $totalScore,
                "streak" => $streak,
                "totalStreak" => $totalStreak
                // "extraData" => $extraData,
                // "secureData" => $secureData,
                // "created" => strtotime($created),
                // "modified" => strtotime($modified)
                // commented out for faster/smaller return data
            );
            array_push($recordArr["body"], $e);
        }
        echo $crypto->encryptArray2($recordArr);
        http_response_code(200);
    }else{
        http_response_code(404);
        echo json_encode(
            array("message" => "No record found.")
        );
    }
?>