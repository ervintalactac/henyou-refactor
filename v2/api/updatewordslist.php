<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../config/database.php';
    include_once '../class/henyowords.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }

    $database = new Database();
    $db = $database->getConnection();

    $item = new HenyoWords($db);

    $data = $crypto->decryptPayload(file_get_contents("php://input"));

    $item->uploadDate = date('Y-m-d H:i:s');
    $item->wordsList = $data->wordsList;
    $item->dictionaryList = $data->dictionaryList;

    if($item->createHenyoWords()){
        echo 'Words list created successfully.';
    } else{
        echo 'Words list could not be created.';
    }
?>