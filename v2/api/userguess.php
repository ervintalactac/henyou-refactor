<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../config/database.php';
    include_once '../class/guesses.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $item = new UserGuesses($db);
    $data = $crypto->decryptPayload(file_get_contents("php://input"));

    $item->name = $data->name;
    $item->word = $data->word;
    $item->extraData = $data->extraData;
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