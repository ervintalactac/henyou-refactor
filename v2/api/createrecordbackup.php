<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../config/database.php';
    include_once '../class/recordsbackup.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }
    $data = $crypto->decryptPayload(file_get_contents("php://input"));
    
    $database = new Database();
    $db = $database->getConnection();
    $item = new RecordsBackup($db);
    $item->name = $crypto->getAuth2User();
    // $item->getRecordBackup();
    // if($item->created != null){
    //     http_response_code(400);
    //     echo 'Record already exists.';
    // }
    
    $item->email = $data->email;

    if($item->createRecordBackup()){
        http_response_code(200);
        echo 'Record backup created successfully.';
    } else{
        http_response_code(400);
        echo 'Record backup could not be created.';
    }
?>