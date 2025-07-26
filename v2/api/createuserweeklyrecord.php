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

    // $enc_data = json_decode($body);
    // $b64_data = base64_decode($enc_data->auth);
    // $enc_auth = $crypto->decryptWithServerPK($b64_data);
    // echo $enc_auth;
    // echo $enc_data->payload;
    // $dec_auth = json_decode($enc_auth);
    // echo 'test2';
    // echo $dec_auth;
    // echo base64_decode($dec_auth->key);
    // echo $dec_auth->iv;
    // $crypto->decryptText($dec_auth->key, $dec_auth->iv, $enc_data->payload, $payload);
    // echo $payload;
    // $data = json_decode($payload);
    
    $database = new Database();
    $db = $database->getConnection();
    $item = new WeeklyRecords($db);
    
    $item->name = $data->name;
    $item->alias = $data->alias;
    $item->score = $data->score;
    $item->streak = $data->streak;
    $item->weekNumber = $data->weekNumber;

    if($item->createWeeklyRecord()){
        http_response_code(200);
        echo 'Record created successfully.';
    } else{
        http_response_code(400);
        echo 'Record could not be created.';
    }
?>