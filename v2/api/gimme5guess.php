<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../config/database.php';
    include_once '../class/gimme5guesses.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $item = new Gimme5Guesses($db);
    $data = $crypto->decryptPayload(file_get_contents("php://input"));

    $item->round = $data->round;
    $item->name = $data->name;
    $item->words = $data->words;
    $item->extradata = $data->extradata;
    $item->timestamp = date('Y-m-d H:i:s');
    $item->attempts = $data->attempts;
    
    if($item->addEntry()){
        http_response_code(200);
        echo 'Entry created successfully.';
    } else{
        http_response_code(400);
        echo 'Entry could not be created.';
    }
?>