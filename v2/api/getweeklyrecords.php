<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../config/database.php';
    include_once '../class/weeklyrecords.php';
    include_once '../class/crypto.php';

    $auth = $_SERVER['HTTP_AUTH2'];
    $crypto = new Crypto();
    if(!$crypto->verifyAuth2($auth)){
        return;
    }

    $database = new Database();
    $db = $database->getConnection();
    $item = new WeeklyRecords($db);
    $returnAll = false;
    $item->weekNumber = isset($_GET['weekNumber']) ? $_GET['weekNumber'] : $returnAll = true;
     
    $stmt = $item->getWeeklyRecords();
    $itemCount = $stmt->rowCount();
    //echo json_encode($itemCount);

    if($itemCount > 0){
        $recordArr = array();
        $recordArr["body"] = array();
        $recordArr["itemCount"] = $itemCount;

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
            extract($row);
            if(!$returnAll && $item->weekNumber != $weekNumber){
                continue;
            }
            $e = array(
                "id" => $id,
                "name" => $name,
                "alias" => $alias,
                "score" => $score,
                "streak" => $streak,
                "weekNumber" => $weekNumber,
                "awardPaid" => $awardPaid,
                "awardAmount" => $awardAmount
            );
            array_push($recordArr["body"], $e);
        }
        echo $crypto->encryptArray2($recordArr);
        http_response_code(200);
    }else{
        http_response_code(404);
        echo $crypto->encryptText2(
            array("message" => "No record found.")
        );
    }
?>