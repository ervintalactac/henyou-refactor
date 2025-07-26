<?php

    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    
    include_once '../config/database.php';
    // include_once '../class/henyowords.php';
    include_once '../class/crypto.php';


    $auth2 = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth2)){
        return;
    }
    include_once '../class/noncerecords.php';
    
    $database = new Database();
    $db = $database->getConnection();
    $item = new NonceRecords($db);

    echo($crypto->nonceValid());

    $item->deleteOldRecords();
    $stmt = $item->getOldRecords();
    $itemCount = $stmt->rowCount();
    // echo(date('Y-m-d H:i:s'));
    // echo('
    // ');
    // echo($itemCount);
    // echo('
    // ');
    if($itemCount > 0){
        
        $recordArr = array();
        $recordArr["body"] = array();
        $recordArr["itemCount"] = $itemCount;

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
            extract($row);
            $e = array(
                "id" => $id,
                "nonce" => $nonce,
                "created" => $created
            );
            array_push($recordArr["body"], $e);
        }
        $encText = $crypto->encryptArray2($recordArr["body"]);
        // $encText = json_encode($recordArr["body"]);
        // error_log($encText);
        echo($encText);
    }
    http_response_code(200);

    
    // echo $auth2;
    // return;
    
    // $data = $crypto->decryptPayload(file_get_contents("php://input"));
// echo file_get_contents("php://input");
    // $enc_data = json_decode($data);
    // $b64_auth = base64_decode($data->auth);
    // $auth = $crypto->decryptWithServerPK($data->auth);
    // error_log($data->auth);
    // $auth = json_decode($auth);
    // $key = base64_decode($auth->key);
    // $iv = base64_decode($auth->iv);
    // echo $enc_data->payload;
    // $dec_auth = json_decode($enc_auth);
    // echo 'test2\n';
    // echo $dec_auth;
    // echo base64_decode($dec_auth->key);
    // echo $dec_auth->iv;
    // error_log($crypto->getKey() . ' <- Key : IV ->' .  $crypto->getIV());
    // echo $crypto->encryptText2(json_encode($data));
    // $data = json_decode($payload);
    // echo $data->time;

// return;
    // $name = $data->name;
    // $time = $data->time;
    
    // $tempArr = array();
    // $item->getSingleRecord();
        
    // $tempArr = '';    
    // if($item->created != null){
    //     // create array
    //     $tempArr = array(
    //         "extraData" => $item->extraData
    //     );
    //     http_response_code(200);
    //     //echo json_encode($tempArr);

    // }else{
    //     http_response_code(404);
    //     die("unable to retrieve user details");
    // }
    
    // $data = json_decode($item->extraData);
    // $publicKey = base64_decode($data->publicKey);

    // $crypto = new Crypto();
    // $otp = $crypto->getOTPwithTime($name, $time);
    
    // echo $otp . PHP_EOL;
    // echo base64_encode($otp) . PHP_EOL;
    
    //echo $crypto->getUserPublicKey($name);
    // if(!$crypto->verifyAuth($name, $auth))
    //     echo 'invalid auth';
    // else
    //     echo 'auth successful';
    
    // return;

    // $database = new Database();
    // $db = $database->getConnection();

    // $henyoWords = new HenyoWords($db);
    // if($henyoWords->getLatestWordsList()){
    //     $tempArr = array(
    //         "id" => $henyoWords->id,
    //         "uploadDate" => $henyoWords->uploadDate,
    //         "wordsList" => $henyoWords->wordsList,
    //         "dictionaryList" => $henyoWords->dictionaryList
    //     );
        // http_response_code(200);
    //     echo json_encode($tempArr);

    // }
      
    // else{
    //     http_response_code(404);
    //     echo json_encode("Record not found.");
    // }
    
?>