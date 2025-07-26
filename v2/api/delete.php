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
    
    $body = $crypto->decryptPayload(file_get_contents("php://input"));
    echo $body;
    if($_SERVER['REQUEST_METHOD'] !== 'POST' || strpos($body, 'id') !== true){
        http_response_code(404);
        return;
    }
    
    $database = new Database();
    $db = $database->getConnection();
    
    $item = new Records($db);
    
    $data = json_decode($body);
    
    $item->id = $data->id;
    
    if($item->deleteRecord()){
        echo json_encode("Record deleted.");
    } else{
        echo json_encode("Data could not be deleted");
    }
?>