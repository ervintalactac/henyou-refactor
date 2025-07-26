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
    $jsonGimme5Round1 = new JsonGimme5Round1($db);
    if($jsonGimme5Round1->getJsonGimme5Round1()){
        $tempArr = array(
            "id" => $jsonGimme5Round1->id,
            "gimme5Round1Json" => $jsonGimme5Round1->gimme5Round1Json,
            "gimme5Round1Date" => strtotime($jsonGimme5Round1->gimme5Round1Date),
        );
        echo $crypto->encryptArray2($tempArr);
        // echo json_encode($tempArr);
        http_response_code(200);
    }else{
        http_response_code(404);
        echo json_encode("Record not found.");
    }
    
?>