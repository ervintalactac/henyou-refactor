<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../config/database.php';
    include_once '../class/recordsbackup.php';
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
    $item = new RecordsBackup($db);
    $item->code = $data->code;
    $item->getRecordWithCode();
    if($item->codeUsed == 'true'){
        http_response_code(403);
        echo json_encode('Restore failed. Code already used previously!');
        return;
    }
    
    $rec = new Records($db);    
    $rec->name = $item->name;

    if($rec->getSingleRecord()){
        // create array
        $tempArr = array(
            "id" => $rec->id,
            "name" => $rec->name,
            "alias" => $rec->alias,
            "score" => $rec->score,
            "totalScore" => $rec->totalScore,
            "streak" => $rec->streak,
            "totalStreak" => $rec->totalStreak,
            "extraData" => $rec->extraData,
            "secureData" => $rec->secureData,
            "created" => strtotime($rec->created),
            "modified" => strtotime($rec->modified),
        );
        http_response_code(200);
        echo $crypto->encryptArray2($tempArr);
        
        $item = new RecordsBackup($db);
        $item->codeUsed = 'true';
        $item->name = $rec->name;
        if($item->updateRecordBackup()){
            error_log('codeUsed set to true for user: ' . $item->name);
        }else{
            error_log('failed to set codeUsed to true for user: ' . $item->name);
        }
    }else{
        http_response_code(404);
        echo json_encode("No record found with the code provided.");
    }
?>