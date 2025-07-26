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
    
    $database = new Database();
    $db = $database->getConnection();
    // $db->set_charset('utf8mb4');
    $item = new Records($db);

    // error_log($data->alias);

    // record values
    $item->name = $data->name;
    $item->alias = $data->alias;
    $item->score = $data->score;
    $item->totalScore = $data->totalScore;
    $item->streak = $data->streak;
    $item->totalStreak = $data->totalStreak;
    $item->modified = date('Y-m-d H:i:s');
    if(isset($data->extraData)){
        $item->extraData = $data->extraData;
    }
    if(isset($data->secureData)){
        $item->secureData = $data->secureData;
    }
    
    if($item->updateRecord()){
        echo json_encode("Record data updated.");
    } else{
        echo json_encode("Record could not be updated");
    }
?>