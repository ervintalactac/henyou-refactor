<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../config/database.php';
    include_once '../class/records.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }
    $data = $crypto->decryptPayload(file_get_contents("php://input"));

    // if(!$crypto->verifyAuth($data->name, $data->auth)){
    //     http_response_code(401);
    //     echo 'Invalid auth';
    //     return;
    // }

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
    $item = new Records($db);
    // $item->name = $crypto->getAuth2User();
    $item->name = $data->name;
    // if($item->getSingleRecord()){
    //     http_response_code(403);
    //     echo('Record already exists.');
    //     return;
    // }
    
    $item->alias = $data->alias;
    $item->score = $data->score;
    $item->totalScore = $data->totalScore;
    $item->streak = $data->streak;
    $item->totalStreak = $data->totalStreak;
    $item->created = date('Y-m-d H:i:s');
    $item->modified = date('Y-m-d H:i:s');
    if($data->extraData != null){
        $item->extraData = $data->extraData;
    }
    if($data->secureData != null){
        $item->secureData = $data->secureData;
    }
    
    if($item->createRecord()){
        http_response_code(200);
        echo 'Record created successfully.';
    } else{
        http_response_code(400);
        echo 'Record could not be created.';
    }
?>