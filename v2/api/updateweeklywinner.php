<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
    
    include_once '../config/database.php';
    include_once '../class/weeklywinners.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }
    $database = new Database();
    $db = $database->getConnection();
    $item = new WeeklyWinners($db);
    $data = $crypto->decryptPayload(file_get_contents("php://input"));

    // record values
    $item->weekNumber = $data->weekNumber;
    $item->firstPlace = $data->firstPlace;
    $item->secondPlace = $data->secondPlace;
    $item->thirdPlace = $data->thirdPlace;
    
    if($item->updateWinnersByWeekNumber()){
        http_response_code(200);
        echo json_encode("Weekly record data updated.");
    } else{
        http_response_code(400);
        echo json_encode("Weekly record could not be updated");
    }

    // if($item->createWeeklyRecord()){
    //     http_response_code(200);
    //     echo json_encode("Weekly record data created.");
    // } else{
    //     http_response_code(400);
    //     echo json_encode("Weekly record could not be created");
    // }

?>