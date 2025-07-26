<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    
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
    $henyoWords = new HenyoWords($db);
    
    if($henyoWords->getGimme5Round1Words()){
        if(isset($_GET['date'])){
            $tempArr = array(
                "uploadDate" => $henyoWords->uploadDate
            );
            echo $crypto->encryptText2(json_encode($tempArr));
            http_response_code(200);
            return;
        }
        $tempArr = array(
            "uploadDate" => $henyoWords->uploadDate,
            "gimme5Round1Words" => $henyoWords->gimme5Round1Words
        );
        echo $crypto->encryptText2(json_encode($tempArr));
        http_response_code(200);
    }else{
        http_response_code(404);
        echo json_encode("Record not found.");
    }
    
?>