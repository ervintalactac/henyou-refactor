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
    $data = $crypto->decryptPayload(file_get_contents("php://input"));
    
    $database = new Database();
    $db = $database->getConnection();
    $item = new WeeklyRecords($db);
    
    $item->name = $crypto->getAuth2User($auth);
    $item->weekNumber = $data->weekNumber;

    if($item->isUserAndWeekNumberExists()){
        http_response_code(200);
        echo 'true';
    } else{
        http_response_code(400);
        echo 'false';
    }
?>