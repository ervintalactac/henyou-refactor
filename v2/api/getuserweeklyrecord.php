<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../config/database.php';
    include_once '../class/weeklyrecords.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }
    
    if(!isset($_GET['weekNumber'])){
        http_response_code(404);
        return;
    }

    $database = new Database();
    $db = $database->getConnection();
    $item = new WeeklyRecords($db);

    $item->name = $crypto->getAuth2User();
    $item->weekNumber = isset($_GET['weekNumber']) ? $_GET['weekNumber'] : die("weekNumber query param missing");
    
    $tempArr = array();
    $item->getUserWeeklyRecord();
    if($item->id != null){
        // create array
        $tempArr = array(
            "id" => $item->id,
            "name" => $item->name,
            "alias" => $item->alias,
            "score" => $item->score,
            "streak" => $item->streak,
            "weekNumber" => $item->weekNumber,
            "awardPaid" => $item->awardPaid,
            "awardAmount" => $item->awardAmount
        );
        http_response_code(200);
        echo $crypto->encryptText2($tempArr);
    }else{
        http_response_code(404);
        echo json_encode("Record not found.");
    }
?>