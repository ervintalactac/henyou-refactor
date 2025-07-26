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

    $database = new Database();
    $db = $database->getConnection();
    $item = new Records($db);
    $item->name = $crypto->getAuth2User();
    $tempArr = array();
    if($item->getSingleRecord()){
        // create array
        $tempArr = array(
            "id" => $item->id,
            "name" => $item->name,
            "alias" => $item->alias,
            "score" => $item->score,
            "totalScore" => $item->totalScore,
            "streak" => $item->streak,
            "totalStreak" => $item->totalStreak,
            "extraData" => $item->extraData,
            "secureData" => $item->secureData,
            "created" => strtotime($item->created),
            "modified" => strtotime($item->modified),
        );
        http_response_code(200);
        echo $crypto->encryptArray2($tempArr);

    }else{
        http_response_code(404);
        echo json_encode("Record not found.");
    }
?>