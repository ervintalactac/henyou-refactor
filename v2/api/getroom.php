<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../config/database.php';
    include_once '../class/multiplayer.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }

    $database = new Database();
    $db = $database->getConnection();

    $item = new MultiPlayer($db);

    $item->roomName = isset($_GET['roomName']) ? $_GET['roomName'] : die("couldn't get query params");
    
    $tempArr = array();
    $item->getRoom();
        
    if($item->created != null){
        // create array
        $tempArr = array(
            "id" => $item->id,
            "roomName" => $item->roomName,
            "guesser" => $item->guesser,
            "cluegiver" => $item->cluegiver,
            "status" => $item->status,
            "created" => $item->created
        );
        http_response_code(200);
        echo $crypto->encryptArray2($tempArr);

    }else{
        http_response_code(404);
        echo json_encode("Record not found.");
    }
?>