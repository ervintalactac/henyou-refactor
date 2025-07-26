<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    
    include_once '../config/database.php';
    include_once '../class/jsonfiles.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    $jsonWords = new JsonWords($db);
    if($jsonWords->getJsonWords()){
        $tempArr = array(
            "id" => $jsonWords->id,
            "wordsJson" => $jsonWords->wordsJson,
            "wordsDate" => strtotime($jsonWords->wordsDate),
        );
        echo $crypto->encryptArray2($tempArr);
        // echo json_encode($tempArr);
        http_response_code(200);
    }else{
        http_response_code(404);
        echo json_encode("Record not found.");
    }
    
?>